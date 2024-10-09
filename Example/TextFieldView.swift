//
//  TextFieldView.swift
//  TestWidget
//
//  Created by Zhanibek Lukpanov on 08.08.2024.
//

import Foundation
import UIKit

protocol TextFieldViewDelegate: AnyObject {
    func textFieldDidEndEditing(with text: String)
}

class TextFieldView: UIView {

    private let mainTextField = UITextField()

    var text: String? {
        get { mainTextField.text }
        set { mainTextField.text = newValue }
    }

    weak var delegate: TextFieldViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(mainTextField)
        mainTextField.constrainToEdges(of: self)
        stylyze()
    }

    private func stylyze() {
        mainTextField.borderStyle = .roundedRect
        mainTextField.layer.borderWidth = 2
        mainTextField.layer.borderColor = UIColor.darkGray.cgColor
        mainTextField.layer.cornerRadius = 12
        mainTextField.layer.masksToBounds = true
        mainTextField.leftViewMode = .always
        mainTextField.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 0))
        mainTextField.returnKeyType = .done
        mainTextField.delegate = self
        mainTextField.backgroundColor = .clear
        mainTextField.textColor = .black
        mainTextField.text = "https://baas-test.halykbank.kz"
        // http://10.25.20.86:5551
        // https://baas-test.halykbank.kz
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension TextFieldView: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text, let range = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: range, with: string)
        delegate?.textFieldDidEndEditing(with: updatedText)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

fileprivate extension UILabel {

    var textSize: CGSize {
        guard let text, let font = UIFont(name: font.fontName, size: font.pointSize) else { return CGSize() }
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
}
