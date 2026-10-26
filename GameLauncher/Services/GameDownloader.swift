import Foundation
import Combine

final class GameDownloader: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var lastError: String?

    private var completion: ((Result<URL, Error>) -> Void)?
    private var destURL: URL?

    private let fm = FileManager.default

    var downloadsDir: URL {
        let dir = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Downloads", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        return URLSession(configuration: cfg, delegate: self, delegateQueue: nil)
    }()

    func download(from urlString: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            lastError = "下载链接无效"
            completion(.failure(NSError(domain: "GameLauncher", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "下载链接无效"])))
            return
        }
        self.completion = completion
        destURL = downloadsDir.appendingPathComponent(fileName)
        progress = 0
        isDownloading = true
        session.downloadTask(with: url).resume()
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            DispatchQueue.main.async {
                self.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let dest = destURL else { return }
        try? fm.removeItem(at: dest)
        do {
            try fm.moveItem(at: location, to: dest)
            DispatchQueue.main.async {
                self.isDownloading = false
                self.completion?(.success(dest))
            }
        } catch {
            DispatchQueue.main.async {
                self.isDownloading = false
                self.lastError = error.localizedDescription
                self.completion?(.failure(error))
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.isDownloading = false
                self.lastError = error.localizedDescription
                self.completion?(.failure(error))
            }
        }
    }
}
