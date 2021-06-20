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
        
        self.animate(xAxisDuration: DetailsConstants.animationDuration)
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
        yAxis.labelFont = DetailsConstants.chartYAxisFont
        yAxis.labelTextColor = DetailsConstants.chartYAxisLabelColor
        yAxis.axisLineColor = DetailsConstants.chartXAxisLineColor
        yAxis.drawLimitLinesBehindDataEnabled = false
        yAxis.removeAllLimitLines()
    }
    
    func configureCommonSettings() {
        self.backgroundColor = DetailsConstants.chartViewBackgroundColor
        self.legend.enabled = false
        self.rightAxis.enabled = false
        self.isUserInteractionEnabled = false
        self.noDataText = String()
    }
    
    func configureDataset(_ dataset: LineChartDataSet) {
        dataset.mode = .linear
        dataset.drawCirclesEnabled = false
        dataset.lineWidth = DetailsConstants.chartLineWidth
        dataset.setColor(DetailsConstants.chartLineColor)
        dataset.fill = ColorFill(color: DetailsConstants.chartFillColor)
        dataset.fillAlpha = DetailsConstants.chartFillAlpha
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
        label.font = DetailsConstants.chartXLabelFont
        label.textColor = DetailsConstants.chartXLabelTextColor
    }
}
