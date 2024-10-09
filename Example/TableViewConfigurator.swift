//
//  TableViewConfigurator.swift
//  TestWidget
//
//  Created by Zhanibek Lukpanov on 07.10.2024.
//

import UIKit

protocol ConfigurableCell {
    associatedtype DataType
    func configure(with data: DataType)
}

protocol CellConfigurator: AnyObject {
    static var reuseID: String { get }
    func configure(cell: UIView)
    func register(in tableView: UITableView)
}

class TableCellConfigurator<
    CellType: ConfigurableCell,
    DataType
>: CellConfigurator where CellType.DataType == DataType, CellType: UITableViewCell {

    let item: DataType

    init(item: DataType) { self.item = item }

    static var reuseID: String { String(describing: CellType.self) }

    func configure(cell: UIView) {
        guard let cell = cell as? CellType else { return }
        cell.configure(with: item)
    }

    func register(in tableView: UITableView) {
        tableView.register(CellType.self, forCellReuseIdentifier: Self.reuseID)
    }
}
