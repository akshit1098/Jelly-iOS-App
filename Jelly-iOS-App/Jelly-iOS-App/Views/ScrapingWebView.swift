//
//  ScrapingWebView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

//import SwiftUI
//import WebKit
//
///// A hidden WKWebView that:
/////   1) Loads “https://www.jellyjelly.com/feed”
/////   2) Scrolls the horizontal carousel “one page” at a time so that Jelly injects all <link rel="prefetch" as="video"> tags
/////   3) Gathers every video URL (from <video> tags & <link rel="prefetch" as="video"> links)
/////   4) Stops once no new URLs appear for `maxConsecutiveRepeats`, then calls `onURLsReceived([...])`.
//struct ScrapingWebView: UIViewRepresentable {
//    /// Called once we’ve collected every unique video URL
//    let onURLsReceived: ([URL]) -> Void
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(onURLsReceived: onURLsReceived)
//    }
//
//    func makeUIView(context: Context) -> WKWebView {
//        // 1) Create a non‐persistent data store so each scrape is fresh (no cookies, no cache).
//        let config = WKWebViewConfiguration()
//        config.websiteDataStore = .nonPersistent()
//        let webView = WKWebView(frame: .zero, configuration: config)
//        webView.navigationDelegate = context.coordinator
//
//        // 2) Disable user‐driven scrolling; our JS will step‐scroll for us.
//        webView.scrollView.isScrollEnabled = false
//
//        // 3) Immediately load the “/feed” endpoint.
//        if let feedURL = URL(string: "https://www.jellyjelly.com/feed") {
//            let request = URLRequest(url: feedURL)
//            webView.load(request)
//        }
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // no dynamic updates needed
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        private let onURLsReceived: ([URL]) -> Void
//
//        /// Keep track of every URL we’ve seen so far
//        private var seen = Set<URL>()
//        private var collected = [URL]()
//
//        /// How many consecutive passes saw no new URLs
//        private var consecutiveRepeats = 0
//        private let maxConsecutiveRepeats = 6
//
//        /// Delay (in seconds) between each “step scroll” so the page has time to inject new <link> tags
//        private let stepDelay: TimeInterval = 0.5
//
//        init(onURLsReceived: @escaping ([URL]) -> Void) {
//            self.onURLsReceived = onURLsReceived
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            // Hide the WebView completely so the user never sees it
//            DispatchQueue.main.async {
//                webView.alpha = 0
//                webView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
//            }
//
//            // Give the page a moment to insert its first handful of <link rel="prefetch" as="video">
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.scrollAndCollect(in: webView)
//            }
//        }
//
//        /// Core loop:
//        ///   1) Count “(videos + link[rel=prefetch][as=video])” in the DOM.
//        ///   2) If newCount > seen.count → reset counters, collect all URLs, then step‐scroll once (calling performStepScrollLoop).
//        ///   3) If newCount ≤ seen.count → increment repeat counter. As long as repeats < maxConsecutiveRepeats, collect again & step‐scroll.
//        ///   4) Once repeats ≥ maxConsecutiveRepeats → finish and return final URL list.
//        private func scrollAndCollect(in webView: WKWebView) {
//            let countJS = """
//              document.querySelectorAll('video, link[rel="prefetch"][as="video"]').length
//            """
//            webView.evaluateJavaScript(countJS) { [weak self] result, _ in
//                guard let self = self else { return }
//                let count = (result as? NSNumber)?.intValue ?? 0
//
//                if count > self.seen.count {
//                    // We saw new tags injected → reset and gather
//                    self.seen.removeAll()
//                    self.collected.removeAll()
//                    self.consecutiveRepeats = 0
//
//                    self.collectAllVideosAndLinks(from: webView) {
//                        self.performStepScrollLoop(in: webView)
//                    }
//                } else {
//                    // No change → bump repeat counter
//                    self.consecutiveRepeats += 1
//
//                    if self.consecutiveRepeats < self.maxConsecutiveRepeats {
//                        // Still hunting: collect whatever’s visible, then step‐scroll again
//                        self.collectAllVideosAndLinks(from: webView) {
//                            self.performStepScrollLoop(in: webView)
//                        }
//                    } else {
//                        // We’ve stalled long enough → return final list
//                        self.returnFinalURLs()
//                    }
//                }
//            }
//        }
//
//        /// Gathers every `<video>`’s `currentSrc` / `src` plus every `<link rel="prefetch" as="video">`’s `href`.
//        /// Once done, calls `completion()`.
//        private func collectAllVideosAndLinks(from webView: WKWebView, completion: @escaping () -> Void) {
//            let collectJS = """
//            (function() {
//              const urls = new Set();
//              // 1) Collect from <video> tags
//              document.querySelectorAll('video').forEach(v => {
//                if (v.currentSrc) urls.add(v.currentSrc);
//                else if (v.src) urls.add(v.src);
//                v.querySelectorAll('source[src]').forEach(s => {
//                  urls.add(s.src);
//                });
//              });
//              // 2) Collect from <link rel="prefetch" as="video">
//              document.querySelectorAll('link[rel="prefetch"][as="video"]').forEach(link => {
//                if (link.href) {
//                  urls.add(link.href);
//                }
//              });
//              return Array.from(urls);
//            })();
//            """
//            webView.evaluateJavaScript(collectJS) { [weak self] result, _ in
//                guard let self = self else { return }
//                if let array = result as? [String] {
//                    for str in array {
//                        if let url = URL(string: str), !self.seen.contains(url) {
//                            self.seen.insert(url)
//                            self.collected.append(url)
//                        }
//                    }
//                }
//                completion()
//            }
//        }
//
//        /// Step‐scrolls the carousel one “page width” at a time until we reach the far right,
//        /// giving Jelly’s page JS a chance to inject each next batch of <link as="video"> tags.
//        private func performStepScrollLoop(in webView: WKWebView) {
//            let stepScrollJS = """
//            (function() {
//              // 1) Find any <video> in the DOM to locate the carousel container
//              let el = document.querySelector('video');
//              if (!el) return 0;
//              while (el && el.scrollWidth <= el.clientWidth) {
//                el = el.parentElement;
//              }
//              if (!el) return 0;
//              // 2) Now `el` is the scrolling “carousel” element
//              const pageWidth = el.clientWidth;
//              const totalWidth = el.scrollWidth;
//              // 3) Compute how many “pages” of content exist
//              const steps = Math.ceil(totalWidth / pageWidth);
//              let i = 0;
//              function doScroll() {
//                if (i >= (steps - 1)) {
//                  // If on last page, stop here
//                  return;
//                }
//                el.scrollBy(pageWidth, 0);
//                i += 1;
//                setTimeout(doScroll, \(self.stepDelay * 1000));
//              }
//              doScroll();
//              return steps;
//            })();
//            """
//            webView.evaluateJavaScript(stepScrollJS, completionHandler: nil)
//
//            // Wait long enough for `(steps × stepDelay)` plus a small buffer,
//            // then re‐run `scrollAndCollect` to see if new tags were injected.
//            let bufferTime = max(Double(8) * stepDelay, 0.7)
//            DispatchQueue.main.asyncAfter(deadline: .now() + bufferTime) {
//                self.scrollAndCollect(in: webView)
//            }
//        }
//
//        /// Called once we’re confident there are no further new URLs. Returns the final array.
//        private func returnFinalURLs() {
//            let finalList = self.collected
//            DispatchQueue.main.async {
//                self.onURLsReceived(finalList)
//            }
//        }
//    }
//}


