//
//  HalykWidgetController.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 25.07.2024.
//

import UIKit
import WebKit
import OZLivenessSDK
internal import HalykCore

public enum Flow { case onBoarding, authorization, homepage }

public class HalykWidgetController: UIViewController {

    private let webView = MessageWebView()
    private let viewModel = HalykWidgetViewModel()
    private var ozLivenessVC: UIViewController?
    private var livenessData: LivenessInfoData?
    private var url: String

    public init(url: String = "https://baas-test.halykbank.kz") {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        ForenzicConfigurator.configure()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        viewModel.prepareRequest(with: url)
    }

    private func setupUI() {
        view.addSubview(webView)
        webView.constraintToEdges(of: view)
        view.backgroundColor = .white
        webView.backgroundColor = .clear
    }

    private func bindViewModel() {
        viewModel.delegate = self
        webView.messagingDelegate = self
        webView.navigationDelegate = self
    }

    private func showLivenessPage() {
        do {
            let bundle = Bundle(for: HalykWidgetController.self)

            try OZSDK.set(licenseBundle: bundle)
            let ozLivenessVC = try OZSDK.createVerificationVCWithDelegate(self, actions: [.selfie])
            self.ozLivenessVC = ozLivenessVC
            present(ozLivenessVC, animated: true)
        } catch {
            dump(error)
            Logger.print("Unable to create OZSDK")
        }
    }

    private func onDeviceLiveness(results: [OZMedia]) {
        guard let livenessData else { return }

        viewModel.analyzeDeviceLiveness(results: results, with: livenessData) { [weak self] in
            guard let viewController = self else { return }

            OZSDK.cleanTempDirectory()
            if let ozLivenessVC = viewController.ozLivenessVC {
                ozLivenessVC.dismiss(animated: true)
            }
            viewController.viewModel.sendLivenessResult(webView: viewController.webView)
        }
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

 extension HalykWidgetController: OZLivenessDelegate {

    public func onOZLivenessResult(results: [OZLivenessSDK.OZMedia]) {
        onDeviceLiveness(results: results)
    }

    public func onError(status: OZLivenessSDK.OZVerificationStatus?) {}
}

extension HalykWidgetController: HalykWidgetViewModelViewDelegate {

    public func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }
}

extension HalykWidgetController: WKNavigationDelegate {}

extension HalykWidgetController: MessagingWebViewDelegate {

    public func webView(_ webView: WKWebView, didReceiveAction action: String) {
        guard let webViewAction = MessagingWebViewActions(rawValue: action) else { return }

        switch webViewAction {
        case .close: dismiss(animated: true)
        case .liveness:
            guard let livenessData: LivenessInfoData = action.decode() else { return }
            self.livenessData = livenessData
            showLivenessPage()
        case .log:
            Logger.print(action)
        }
    }
}
