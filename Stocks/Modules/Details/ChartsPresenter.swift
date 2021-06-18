//
//  DetailsPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 18.06.2021.
//

import Foundation
import class Charts.LineChartDataSet

enum ChartState {
    case year, month, day
}

protocol IChartsPresenter: class {
    func loadChartData(completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void))
    func getLeftLabelText() -> String
    func getMiddleLabelText() -> String
    func getRightLabelText() -> String
    func changeState(to state: ChartState)
}

protocol IChartsPresenterState: class {
    func loadChartData(completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void))
    func getLeftLabelText() -> String
    func getMiddleLabelText() -> String
    func getRightLabelText() -> String
}

final class ChartsPresenter: IChartsPresenter {
    private let networkManager: INetworkManager
    private let ticker: String
    private var chartsPresenterState: IChartsPresenterState
    
    init(networkManager: INetworkManager, ticker: String) {
        self.networkManager = networkManager
        self.ticker = ticker
        self.chartsPresenterState = DayChartsPresenterState(networkManager: networkManager,
                                                             ticker: ticker)
    }
    
    func loadChartData(completion: @escaping ((Result<LineChartDataSet, NetworkError>) -> Void)) {
        self.chartsPresenterState.loadChartData(completion: completion)
    }
    
    func getLeftLabelText() -> String {
        return self.chartsPresenterState.getLeftLabelText()
    }
    
    func getMiddleLabelText() -> String {
        return self.chartsPresenterState.getMiddleLabelText()
    }
    
    func getRightLabelText() -> String {
        return self.chartsPresenterState.getRightLabelText()
    }
    
    func changeState(to state: ChartState) {
        switch state {
        case .day:
            self.chartsPresenterState = DayChartsPresenterState(networkManager: self.networkManager,
                                                                ticker: self.ticker)
        case .month:
            self.chartsPresenterState = MonthChartsPresenterState(networkManager: self.networkManager,
                                                                ticker: self.ticker)
        case .year:
            self.chartsPresenterState = YearChartsPresenterState(networkManager: self.networkManager,
                                                                ticker: self.ticker)
        }
    }
}
