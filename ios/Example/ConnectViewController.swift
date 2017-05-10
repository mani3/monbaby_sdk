//
//  ConnectViewController.swift
//  Example
//
//  Created by Kazuya Shida on 2017/05/11.
//  Copyright © 2017 mani3. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts

// MARK: - Const

fileprivate let MAX_LIMIT_Y: Double = 2.0
fileprivate let MIN_LIMIT_Y: Double = -2.0
fileprivate let NUMBER_OF_DISPLAYED_POINTS: Int = 100
fileprivate let X_AXIS_INDEX: Int = 0
fileprivate let Y_AXIS_INDEX: Int = 1
fileprivate let Z_AXIS_INDEX: Int = 2

// MARK: - ConnectViewController

class ConnectViewController: UIViewController {

    @IBOutlet weak var lineChartView: LineChartView!

    fileprivate var dataSets: [LineChartDataSet] = []
    fileprivate var connectionHelper = BleConnectionHelper()

    var identifier: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let data = LineChartData()
        data.addDataSet(createDataSet(color: UIColor.red, label: "X"))
        data.addDataSet(createDataSet(color: UIColor.green, label: "Y"))
        data.addDataSet(createDataSet(color: UIColor.blue, label: "Z"))

        self.lineChartView?.data = data
        self.lineChartView?.gridBackgroundColor = UIColor.white
        self.lineChartView?.pinchZoomEnabled = false
        self.lineChartView?.scaleXEnabled = false
        self.lineChartView?.scaleYEnabled = false
        self.lineChartView?.chartDescription?.text = "MonBaby Device"

        let leftAxis = self.lineChartView?.leftAxis
        leftAxis?.axisMaximum = 2.0
        leftAxis?.axisMinimum = -2.0

        let rightAxis = self.lineChartView?.rightAxis
        rightAxis?.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let id = identifier {
            connectionHelper.runBleConnection(identifier: id) { [weak self] (acc) in
                guard let data = self?.lineChartView.data else { return }
                let xSet = data.dataSets[X_AXIS_INDEX]
                let ySet = data.dataSets[Y_AXIS_INDEX]
                let zSet = data.dataSets[Z_AXIS_INDEX]
                if xSet.entryCount > NUMBER_OF_DISPLAYED_POINTS {
                    if !xSet.removeFirst() {}
                }
                if ySet.entryCount > NUMBER_OF_DISPLAYED_POINTS {
                    if !ySet.removeFirst() {}
                }
                if zSet.entryCount > NUMBER_OF_DISPLAYED_POINTS {
                    if !zSet.removeFirst() {}
                }
                if xSet.addEntry(ChartDataEntry(x: Double(max(0, xSet.xMax) + 1), y: Double(acc.x)))
                    && ySet.addEntry(ChartDataEntry(x: Double(max(0, xSet.xMax) + 1), y: Double(acc.y)))
                    && zSet.addEntry(ChartDataEntry(x: Double(max(0, xSet.xMax) + 1), y: Double(acc.z))) {
                }
                data.notifyDataChanged()
                self?.lineChartView.notifyDataSetChanged()
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        connectionHelper.cancel()
    }

    func createDataSet(values: [ChartDataEntry] = [], color: UIColor, label: String) -> LineChartDataSet {
        let dataSet = LineChartDataSet(values: values, label: label)
        dataSet.colors = [color]
        dataSet.drawCirclesEnabled = false
        return dataSet
    }
}
