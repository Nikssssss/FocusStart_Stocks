//
//  DetailsUI.swift
//  Stocks
//
//  Created by Никита Гусев on 17.06.2021.
//

import UIKit
import class Charts.LineChartDataSet

protocol IDetailsUI: class {
    func replaceScreenView()
    func configureUI(with ticker: String)
    func setChartDataSet(_ dataset: LineChartDataSet)
    func setChartLeftLabelHandler(_ handler: @escaping (() -> String))
    func setChartMiddleLabelHandler(_ handler: @escaping (() -> String))
    func setChartRightLabelHandler(_ handler: @escaping (() -> String))
    func setDayChartTapHandler(_ handler: @escaping (() -> Void))
    func setMonthChartTapHandler(_ handler: @escaping (() -> Void))
    func setYearChartTapHandler(_ handler: @escaping (() -> Void))
    func reloadChartLabelsText()
}

class DetailsUI: UIViewController {
    private let detailsView = DetailsView()
    private var presenter: IDetailsPresenter?
    
    func setPresenter(_ presenter: IDetailsPresenter) {
        self.presenter = presenter
    }
    
    override func loadView() {
        super.loadView()
        
        self.presenter?.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter?.viewDidLoad()
    }
}

extension DetailsUI: IDetailsUI {
    func replaceScreenView() {
        self.view = self.detailsView
    }
    
    func configureUI(with ticker: String) {
        self.configureNavigationBar(with: ticker)
        self.detailsView.configureView()
    }
    
    func setChartDataSet(_ dataset: LineChartDataSet) {
        self.detailsView.setChartDataSet(dataset)
    }
    
    func setChartLeftLabelHandler(_ handler: @escaping (() -> String)) {
        self.detailsView.setChartLeftLabelHandler(handler)
    }
    
    func setChartMiddleLabelHandler(_ handler: @escaping (() -> String)) {
        self.detailsView.setChartMiddleLabelHandler(handler)
    }
    
    func setChartRightLabelHandler(_ handler: @escaping (() -> String)) {
        self.detailsView.setChartRightLabelHandler(handler)
    }
    
    func setDayChartTapHandler(_ handler: @escaping (() -> Void)) {
        self.detailsView.dayChartTapHandler = handler
    }
    
    func setMonthChartTapHandler(_ handler: @escaping (() -> Void)) {
        self.detailsView.monthChartTapHandler = handler
    }
    
    func setYearChartTapHandler(_ handler: @escaping (() -> Void)) {
        self.detailsView.yearChartTapHandler = handler
    }
    
    func reloadChartLabelsText() {
        self.detailsView.reloadChartLabelsText()
    }
}

private extension DetailsUI {
    func configureNavigationBar(with ticker: String) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.title = ticker
    }
}
