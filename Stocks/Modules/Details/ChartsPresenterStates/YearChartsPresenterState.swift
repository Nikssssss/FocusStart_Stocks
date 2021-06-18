//
//  YearChartsPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 18.06.2021.
//

import Foundation
import class Charts.ChartDataEntry
import class Charts.LineChartDataSet

final class YearChartsPresenterState: IChartsPresenterState {
    private let networkManager: INetworkManager
    private let ticker: String
    
    init(networkManager: INetworkManager, ticker: String) {
        self.networkManager = networkManager
        self.ticker = ticker
    }
    
    func loadChartData(completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void)) {
        let currentDate = Date()
        guard let yearAgoDate = Calendar.current.date(byAdding: .year,
                                                value: -1,
                                                to: currentDate)
        else { return }
        let currentDateTime = Int64(currentDate.timeIntervalSince1970)
        let yearAgoTime = Int64(yearAgoDate.timeIntervalSince1970)
        self.networkManager.loadYearChartData(for: ticker,
                                          from: yearAgoTime,
                                          to: currentDateTime) { [weak self] chartResult in
            self?.handleChartResult(chartResult, completion: completion)
        }
    }
    
    func getLeftLabelText() -> String {
        guard let yearAgoDate = Calendar.current.date(byAdding: .year,
                                                value: -1,
                                                to: Date())
        else { return "" }
        return String(Calendar.current.component(.month, from: yearAgoDate))
    }
    
    func getMiddleLabelText() -> String {
        guard let yearAgoDate = Calendar.current.date(byAdding: .month,
                                                value: -6,
                                                to: Date())
        else { return "" }
        return String(Calendar.current.component(.month, from: yearAgoDate))
    }
    
    func getRightLabelText() -> String {
        return String(Calendar.current.component(.month, from: Date()))
    }
    
    private func handleChartResult(_ result: Result<ChartDto?, NetworkError>,
                                   completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void)) {
        switch result {
        case .failure(let error):
            completion(.failure(error))
        case .success(let chartDto):
            guard let chartDto = chartDto,
                  chartDto.prices.count == chartDto.datestamps.count
            else { return }
            var chartEntries = [ChartDataEntry]()
            var week: Double = 1
            for index in 0..<chartDto.prices.count {
                chartEntries.append(ChartDataEntry(x: week,
                                                   y: chartDto.prices[index]))
                week += 2
            }
            let chartDataset = LineChartDataSet(entries: chartEntries)
            completion(.success(chartDataset))
        }
    }
}
