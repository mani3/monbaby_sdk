//
//  BleScanHelper.swift
//  Example
//
//  Created by Kazuya Shida on 2017/05/10.
//  Copyright © 2017 mani3. All rights reserved.
//

import CoreBluetooth
import RxSwift
import RxCocoa

@objc protocol BleScanHelperDelegate: class {
    @objc optional func didConnect(peripheral: CBPeripheral)
    @objc optional func didStopScan()
}

class BleScanHelper: NSObject {

    fileprivate static let BLE_SCAN_TIMEOUT: Int = 10 // seconds
    fileprivate var centralManager: CBCentralManager!

    weak var delegate: BleScanHelperDelegate?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan(timeout: Int = BleScanHelper.BLE_SCAN_TIMEOUT) {
        centralManager.scanForPeripherals(withServices: nil, options: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(timeout)) { [weak self] in
            self?.centralManager.stopScan()
            self?.delegate?.didStopScan?()
        }
    }

    var isScanning: Bool {
        return centralManager.isScanning
    }
}

// MARK: - CBCentralManagerDelegate

extension BleScanHelper: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state.rawValue)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.lowercased().contains("monbaby") {
            self.delegate?.didConnect?(peripheral: peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
}
