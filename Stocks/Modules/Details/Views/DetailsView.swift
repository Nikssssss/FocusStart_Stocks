//
//  DetailsView.swift
//  Stocks
//
//  Created by Никита Гусев on 17.06.2021.
//

import UIKit
import class Charts.LineChartDataSet

class DetailsView: UIView {
    private let chartView = ChartView()
    
    func configureView() {
        self.backgroundColor = .white
        self.configureChartView()
    }
    
    func setChartDataSet(_ dataset: LineChartDataSet) {
        self.chartView.setDataSet(dataset)
    }
    
    func setChartLeftLabelHandler(_ handler: @escaping (() -> String)) {
        self.chartView.leftXLabelTextHandler = handler
    }
    
    func setChartMiddleLabelHandler(_ handler: @escaping (() -> String)) {
        self.chartView.middleXLabelTextHandler = handler
    }
    
    func setChartRightLabelHandler(_ handler: @escaping (() -> String)) {
        self.chartView.rightXLabelTextHandler = handler
    }
    
    func reloadChartLabelsText() {
        self.chartView.reloadXLabels()
    }
}

private extension DetailsView {
    func configureChartView() {
        self.addSubview(self.chartView)
        self.chartView.configureView()
        self.chartView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(350)
        }
    }
}
