//
//  LoginAndScrapeWebView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

import SwiftUI
import WebKit

struct LoginAndScrapeWebView: UIViewRepresentable {
    /// The URL where the user should log in
        private let loginURL = URL(string: "https://www.jellyjelly.com/login")!
        /// The URL of the authenticated feed
        private let feedURL = URL(string: "https://www.jellyjelly.com/feed")!
        
        /// Called once we have fully rendered (and scrolled) `/feed` and captured its HTML
        let onHTMLReceived: (String) -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(onHTMLReceived: onHTMLReceived, feedURL: feedURL)
        }

        func makeUIView(context: Context) -> WKWebView {
            // Use the default (persistent) data store so login cookies persist in this WebView.
            let config = WKWebViewConfiguration()
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.navigationDelegate = context.coordinator

            // Initially load the login page
            webView.load(URLRequest(url: loginURL))

            // Full-screen, visible to the user (so they can sign in)
            webView.isOpaque = true
            webView.backgroundColor = .white
            webView.scrollView.isScrollEnabled = true

            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            // no-op
        }

        class Coordinator: NSObject, WKNavigationDelegate {
            private let onHTMLReceived: (String) -> Void
            private let feedURL: URL
            private var didBeginScraping = false

            // State for “scroll until no more <video> tags appear.”
            private var lastVideoCount: Int = 0
            private var scrollAttempts: Int = 0
            private let maxScrollAttempts = 15
            private let scrollInterval: TimeInterval = 0.5

            init(onHTMLReceived: @escaping (String) -> Void, feedURL: URL) {
                self.onHTMLReceived = onHTMLReceived
                self.feedURL = feedURL
            }

            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                // 1) If we haven’t started scraping yet, check if the URL is /feed:
                guard !didBeginScraping else { return }

                if let currentURL = webView.url, currentURL.path == feedURL.path {
                    // The login just succeeded and we’re now on /feed → begin scraping
                    didBeginScraping = true
                    // Give the page a moment to hydrate, then start scrolling
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.checkVideoCountAndScroll(in: webView)
                    }
                }
                // else: still on /login or some other page, do nothing—user is signing in
            }

            private func checkVideoCountAndScroll(in webView: WKWebView) {
                // Count how many <video> tags are in the DOM right now
                let countJS = "document.querySelectorAll('video').length"
                webView.evaluateJavaScript(countJS) { [weak self] result, _ in
                    guard let self = self, !self.didBeginScraping == false else { return }
                    let count = (result as? NSNumber)?.intValue ?? 0

                    if count > self.lastVideoCount {
                        // New videos have appeared!
                        self.lastVideoCount = count
                        self.scrollAttempts = 0
                        // Scroll to bottom so next batch can load
                        let scrollJS = "window.scrollTo(0, document.body.scrollHeight);"
                        webView.evaluateJavaScript(scrollJS, completionHandler: nil)
                        // Check again after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.scrollInterval) {
                            self.checkVideoCountAndScroll(in: webView)
                        }
                    }
                    else {
                        // No increase this time
                        self.scrollAttempts += 1
                        if self.scrollAttempts < self.maxScrollAttempts {
                            // Try scrolling again to ensure we didn’t miss a late load
                            let scrollJS = "window.scrollTo(0, document.body.scrollHeight);"
                            webView.evaluateJavaScript(scrollJS, completionHandler: nil)
                            DispatchQueue.main.asyncAfter(deadline: .now() + self.scrollInterval) {
                                self.checkVideoCountAndScroll(in: webView)
                            }
                        }
                        else {
                            // Enough attempts with no new videos → grab final HTML
                            self.didBeginScraping = true // prevent re-entry
                            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { htmlResult, _ in
                                let html = (htmlResult as? String) ?? ""
                                self.onHTMLReceived(html)
                            }
                        }
                    }
                }
            }
        }
}

