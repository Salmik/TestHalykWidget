//
//  HalykWidgetViewModel.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 25.07.2024.
//

import UIKit
import WebKit
import OZLivenessSDK
internal import HalykCore

protocol HalykWidgetViewModelViewDelegate: AnyObject {

    func loadRequest(_ request: URLRequest)
}

class HalykWidgetViewModel {

    weak var delegate: HalykWidgetViewModelViewDelegate?

    private lazy var networkManager: NetworkManager = {
        let networkManager = NetworkManager()
        networkManager.isNeedToLogRequests = true
        networkManager.isSSLPinningEnabled = false
        let bundle = Bundle(for: HalykWidgetViewModel.self)
        networkManager.certDataItems = bundle.SSLCertificates
        return networkManager
    }()

    var isFirstPage = false


    func prepareRequest(with url: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            delegate?.loadRequest(request)
        }
    }

    func sendLivenessResult(webView: WKWebView) {
        let script = Scripts.livenessOk()
        webView.evaluateJavaScript(script) { (_, error) in
            if let error {
                Logger.print("Ошибка выполнения скрипта: \(error)")
            }
        }
    }

    func analyzeDeviceLiveness(
        results: [OZMedia],
        with livenessData: LivenessInfoData,
        completion: @escaping () -> Void
    ) {
        let analysisRequest = AnalysisRequestBuilder()
        let analysis = Analysis.init(media: results, type: .quality, mode: .onDevice)
        analysisRequest.addAnalysis(analysis)

        analysisRequest.run { status in
            print(status.status)
        } errorHandler: { error in
            print(error.localizedDescription)
        } completionHandler: { [weak self] results in
            var urls: [URL] = []
            var videoUrl: URL?
            var images: [UIImage] = []
            results.analysisResults.forEach { res in
                res.resultsMedia.forEach { media in
                    if let url = media.media.bestShotURL {
                        urls.append(url)
                    }
                }
                videoUrl = res.resultsMedia.first?.media.videoURL
            }
            urls.forEach { url in
                guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
                images.append(image)
            }

            if let videoUrl {
                self?.makeMultiPartRequest(with: videoUrl, and: livenessData) {}
            }

            completion()
        }
    }

    func makeMultiPartRequest(
        with videoUrl: URL,
        and livenessData: LivenessInfoData,
        completion: @escaping () -> Void
    ) {
        guard let data = try? Data(contentsOf: videoUrl),
              let url = livenessData.liveness?.url,
              let accessToken = livenessData.liveness?.livenessAuth else {
            return
        }
        let multipartData = MultipartFormDataParameter(
            data: data,
            name: "video",
            fileName: "video.mp4",
            mimeType: data.mimeType
        )
        networkManager.multiPart(
            HalykWidgetAuthorizationApi.sendLivenessVideo(accessToken: accessToken, url: url),
            with: [multipartData]
        ) { response in
            Logger.print("DONE")
            completion()
        }
    }
}
