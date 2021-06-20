//
//  MonthChartsPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 18.06.2021.
//

import Foundation
import class Charts.ChartDataEntry
import class Charts.LineChartDataSet

final class MonthChartsPresenterState: IChartsPresenterState {
    private let networkManager: INetworkManager
    private let ticker: String
    
    init(networkManager: INetworkManager, ticker: String) {
        self.networkManager = networkManager
        self.ticker = ticker
    }
    
    func loadChartData(completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void)) {
        let currentDate = Date()
        guard let monthAgoDate = Calendar.current.date(byAdding: .month,
                                                       value: -1,
                                                       to: currentDate)
        else { return }
        let currentDateTime = Int64(currentDate.timeIntervalSince1970)
        let monthAgoTime = Int64(monthAgoDate.timeIntervalSince1970)
        self.networkManager.loadMonthChartData(for: ticker,
                                               from: monthAgoTime,
                                               to: currentDateTime) { [weak self] chartResult in
            self?.handleChartResult(chartResult, completion: completion)
        }
    }
    
    func getLeftLabelText() -> String {
        guard let monthAgoDate = Calendar.current.date(byAdding: .month,
                                                       value: -1,
                                                       to: Date())
        else { return String() }
        return String(Calendar.current.component(.day, from: monthAgoDate))
    }
    
    func getMiddleLabelText() -> String {
        guard let halfMonthAgoDate = Calendar.current.date(byAdding: .day,
                                                           value: -15,
                                                           to: Date())
        else { return String() }
        return String(Calendar.current.component(.day, from: halfMonthAgoDate))
    }
    
    func getRightLabelText() -> String {
        return String(Calendar.current.component(.day, from: Date()))
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
            var day: Double = 1
            for index in 0..<chartDto.prices.count {
                chartEntries.append(ChartDataEntry(x: day,
                                                   y: chartDto.prices[index]))
                day += DetailsConstants.monthChartDayInterval
            }
            let chartDataset = LineChartDataSet(entries: chartEntries)
            completion(.success(chartDataset))
        }
    }
}

