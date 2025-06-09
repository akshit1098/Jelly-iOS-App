//
//  ScrapingWebView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//


import SwiftUI
import WebKit

/// A small, hidden WKWebView that loads "https://www.jellyjelly.com/feed"
/// and then—once the page has fully rendered—scrapes every
///   <link rel="prefetch" as="video" href="…">
/// by programmatically clicking the “Next” arrow up to 5 times
/// (with a 0.5 s delay between clicks), collecting all unique hrefs,
/// and finally posting them back to Swift via a script message.
struct ScrapingWebView: UIViewRepresentable {
    /// Called once we have collected the full [URL] list
    var onURLsScraped: ([URL]) -> Void

    func makeUIView(context: Context) -> WKWebView {
        // 1) Configure a userContentController and register our message handler
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator,
                                  name: "didScrape") // JS will call window.webkit.messageHandlers.didScrape.postMessage([...])

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptEnabled = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        // 2) Load the /feed page
        if let url = URL(string: "https://www.jellyjelly.com/feed") {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        // Hide the webView offscreen
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No dynamic updates needed—this view simply loads once and scrapes.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: ScrapingWebView
        private var hasScraped = false

        init(_ parent: ScrapingWebView) {
            self.parent = parent
        }

        // MARK: - WKNavigationDelegate

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Only scrape once per page load
            guard !hasScraped else { return }
            hasScraped = true

            // ─────────────────────────────────────────────────────────────────
            // Increase the delay to 2.0s (from 0.7s) so that Next.js can fully hydrate
            // and insert the initial <link rel="prefetch" as="video"> into <head>.
            // ─────────────────────────────────────────────────────────────────
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let js = """
                (function() {
                  const collected = new Set();

                  function grabLinks() {
                    document.querySelectorAll("link[rel='prefetch'][as='video']").forEach(el => {
                      if (el.href) {
                        collected.add(el.href);
                      }
                    });
                  }

                  // 1) Grab any <link> tags already present
                  grabLinks();

                  // 2) Find the “Next” arrow button (adjust selectors if needed)
                  let nextBtn = document.querySelector("button[aria-label*='Next']") ||
                                document.querySelector("button[aria-label*='next']") ||
                                document.querySelector(".chakra-icon-button");

                  let clickCount = 0;
                  function clickNextStep() {
                    if (clickCount >= 5 || !nextBtn) {
                      // 4) When done, post the deduped array back to Swift:
                      window.webkit.messageHandlers.didScrape.postMessage(Array.from(collected));
                      return;
                    }
                    nextBtn.click();
                    clickCount++;

                    // After 500ms, re‐grab any new <link> tags and repeat
                    setTimeout(function() {
                      grabLinks();
                      // Re‐query the “Next” arrow in case the DOM re‐rendered
                      nextBtn = document.querySelector("button[aria-label*='Next']") ||
                                document.querySelector("button[aria-label*='next']") ||
                                document.querySelector(".chakra-icon-button");
                      clickNextStep();
                    }, 500);
                  }

                  // Start the chain:
                  clickNextStep();
                })();
                """

                webView.evaluateJavaScript(js, completionHandler: { _, error in
                    if let error = error {
                        print("🔴 JS injection error: \(error.localizedDescription)")
                        // If JS fails immediately, return an empty result so UI can retry
                        self.parent.onURLsScraped([])
                    }
                })
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("🔴 WebView navigation failed: \(error.localizedDescription)")
            parent.onURLsScraped([])
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("🔴 WebView provisional load failed: \(error.localizedDescription)")
            parent.onURLsScraped([])
        }

        // WKScriptMessageHandler

        /// Invoked by JavaScript `window.webkit.messageHandlers.didScrape.postMessage([...])`
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "didScrape" else {
                return
            }
            // Expect message.body to be an Array of String URLs
            if let hrefArray = message.body as? [String] {
                let urls = hrefArray.compactMap { URL(string: $0) }
                parent.onURLsScraped(urls)
            } else {
                parent.onURLsScraped([])
            }
        }
    }
}
