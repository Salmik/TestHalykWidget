//
//  MessageWebView.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 02.08.2024.
//

import WebKit

protocol MessagingWebViewDelegate: AnyObject {

    func webView(_ webView: WKWebView, didReceiveAction action: String)
}

class MessageWebView: WKWebView, WKUIDelegate {

    weak var messagingDelegate: MessagingWebViewDelegate?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        webConfiguration.allowsInlineMediaPlayback = true
        if #available(iOS 15.4, *) {
            webConfiguration.preferences.isElementFullscreenEnabled = true
        }
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.userContentController = contentController
        super.init(frame: frame, configuration: webConfiguration)
        contentController.add(self, name: "bridge")
        self.isOpaque = false
        self.backgroundColor = .clear
        self.allowsBackForwardNavigationGestures = false
        self.scrollView.bounces = false
        uiDelegate = self
        scrollView.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension MessageWebView: WKScriptMessageHandler {

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "bridge", let messageBody = message.body as? String {
            messagingDelegate?.webView(self, didReceiveAction: messageBody)
        }
    }
}

extension MessageWebView: UIScrollViewDelegate {

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
