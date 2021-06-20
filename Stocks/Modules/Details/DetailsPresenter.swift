//
//  DetailsPresenter.swift
//  Stocks
//
//  Created by Никита Гусев on 17.06.2021.
//

import Foundation

protocol IDetailsPresenter: class {
    func loadView()
    func viewDidLoad()
}

final class DetailsPresenter: IDetailsPresenter {
    private let previewStock: PreviewStockDto
    private weak var detailsUI: IDetailsUI?
    private let navigator: INavigator
    private let chartsPresenter: IChartsPresenter
    
    init(detailsUI: IDetailsUI,
         previewStock: PreviewStockDto,
         navigator: INavigator,
         chartsPresenter: IChartsPresenter) {
        self.detailsUI = detailsUI
        self.previewStock = previewStock
        self.navigator = navigator
        self.chartsPresenter = chartsPresenter
    }
    
    func loadView() {
        self.detailsUI?.replaceScreenView()
    }
    
    func viewDidLoad() {
        self.detailsUI?.configureUI(with: previewStock.ticker)
        self.hookUI()
        self.handleLoadingChartData()
    }
}

private extension DetailsPresenter {
    func hookUI() {
        self.hookChartLeftLabelHandler()
        self.hookChartMiddleLabelHandler()
        self.hookChartRightLabelHandler()
        self.hookDayChartTapHandler()
        self.hookMonthChartTapHandler()
        self.hookYearChartTapHandler()
    }
    
    func hookChartLeftLabelHandler() {
        self.detailsUI?.setChartLeftLabelHandler { [weak self] in
            return self?.chartsPresenter.getLeftLabelText() ?? ""
        }
    }
    
    func hookChartMiddleLabelHandler() {
        self.detailsUI?.setChartMiddleLabelHandler { [weak self] in
            return self?.chartsPresenter.getMiddleLabelText() ?? ""
        }
    }
    
    func hookChartRightLabelHandler() {
        self.detailsUI?.setChartRightLabelHandler { [weak self] in
            return self?.chartsPresenter.getRightLabelText() ?? ""
        }
    }
    
    func hookDayChartTapHandler() {
        self.detailsUI?.setDayChartTapHandler { [weak self] in
            guard let self = self else { return }
            self.chartsPresenter.changeState(to: .day)
            self.handleLoadingChartData()
        }
    }
    
    func hookMonthChartTapHandler() {
        self.detailsUI?.setMonthChartTapHandler { [weak self] in
            guard let self = self else { return }
            self.chartsPresenter.changeState(to: .month)
            self.handleLoadingChartData()
        }
    }
    
    func hookYearChartTapHandler() {
        self.detailsUI?.setYearChartTapHandler { [weak self] in
            guard let self = self else { return }
            self.chartsPresenter.changeState(to: .year)
            self.handleLoadingChartData()
        }
    }
    
    func handleLoadingChartData() {
        self.chartsPresenter.loadChartData { [weak self] chartResult in
            guard let self = self else { return }
            switch chartResult {
            case .failure(let message):
                if message == .limitExceeded {
                    self.navigator.errorOccured(with: AlertMessages.limitExcessMessage)
                } else {
                    self.navigator.errorOccured(with: AlertMessages.noChartDataMessage)
                }
            case .success(let dataset):
                self.detailsUI?.setChartDataSet(dataset)
                self.detailsUI?.reloadChartLabelsText()
            }
        }
    }
}
