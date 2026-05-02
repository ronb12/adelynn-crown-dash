import Foundation
import WebKit

/// Serves bundled `Game/` files under **`appassets://`** so WKWebView can load large binaries (e.g. 50MB+ `.glb`)
/// without `file://` XHR/fetch failing with a generic **"Load failed"** after partial progress.
///
/// **HTTPURLResponse:** `fetch` / **Three.js `FileLoader`** need a real HTTP response with **`Content-Type`** and **`Content-Length`**.
///
/// **Always status 200:** `three/src/loaders/FileLoader.js` only accepts **`status === 200` or `0`**. A **206** response
/// (e.g. after a `Range` request) is **rejected** and surfaces as **Load failed** — so we always send the full
/// body with **200** and ignore `Range` (allowed per HTTP: server may return full representation).
final class GameAssetSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    /// `file://` pages loading `appassets:` are cross-origin; without these, **XHR** fails (`onerror`) and **fetch** can still fail for large bodies.
    private static let corsHeaders: [String: String] = [
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Expose-Headers": "Content-Length, Content-Type",
    ]

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing URL"]))
            return
        }

        let method = urlSchemeTask.request.httpMethod?.uppercased() ?? "GET"
        guard method == "GET" || method == "HEAD" || method == "OPTIONS" else {
            urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: 405, userInfo: [NSLocalizedDescriptionKey: "Unsupported method: \(method)"]))
            return
        }

        if method == "OPTIONS" {
            var headers = Self.corsHeaders
            headers["Access-Control-Max-Age"] = "86400"
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 204,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            ) else {
                urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: -5, userInfo: [NSLocalizedDescriptionKey: "Bad OPTIONS response"]))
                return
            }
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didFinish()
            return
        }

        var rawPath = url.path
        if rawPath.hasPrefix("/") {
            rawPath.removeFirst()
        }
        let safeComponents = rawPath.split(separator: "/").filter { $0 != "." && $0 != ".." }
        guard !safeComponents.isEmpty else {
            urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty path"]))
            return
        }
        let relativePath = safeComponents.joined(separator: "/")

        let fileURL = Bundle.main.bundleURL
            .appendingPathComponent("Game")
            .appendingPathComponent(relativePath)

        let gameFolder = Bundle.main.bundleURL.appendingPathComponent("Game").standardizedFileURL
        let gamePath = gameFolder.path
        let filePath = fileURL.standardizedFileURL.path
        guard filePath == gamePath || filePath.hasPrefix(gamePath + "/") else {
            urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: -3, userInfo: [NSLocalizedDescriptionKey: "Path outside Game/"]))
            return
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found: \(relativePath)"]))
            return
        }

        let mime = Self.mimeType(for: fileURL.pathExtension.lowercased())

        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = attrs[.size] as? Int64 ?? 0

            guard let fh = FileHandle(forReadingAtPath: fileURL.path) else {
                urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: -4, userInfo: [NSLocalizedDescriptionKey: "Could not open file"]))
                return
            }
            defer { try? fh.close() }

            // Three.js FileLoader only accepts HTTP 200 (or 0). Never use 206 here.
            var headers = Self.corsHeaders
            headers["Content-Type"] = mime
            headers["Content-Length"] = "\(fileSize)"
            headers["Accept-Ranges"] = "bytes"
            headers["Cache-Control"] = "public, max-age=31536000, immutable"
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            ) else {
                urlSchemeTask.didFailWithError(NSError(domain: "GameAsset", code: -5, userInfo: [NSLocalizedDescriptionKey: "Bad HTTP response"]))
                return
            }
            urlSchemeTask.didReceive(response)

            if method == "HEAD" {
                urlSchemeTask.didFinish()
                return
            }

            let chunkSize = 1024 * 1024
            while true {
                let chunk = try fh.read(upToCount: chunkSize) ?? Data()
                if chunk.isEmpty { break }
                urlSchemeTask.didReceive(chunk)
            }
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }

    private static func mimeType(for ext: String) -> String {
        switch ext {
        case "glb": return "model/gltf-binary"
        case "gltf": return "model/gltf+json"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "webp": return "image/webp"
        case "json": return "application/json"
        case "js": return "text/javascript"
        case "html": return "text/html"
        case "css": return "text/css"
        case "woff2": return "font/woff2"
        case "woff": return "font/woff"
        default: return "application/octet-stream"
        }
    }
}
