import Foundation
import SwiftUI
import Combine

#if canImport(UIKit)
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
typealias PlatformImage = NSImage
#endif

#if canImport(CryptoKit)
import CryptoKit
#endif

#if canImport(SwiftSoup)
import SwiftSoup
#endif

@MainActor
final class ImageFetcher: ObservableObject {
    @Published public private(set) var image: PlatformImage? = nil
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String? = nil

    private static let memoryCache = NSCache<NSURL, PlatformImage>()
    private var currentTask: Task<Void, Never>?

    private let diskCache = DiskImageCache()

    /// 페이지 URL에 대한 대표 이미지를 찾아 다운로드(또는 캐시 사용)
    func fetchImage(fromPageURL pageURL: URL) {
        cancel()
        isLoading = true
        errorMessage = nil
        image = nil

        #if DEBUG
        print("DEBUG: start fetchImage fromPageURL=\(pageURL.absoluteString)")
        #endif

        currentTask = Task { [weak self] in
            guard let self = self else { return }
            // 메모리 캐시 우선
            if let cached = Self.memoryCache.object(forKey: pageURL as NSURL) {
                #if DEBUG
                print("DEBUG: found memory cache for \(pageURL.absoluteString)")
                #endif
                self.image = cached
                self.isLoading = false
                return
            }

            do {
                // 1) HTML 또는 리소스 가져오기
                let (data, response) = try await URLSession.shared.data(from: pageURL)

                // 1a) 응답의 MIME 타입을 검사해 image/*이면 바로 처리
                #if DEBUG
                print("DEBUG: response mimeType=\(response.mimeType ?? "nil")")
                #endif
                if let mime = response.mimeType, mime.lowercased().hasPrefix("image") {
                    #if DEBUG
                    print("DEBUG: response is image, size=\(data.count)")
                    #endif
                    if let platformImage = PlatformImage(data: data) {
                        // 저장: 디스크와 메모리
                        self.diskCache.save(data: data, for: pageURL)
                        Self.memoryCache.setObject(platformImage, forKey: pageURL as NSURL)
                        self.image = platformImage
                    } else {
                        self.errorMessage = "이미지 디코딩 실패"
                    }
                    self.isLoading = false
                    return
                }

                // try different encodings (for HTML)
                let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""

                // 2) 이미지 URL 추출 (SwiftSoup 사용 가능하면 사용)
                var foundImageURLString: String? = nil

                #if canImport(SwiftSoup)
                do {
                    foundImageURLString = try Self.extractUsingSwiftSoup(html: html)
                    #if DEBUG
                    print("DEBUG: swiftSoup foundImageURLString=\(foundImageURLString ?? "nil")")
                    #endif
                } catch {
                    foundImageURLString = nil
                }
                #endif

                // fallback: 기존 정규식 기반 추출
                if foundImageURLString == nil {
                    foundImageURLString = Self.extractRepresentativeImageURL(fromHTML: html) ?? Self.extractFirstImageSrc(fromHTML: html)
                    #if DEBUG
                    print("DEBUG: regex fallback foundImageURLString=\(foundImageURLString ?? "nil")")
                    #endif
                }

                guard let imgStr = foundImageURLString, let resolved = Self.resolve(urlString: imgStr, base: pageURL) else {
                    #if DEBUG
                    print("DEBUG: no representative image found for page \(pageURL.absoluteString)")
                    #endif
                    self.errorMessage = "대표 이미지 찾지 못함"
                    self.isLoading = false
                    return
                }

                #if DEBUG
                print("DEBUG: resolved image URL=\(resolved.absoluteString)")
                #endif

                // 3) 디스크 캐시 확인 (image URL을 키로 사용)
                if let diskData = self.diskCache.loadData(for: resolved),
                   let platformImage = PlatformImage(data: diskData) {
                    #if DEBUG
                    print("DEBUG: loaded image from disk cache for \(resolved.absoluteString)")
                    #endif
                    Self.memoryCache.setObject(platformImage, forKey: pageURL as NSURL)
                    self.image = platformImage
                    self.isLoading = false
                    return
                }

                // 4) 이미지 다운로드
                let (imgData, imgResp) = try await URLSession.shared.data(from: resolved)
                #if DEBUG
                print("DEBUG: downloaded image bytes=\(imgData.count), resp mime=\(imgResp.mimeType ?? "nil")")
                #endif

                if let platformImage = PlatformImage(data: imgData) {
                    // 저장: 디스크와 메모리
                    self.diskCache.save(data: imgData, for: resolved)
                    Self.memoryCache.setObject(platformImage, forKey: pageURL as NSURL)
                    self.image = platformImage
                } else {
                    self.errorMessage = "이미지 디코딩 실패"
                }
            } catch {
                if Task.isCancelled { return }
                #if DEBUG
                print("DEBUG: fetchImage error=\(error)")
                #endif
                self.errorMessage = "이미지 로드 실패: \(error.localizedDescription)"
            }

            self.isLoading = false
        }
    }

