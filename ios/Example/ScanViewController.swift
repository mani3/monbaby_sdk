//
//  ScanViewController.swift
//  Example
//
//  Created by Kazuya Shida on 2017/05/10.
//  Copyright © 2017 mani3. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa

class ScanViewController: UIViewController {
    let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    fileprivate var scanHelper: BleScanHelper!
    fileprivate var peripherals = Variable<[CBPeripheral]>([])

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(scan), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        peripherals.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { (_, item: CBPeripheral, cell) in
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.identifier.uuidString
            }
            .addDisposableTo(disposeBag)

        tableView.addSubview(refreshControl)
        tableView.rx
            .modelSelected(CBPeripheral.self)
            .subscribe(onNext: { (peripheral) in
                self.performSegue(withIdentifier: "Connect", sender: peripheral)
            })
            .addDisposableTo(disposeBag)

        scanHelper = BleScanHelper()
        scanHelper.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /// Start scan
        refreshControl.beginRefreshing()
        tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y - refreshControl.frame.height), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.refreshControl.sendActions(for: .valueChanged)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func scan() {
        if !scanHelper.isScanning {
            scanHelper.startScan()
        } else {
            refreshControl.endRefreshing()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ConnectViewController,
            let peripheral = sender as? CBPeripheral {
            viewController.identifier = peripheral.identifier.uuidString
        }
    }
}

// MARK: - BleScanHelperDelegate

extension ScanViewController: BleScanHelperDelegate {

    func didConnect(peripheral: CBPeripheral) {
        if peripherals.value.filter({ $0 == peripheral }).isEmpty {
            peripherals.value.append(peripheral)
        }
    }

    func didStopScan() {
        refreshControl.endRefreshing()
    }
}
