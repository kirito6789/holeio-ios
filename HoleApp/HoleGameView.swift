import SwiftUI
import Foundation
import WebKit

struct HoleGameView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: Self.viewportFixScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )
        configuration.setURLSchemeHandler(context.coordinator.schemeHandler, forURLScheme: "game")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = false
        webView.load(URLRequest(url: URL(string: "game://app/index.html")!))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator {
        let schemeHandler = LocalGameSchemeHandler()
    }

    private static let viewportFixScript = """
    (function () {
      function fixViewport() {
        var stage = document.getElementById('game-stage');
        if (stage) {
          stage.style.position = 'fixed';
          stage.style.left = '0';
          stage.style.top = '0';
          stage.style.width = '100vw';
          stage.style.height = '100vh';
          stage.style.zIndex = '0';
        }
        window.dispatchEvent(new Event('resize'));
      }
      function scheduleFixes() {
        [0, 50, 150, 400, 1000, 2500].forEach(function (delay) {
          setTimeout(fixViewport, delay);
        });
      }
      window.addEventListener('load', scheduleFixes);
      window.addEventListener('orientationchange', scheduleFixes);
      document.addEventListener('visibilitychange', function () {
        if (!document.hidden) scheduleFixes();
      });
      if (window.visualViewport) {
        window.visualViewport.addEventListener('resize', fixViewport);
      }
      scheduleFixes();
    })();
    """
}
