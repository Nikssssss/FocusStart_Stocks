//
//  ChartView.swift
//  Stocks
//
//  Created by Никита Гусев on 17.06.2021.
//

import UIKit
import Charts

class ChartView: LineChartView {
    var leftXLabelTextHandler: (() -> String)?
    var middleXLabelTextHandler: (() -> String)?
    var rightXLabelTextHandler: (() -> String)?
    
    private let leftXLabel = UILabel()
    private let middleXLabel = UILabel()
    private let rightXLabel = UILabel()
    
    func configureView() {
        self.configureXAxis()
        self.configureYAxis()
        self.configureCommonSettings()
        self.addSubviews()
        self.configureAxisLabels()
    }
    
    func setDataSet(_ dataset: LineChartDataSet) {
        self.configureDataset(dataset)
        
        let data = LineChartData(dataSet: dataset)
        data.setDrawValues(false)
        self.data = data
        
        self.animate(xAxisDuration: 1)
    }
    
    func reloadXLabels() {
        self.leftXLabel.text = self.leftXLabelTextHandler?()
        self.middleXLabel.text = self.middleXLabelTextHandler?()
        self.rightXLabel.text = self.rightXLabelTextHandler?()
    }
}

private extension ChartView {
    func configureXAxis() {
        self.xAxis.enabled = false
    }
    
    func configureYAxis() {
        let yAxis = self.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.labelTextColor = .gray
        yAxis.axisLineColor = .white
        yAxis.drawLimitLinesBehindDataEnabled = false
        yAxis.removeAllLimitLines()
    }
    
    func configureCommonSettings() {
        self.backgroundColor = .white
        self.legend.enabled = false
        self.rightAxis.enabled = false
        self.isUserInteractionEnabled = false
        self.noDataText = ""
    }
    
    func configureDataset(_ dataset: LineChartDataSet) {
        dataset.mode = .linear
        dataset.drawCirclesEnabled = false
        dataset.lineWidth = 2
        dataset.setColor(UIColor(red: 34 / 255.0, green: 128 / 255.0, blue: 59 / 255.0, alpha: 1.0))
        dataset.fill = ColorFill(color: UIColor(red: 34 / 255.0, green: 128 / 255.0, blue: 59 / 255.0, alpha: 1.0))
        dataset.fillAlpha = 0.2
        dataset.drawFilledEnabled = true
    }
    
    func addSubviews() {
        self.addSubview(self.leftXLabel)
        self.addSubview(self.middleXLabel)
        self.addSubview(self.rightXLabel)
    }
    
    func configureAxisLabels() {
        self.leftXLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(25)
        }
        self.configureLabel(self.leftXLabel)
        
        self.middleXLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(10)
            make.centerX.equalToSuperview().offset(10)
        }
        self.configureLabel(self.middleXLabel)
        
        self.rightXLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-5)
        }
        self.configureLabel(self.rightXLabel)
    }
    
    func configureLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkGray
    }
}
