//
//  HalykWidgetViewModel.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 25.07.2024.
//

import UIKit
import WebKit
internal import HalykCore

protocol HalykWidgetViewModelViewDelegate: AnyObject {

    func loadRequest(_ request: URLRequest)
}

class HalykWidgetViewModel {

    private let fraudManager = FraudDataConfigurator()
    weak var delegate: HalykWidgetViewModelViewDelegate?

    var isFirstPage = false

    func prepareRequest(with url: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            delegate?.loadRequest(request)
        }
    }

    func sendInitialPayload(webView: WKWebView) {
        let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let fraudData = fraudManager.makeFraudData()
        let page = "HomePage"

        let safePartnerToken = CommonInformation.shared.partnersToken?.replacingOccurrences(of: "'", with: "\\'") ?? ""
        let safeFraudData = fraudData
        let safePage = page.replacingOccurrences(of: "'", with: "\\'")

        let script = """
        window.HalykWidget = {
            partnerToken: '\(safePartnerToken)',
            fraudData: '\(safeFraudData)',
            top: \(safeAreaTop),
            bottom: \(safeAreaBottom),
            page: '\(safePage)'
        };
        """
        Logger.print(script)

        webView.evaluateJavaScript(script) { [weak self] (_, error) in
            if let error {
                Logger.print("JavaScript error: \(error.localizedDescription)")
            } else {
                self?.isFirstPage = false
            }
        }
    }

    func sendLivenessResult(webView: WKWebView) {
        let script = """
            window.dispatchEvent(new CustomEvent('livenessDone', {
              detail: {
                status: 'ok'
              }
            }));
        """
        webView.evaluateJavaScript(script) { (result, error) in
            if let error {
                print("Ошибка выполнения скрипта: \(error)")
            }
        }
    }

//    func analyzeDeviceLiveness(results: [OZMedia], completion: @escaping ([UIImage]) -> Void) {
//        let analysisRequest = AnalysisRequestBuilder()
//        let analysis = Analysis.init(media: results, type: .quality, mode: .onDevice)
//        analysisRequest.addAnalysis(analysis)
//
//        analysisRequest.run { status in
//            print(status.status)
//        } errorHandler: { error in
//            print(error.localizedDescription)
//        } completionHandler: { [weak self] results in
//            var urls: [URL] = []
//            var images: [UIImage] = []
//            results.analysisResults.forEach { res in
//                res.resultsMedia.forEach { media in
//                    if let url = media.media.bestShotURL {
//                        urls.append(url)
//                    }
//                }
//            }
//            urls.forEach { url in
//                guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
//                images.append(image)
//            }
//            completion(images)
//        }
//    }

    func makeMultiPartRequest() {
        // Реализация многосегментного запроса
    }
}
