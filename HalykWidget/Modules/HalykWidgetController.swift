//
//  HalykWidgetController.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 25.07.2024.
//

import UIKit
import WebKit
import Combine
internal import HalykCore

public enum Flow { case onBoarding, authorization, homepage }

public class HalykWidgetController: UIViewController {

    private let webView = MessageWebView()
    private let viewModel = HalykWidgetViewModel()
    private var url: String

    public init(url: String = "https://baas-test.halykbank.kz") {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        viewModel.prepareRequest(with: url)
    }

    private func setupUI() {
        view.addSubview(webView)
        webView.constrainToEdges(of: view)
        view.backgroundColor = .white
        webView.backgroundColor = .clear
    }

    private func bindViewModel() {
        viewModel.delegate = self
        webView.messagingDelegate = self
        webView.navigationDelegate = self
    }

    private func showLivenessPage() {
//        do {
//            let bundle = Bundle(for: HalykWidgetController.self)
//
//            try OZSDK.set(licenseBundle: bundle)
//            let ozLivenessVC = try OZSDK.createVerificationVCWithDelegate(self, actions: [.selfie])
//            self.ozLivenessVC = ozLivenessVC
//            present(ozLivenessVC, animated: true)
//        } catch {
//            dump(error)
//            print("Unable to create OZSDK")
//        }
    }

//    private func onDeviceLiveness(results: [OZMedia]) {
//        viewModel.analyzeDeviceLiveness(results: results) { [weak self] images in
//            guard let viewController = self else { return }
//
//            viewController.viewModel.makeMultiPartRequest()
//            OZSDK.cleanTempDirectory()
//            if let ozLivenessVC = viewController.ozLivenessVC {
//                ozLivenessVC.dismiss(animated: true)
//            }
//            viewController.viewModel.sendLivenessResult(webView: viewController.webView)
//        }
//    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// extension HalykWidgetController: OZLivenessDelegate {
//
//    public func onOZLivenessResult(results: [OZLivenessSDK.OZMedia]) {
//        onDeviceLiveness(results: results)
//    }
//
//    public func onError(status: OZLivenessSDK.OZVerificationStatus?) {}
//}

extension HalykWidgetController: HalykWidgetViewModelViewDelegate {

    public func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
}

extension HalykWidgetController: WKNavigationDelegate {

    // swiftlint:disable implicitly_unwrapped_optional
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !viewModel.isFirstPage {
            viewModel.sendInitialPayload(webView: webView)
            viewModel.isFirstPage = true
        }
    }
}

extension HalykWidgetController: MessagingWebViewDelegate {

    public func webView(_ webView: WKWebView, didReceiveAction action: String) {
        print(action)
        guard let action = MessagingWebViewActions(rawValue: action) else { return }

        switch action {
        case .close: dismiss(animated: true)
        case .liveness: showLivenessPage()
        }
    }
}
