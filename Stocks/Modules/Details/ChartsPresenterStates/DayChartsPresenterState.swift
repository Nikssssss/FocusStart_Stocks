//
//  DayChartsPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 18.06.2021.
//

import Foundation
import class Charts.ChartDataEntry
import class Charts.LineChartDataSet

final class DayChartsPresenterState: IChartsPresenterState {
    private let networkManager: INetworkManager
    private let ticker: String
    
    init(networkManager: INetworkManager, ticker: String) {
        self.networkManager = networkManager
        self.ticker = ticker
    }
    
    func loadChartData(completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void)) {
        let currentDate = Date()
        guard let dayAgoDate = Calendar.current.date(byAdding: .hour,
                                                       value: -24,
                                                       to: currentDate)
        else { return }
        let currentDateTime = Int64(currentDate.timeIntervalSince1970)
        let dayAgoTime = Int64(dayAgoDate.timeIntervalSince1970)
        self.networkManager.loadDayChartData(for: ticker,
                                               from: dayAgoTime,
                                               to: currentDateTime) { [weak self] chartResult in
            self?.handleChartResult(chartResult, completion: completion)
        }
    }
    
    func getLeftLabelText() -> String {
        guard let dayAgoDate = Calendar.current.date(byAdding: .hour,
                                                       value: -24,
                                                       to: Date())
        else { return String() }
        return String(Calendar.current.component(.hour, from: dayAgoDate))
    }
    
    func getMiddleLabelText() -> String {
        guard let halfDayAgoDate = Calendar.current.date(byAdding: .hour,
                                                       value: -12,
                                                       to: Date())
        else { return String() }
        return String(Calendar.current.component(.hour, from: halfDayAgoDate))
    }
    
    func getRightLabelText() -> String {
        return String(Calendar.current.component(.hour, from: Date()))
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
            var hour: Double = 1
            for index in 0..<chartDto.prices.count {
                chartEntries.append(ChartDataEntry(x: hour,
                                                   y: chartDto.prices[index]))
                hour += DetailsConstants.dayChartHourInterval
            }
            let chartDataset = LineChartDataSet(entries: chartEntries)
            completion(.success(chartDataset))
        }
    }
}