//import SwiftUI
//import WebKit
//
///// A small, hidden WKWebView that loads "https://www.jellyjelly.com/feed"
///// and (after a short delay) grabs all <link rel="prefetch" as="video"> hrefs
///// from <head>. Once extracted, it calls `onURLsScraped([URL])`.
//struct ScrapingWebView: UIViewRepresentable {
//    /// Called once we've extracted all <link rel="prefetch" as="video"> URLs.
//    var onURLsScraped: ([URL]) -> Void
//
//    func makeUIView(context: Context) -> WKWebView {
//        let configuration = WKWebViewConfiguration()
//        configuration.preferences.javaScriptEnabled = true
//
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.navigationDelegate = context.coordinator
//
//        // Load the /feed page silently
//        if let url = URL(string: "https://www.jellyjelly.com/feed") {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
//
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // Nothing to update here—this view simply loads once and scrapes.
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: ScrapingWebView
//
//        init(_ parent: ScrapingWebView) {
//            self.parent = parent
//        }
//
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            // Wait ~0.7 seconds to allow the Next.js app to insert <link rel="prefetch" as="video"> tags into <head>
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                let js = """
//                Array.from(
//                  document.querySelectorAll("link[rel='prefetch'][as='video']")
//                ).map(el => el.href);
//                """
//
//                webView.evaluateJavaScript(js) { result, error in
//                    if let error = error {
//                        print("🔴 JS evaluation error: \(error.localizedDescription)")
//                        self.parent.onURLsScraped([])
//                        return
//                    }
//
//                    guard let hrefs = result as? [String] else {
//                        // If the result is not a String array, return empty
//                        self.parent.onURLsScraped([])
//                        return
//                    }
//
//                    let urls = hrefs.compactMap { URL(string: $0) }
//                    self.parent.onURLsScraped(urls)
//                }
//            }
//        }
//    }
//}
//
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
                    // We do not capture the evaluateJavaScript result here,
                    // since the JS calls window.webkit.messageHandlers.didScrape.postMessage(...)
                    // when it finishes gathering links.
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

        // MARK: - WKScriptMessageHandler

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
