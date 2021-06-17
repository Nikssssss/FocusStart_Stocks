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
            guard let self = self else { return }
            switch chartResult {
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
                    day += 2
                }
                let chartDataset = LineChartDataSet(entries: chartEntries)
                completion(.success(chartDataset))
            }
        }
    }
    
    func getLeftLabelText() -> String {
        guard let monthAgoDate = Calendar.current.date(byAdding: .month,
                                                       value: -1,
                                                       to: Date())
        else { return "" }
        return String(Calendar.current.component(.day, from: monthAgoDate))
    }
    
    func getMiddleLabelText() -> String {
        guard let halfMonthAgoDate = Calendar.current.date(byAdding: .day,
                                                           value: -15,
                                                           to: Date())
        else { return "" }
        return String(Calendar.current.component(.day, from: halfMonthAgoDate))
    }
    
    func getRightLabelText() -> String {
        return String(Calendar.current.component(.day, from: Date()))
    }
}

