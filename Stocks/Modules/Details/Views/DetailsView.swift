//
//  DetailsView.swift
//  Stocks
//
//  Created by Никита Гусев on 17.06.2021.
//

import UIKit
import class Charts.LineChartDataSet

class DetailsView: UIView {
    var dayChartTapHandler: (() -> Void)?
    var monthChartTapHandler: (() -> Void)?
    var yearChartTapHandler: (() -> Void)?
    
    private let chartTypeSegmentedControl = UISegmentedControl()
    private let chartView = ChartView()
    
    func configureView() {
        self.backgroundColor = .white
        self.addSubviews()
        self.configureChartSegmentedControl()
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
    func addSubviews() {
        self.addSubview(self.chartTypeSegmentedControl)
        self.addSubview(self.chartView)
    }
    
    func configureChartSegmentedControl() {
        self.chartTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        self.chartTypeSegmentedControl.insertSegment(action: UIAction(handler: self.dayChartTapped(_:)),
                                                     at: 0, animated: true)
        self.chartTypeSegmentedControl.insertSegment(action: UIAction(handler: self.monthChartTapped(_:)),
                                                     at: 1, animated: true)
        self.chartTypeSegmentedControl.insertSegment(action: UIAction(handler: self.yearChartTapped(_:)),
                                                     at: 2, animated: true)
        self.chartTypeSegmentedControl.setTitle("День (ч.)", forSegmentAt: 0)
        self.chartTypeSegmentedControl.setTitle("Месяц (д.)", forSegmentAt: 1)
        self.chartTypeSegmentedControl.setTitle("Год (м.)", forSegmentAt: 2)
        self.chartTypeSegmentedControl.selectedSegmentIndex = 0
    }
    
    func configureChartView() {
        self.chartView.configureView()
        self.chartView.snp.makeConstraints { make in
            make.top.equalTo(self.chartTypeSegmentedControl.snp.bottom).offset(20)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(350)
        }
    }
    
    func dayChartTapped(_ action: UIAction) -> Void {
        self.dayChartTapHandler?()
    }
    
    func monthChartTapped(_ action: UIAction) {
        self.monthChartTapHandler?()
    }
    
    func yearChartTapped(_ action: UIAction) {
        self.yearChartTapHandler?()
    }
}
