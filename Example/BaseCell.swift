//
//  BaseCell.swift
//  TestWidget
//
//  Created by Zhanibek Lukpanov on 04.10.2024.
//

import UIKit
internal import HalykCore
import HalykWidget

class BaseCell: UITableViewCell, ConfigurableCell {    

    typealias DataType = Processes

    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)
        label.constraintToEdges(of: contentView, insets: .init(top: 0, left: 8, bottom: 0, right: 8))
        stylyze()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = .none
    }

    private func stylyze() {
        backgroundColor = .clear
        label.textColor = .black
    }

    func configure(with data: Processes) {
        label.text = data.name
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
