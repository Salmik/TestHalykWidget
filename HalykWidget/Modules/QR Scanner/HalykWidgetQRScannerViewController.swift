//
//  HalykWidgetQRScannerViewController.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 16.10.2024.
//

import UIKit
import AVFoundation
import Combine

public class HalykWidgetQRScannerViewController: UIViewController {

    private var viewModel = HalykWidgetQRScannerViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let backgroundView = UIView()
    private let backButton = UIButton(type: .close)
    private let focusView = UIView()
    private let focusFrameView = CameraFocusFrameView()
    private let activityIndicatorView = UIActivityIndicatorView()

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Halyk Widget QR"

        addSubviews()
        setLayoutConstraints()
        stylize()
        setActions()
        bindViewModel()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        focus(onArea: focusView.frame)
    }

    private func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(backButton)
        view.addSubview(focusView)
        view.addSubview(focusFrameView)
        view.addSubview(activityIndicatorView)
    }

    private func setLayoutConstraints() {
        backgroundView.constraintToEdges(of: view)

        backButton.makeConstraints { button in
            return [
                button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16)
            ]
        }
        backButton.constraintSize(to: .init(width: 24, height: 24))

        focusView.constraintToCenter(of: view)
        focusView.constraintSize(to: .init(width: 260, height: 260))

        focusFrameView.constraintToCenter(of: focusView)
        focusFrameView.constraintSize(to: .init(width: 24, height: 24))

        activityIndicatorView.makeConstraints { activityIndicatorView in
            return [
                activityIndicatorView.topAnchor.constraint(equalTo: focusFrameView.bottomAnchor, constant: 24),
                activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        }
        activityIndicatorView.constraintSize(to: .init(width: 24, height: 24))
    }

    private func stylize() {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)

        backButton.tintColor = UIColor.white

        focusFrameView.radius = 32
        focusFrameView.backgroundColor = .clear

        activityIndicatorView.color = UIColor.white
    }

    private func setActions() {
        backButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        viewModel.startCaptureSession()
    }

    private func bindViewModel() {
        viewModel.$previewLayer
            .compactMap { $0 }
            .sink { [weak self] previewLayer in
                previewLayer.frame = self?.view.frame ?? .zero
                self?.view.layer.insertSublayer(previewLayer, at: 0)
            }
            .store(in: &cancellables)

        viewModel.$scanResult
            .sink { [weak self] scanResult in
                let alert = UIAlertController(title: "Scan Result", message: scanResult, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    self?.dismiss(animated: true)
                }
                alert.addAction(action)
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }

    private func focus(onArea frame: CGRect) {
        let path = UIBezierPath(rect: UIScreen.main.bounds)
        let rectPath = UIBezierPath(roundedRect: frame, cornerRadius: 24)
        path.append(rectPath.reversing())

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd

        backgroundView.layer.mask = maskLayer
    }

    @objc private func buttonAction() { dismiss(animated: true) }
}
