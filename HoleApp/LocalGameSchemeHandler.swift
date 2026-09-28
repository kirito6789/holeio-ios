import Foundation
import WebKit

final class LocalGameSchemeHandler: NSObject, WKURLSchemeHandler {
    private let gameRoot: URL? = Bundle.main.resourceURL?
        .appendingPathComponent("Game", isDirectory: true)
        .standardizedFileURL

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let requestURL = urlSchemeTask.request.url,
              let gameRoot = gameRoot else {
            fail(urlSchemeTask, status: 404)
            return
        }

        let requestedPath = requestURL.path.removingPercentEncoding ?? requestURL.path
        let relativePath = requestedPath == "/" || requestedPath.isEmpty
            ? "index.html"
            : requestedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard !relativePath.split(separator: "/").contains("..") else {
            fail(urlSchemeTask, status: 403)
            return
        }

        let fileURL = gameRoot.appendingPathComponent(relativePath).standardizedFileURL
        let rootPath = gameRoot.path.hasSuffix("/") ? gameRoot.path : gameRoot.path + "/"
        guard fileURL.path.hasPrefix(rootPath) else {
            fail(urlSchemeTask, status: 403)
            return
        }

        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let response = HTTPURLResponse(
                url: requestURL,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": Self.mimeType(for: fileURL.pathExtension),
                    "Cache-Control": "no-store"
                ]
            )!
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            fail(urlSchemeTask, status: 404)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    private func fail(_ urlSchemeTask: WKURLSchemeTask, status: Int) {
        guard let url = urlSchemeTask.request.url else { return }
        let response = HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "text/plain; charset=utf-8"]
        )!
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(Data())
        urlSchemeTask.didFinish()
    }

    private static func mimeType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "js", "mjs": return "text/javascript; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "json", "webmanifest": return "application/json; charset=utf-8"
        case "svg": return "image/svg+xml"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "ico": return "image/x-icon"
        case "woff": return "font/woff"
        case "woff2": return "font/woff2"
        case "ttf": return "font/ttf"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "m4a": return "audio/mp4"
        case "ogg": return "audio/ogg"
        case "wasm": return "application/wasm"
        default: return "application/octet-stream"
        }
    }
}
