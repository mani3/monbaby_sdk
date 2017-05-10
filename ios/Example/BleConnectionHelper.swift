//
//  BleConnectionHelper.swift
//  Example
//
//  Created by Kazuya Shida on 2017/05/11.
//  Copyright © 2017 mani3. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: -

/// Service UUID
fileprivate let ACCELEROMETER_SERVICE: String = "AA10"

/// Characteristic UUIDs
fileprivate let ACCELEROMETER_CONFIG: String = "AA12"
fileprivate let ACCELEROMETER_DATA14: String = "AA16"

fileprivate let VALUE_ENABLE_ACCELEROMETER: [UInt8] = [0x03]



// MARK: - BleConnectionHelper

class BleConnectionHelper: NSObject {

    fileprivate var centralManager: CBCentralManager!
    fileprivate var peripheral: CBPeripheral?

    var action: ((Acceleration) -> Void)?
    var identifier: String?

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func runBleConnection(identifier: String, action: ((Acceleration) -> Void)?) {
        self.identifier = identifier
        self.action = action
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func cancel() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }

    struct Acceleration {
        var x: Float
        var y: Float
        var z: Float

        init(bytes: Data) {
            /// Int16 is little-endian
            let xData = Data(bytes[0..<2].reversed()).to(type: Int16.self)
            let yData = Data(bytes[2..<4].reversed()).to(type: Int16.self)
            let zData = Data(bytes[4..<6].reversed()).to(type: Int16.self)
            x = Float(xData >> 2) / 4096
            y = Float(yData >> 2) / 4096
            z = Float(zData >> 2) / 4096
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BleConnectionHelper: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.lowercased().contains("monbaby") {
            if peripheral.identifier.uuidString == self.identifier {
                self.peripheral = peripheral
                centralManager.connect(peripheral, options: nil)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
}

// MARK: - CBPeripheralDelegate

extension BleConnectionHelper: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            NSLog(#function, error.localizedDescription)
            return
        }
        guard let services = peripheral.services, !services.isEmpty else {
            NSLog("No services")
            return
        }
        for service in services {
            if service.uuid.uuidString == ACCELEROMETER_SERVICE {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            NSLog(#function, error.localizedDescription)
            return
        }
        guard let characteristics = service.characteristics, !characteristics.isEmpty else {
            print("No characteristics")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid.uuidString == ACCELEROMETER_CONFIG {
                let data = Data(bytes: VALUE_ENABLE_ACCELEROMETER)
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
            if characteristic.uuid.uuidString == ACCELEROMETER_DATA14 {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.discoverDescriptors(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog(#function, error.localizedDescription)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog(#function, error.localizedDescription)
            return
        }
        guard let data = characteristic.value else {
            print("No characteristic value")
            return
        }
        if characteristic.uuid.uuidString == ACCELEROMETER_DATA14 {
            let acc = Acceleration(bytes: data)
            self.action?(acc)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog(#function, error.localizedDescription)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            NSLog(#function, error.localizedDescription)
        }
    }
}

// MARK: - Extensions

extension Data {
    init<T>(from value: T) {
        var v = value
        self.init(buffer: UnsafeBufferPointer(start: &v, count: 1))
    }

    init<T>(from values: [T]) {
        var v = values
        self.init(buffer: UnsafeBufferPointer(start: &v, count: v.count))
    }

    func to<T>(type: T.Type) -> T {
        return withUnsafeBytes { $0.pointee }
    }
}

extension Float {
    var bytes: Data {
        let data = Data(from: self)
        return data
    }
}

extension Int16 {
    var bytes: Data {
        let data = Data(from: self)
        return data
    }
}