    func cancel() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }

    // MARK: - SwiftSoup helper (optional)
    #if canImport(SwiftSoup)
    private static func extractUsingSwiftSoup(html: String) throws -> String? {
        let doc = try SwiftSoup.parse(html)
        // og:image
        if let og = try doc.select("meta[property=og:image]").first() {
            let content = try og.attr("content")
            if !content.isEmpty { return content }
        }
        if let tw = try doc.select("meta[name=twitter:image]").first() {
            let content = try tw.attr("content")
            if !content.isEmpty { return content }
        }
        if let link = try doc.select("link[rel=image_src]").first() {
            let href = try link.attr("href")
            if !href.isEmpty { return href }
        }
        if let img = try doc.select("img").first() {
            let src = try img.attr("src")
            if !src.isEmpty { return src }
        }
        return nil
    }
    #endif

    // MARK: - 기존 정규식 기반 추출 (fallback)
    private static func extractRepresentativeImageURL(fromHTML html: String) -> String? {
        if let v = matchRegex(html, pattern: "<meta[^>]+property=[\\\"']og:image[\\\"'][^>]*content=[\\\"']([^\\\"']+)[\\\"']", caseInsensitive: true) {
            return v
        }
        if let v = matchRegex(html, pattern: "<meta[^>]+name=[\\\"']og:image[\\\"'][^>]*content=[\\\"']([^\\\"']+)[\\\"']", caseInsensitive: true) {
            return v
        }
        if let v = matchRegex(html, pattern: "<meta[^>]+name=[\\\"']twitter:image[\\\"'][^>]*content=[\\\"']([^\\\"']+)[\\\"']", caseInsensitive: true) {
            return v
        }
        if let v = matchRegex(html, pattern: "<link[^>]+rel=[\\\"']image_src[\\\"'][^>]*href=[\\\"']([^\\\"']+)[\\\"']", caseInsensitive: true) {
            return v
        }
        return nil
    }

    private static func extractFirstImageSrc(fromHTML html: String) -> String? {
        if let v = matchRegex(html, pattern: "<img[^>]+src=[\\\"']([^\\\"']+)[\\\"']", caseInsensitive: true) {
            return v
        }
        return nil
    }

    private static func matchRegex(_ text: String, pattern: String, caseInsensitive: Bool = false) -> String? {
        do {
            let opts: NSRegularExpression.Options = caseInsensitive ? [.caseInsensitive] : []
            let regex = try NSRegularExpression(pattern: pattern, options: opts)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            if let m = regex.firstMatch(in: text, options: [], range: range), m.numberOfRanges >= 2 {
                let r = m.range(at: 1)
                if let swiftRange = Range(r, in: text) {
                    return String(text[swiftRange])
                }
            }
        } catch {
            return nil
        }
        return nil
    }

    private static func resolve(urlString: String, base: URL) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if let absolute = URL(string: trimmed), absolute.scheme != nil {
            return absolute
        }
        if let resolved = URL(string: trimmed, relativeTo: base)?.absoluteURL {
            return resolved
        }
        return nil
    }
}

// MARK: - Disk Image Cache
final class DiskImageCache {
    private let directoryURL: URL
    private let fileManager = FileManager.default

    init(folderName: String = "ImageCache") {
        if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            directoryURL = caches.appendingPathComponent(folderName, isDirectory: true)
        } else {
            directoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        }
        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    func cacheFileURL(for url: URL) -> URL {
        let key = sha256(url.absoluteString)
        return directoryURL.appendingPathComponent(key)
    }

    func loadData(for url: URL) -> Data? {
        let file = cacheFileURL(for: url)
        return try? Data(contentsOf: file)
    }

    func save(data: Data, for url: URL) {
        let file = cacheFileURL(for: url)
        try? data.write(to: file, options: .atomic)
    }

    private func sha256(_ string: String) -> String {
        #if canImport(CryptoKit)
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
        #else
        // Fallback: base64 of utf8 (replace problematic chars)
        let data = Data(string.utf8)
        return data.base64EncodedString().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        #endif
    }
}

// MARK: - RemoteImageView
struct RemoteImageView<Placeholder: View>: View {
    @StateObject private var fetcher = ImageFetcher()
    let pageURL: URL
    var contentMode: ContentMode = .fill
    var placeholder: Placeholder

    init(pageURL: URL,
         contentMode: ContentMode = .fill,
         @ViewBuilder placeholder: () -> Placeholder) {
        self.pageURL = pageURL
        self.contentMode = contentMode
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if fetcher.isLoading {
                placeholder
            } else if let img = fetcher.image {
                #if canImport(UIKit)
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #elseif canImport(AppKit)
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #else
                placeholder
                #endif
            } else if let error = fetcher.errorMessage {
                VStack {
                    placeholder
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                placeholder
            }
        }
        .task(id: pageURL) {
            fetcher.fetchImage(fromPageURL: pageURL)
        }
        .onDisappear {
            fetcher.cancel()
        }
    }
}
