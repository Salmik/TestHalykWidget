//
//  ViewController.swift
//  TestWidget
//
//  Created by Zhanibek Lukpanov on 25.07.2024.
//

import UIKit
import HalykWidget

class ViewController: UIViewController {

    private let tableView = UITableView()
    private var configurators: [CellConfigurator] = []

    private var processes: [Processes] = [] {
        didSet {
            configurators = processes.map(convert)
            configurators.forEach { $0.register(in: tableView) }
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Halyk Widget"
        view.backgroundColor = .white

        view.addSubview(tableView)
        tableView.constraintToEdges(of: view, safe: true)
        stylyze()
        setActions()
    }

    private func stylyze() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = 56
    }

    private func setActions() {
        tableView.delegate = self
        tableView.dataSource = self

        CommonInformation.shared.setPartnersInfo(login: "gbdq", password: "1234") { [weak self] processes in
            guard let processes else { return }
            self?.processes = processes
            self?.showHalykWidgetPage(with: "https://baas-test.halykbank.kz/auth")
        }
    }

    private func showHalykWidgetPage(with url: String) {
        let controller = HalykWidgetController(url: url)
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true) { [weak self] in self?.modalPresentationStyle = .automatic }
    }

    private func convert(_ processes: Processes) -> CellConfigurator {
        return TableCellConfigurator<BaseCell, Processes>(item: processes)
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { configurators.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configurator = configurators[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configurator).reuseID, for: indexPath)
        configurator.configure(cell: cell)
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = processes[indexPath.row].link else { return }
        showHalykWidgetPage(with: url)
    }
}
