//
//  PreviewConstants.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation
import UIKit

struct PreviewConstants {
    //MARK: StockTableViewCell
    
    static let cellIdentifier = "StockTableViewCell"
    static let cellInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    static let cellCornerRadius: CGFloat = 10
    static let cellLogoImageCornerRadius: CGFloat = 10
    static let cellHeight: CGFloat = 70
    
    static let cellTickerFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    static let cellCompanyFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
    static let cellPriceFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    static let cellDeltaFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
    
    static let cellTickerTextColor = UIColor.black
    static let cellCompanyTextColor = UIColor.black
    static let cellPriceTextColor = UIColor.black
    static let cellDeltaPositiveColor = UIColor(red: 35 / 255.0,
                                                green: 175 / 255.0,
                                                blue: 86 / 255.0,
                                                alpha: 1.0)
    static let cellNegativeDeltaColor = UIColor.red
    static let cellIsFavouriteColor = UIColor(red: 255 / 255.0,
                                          green: 202 / 255.0,
                                          blue: 28 / 255.0,
                                          alpha: 1.0)
    static let cellIsNotFavouriteColor = UIColor.lightGray
    static let cellEvenBackgroundColor = UIColor(red: 240.0 / 255,
                                                 green: 240.0 / 255,
                                                 blue: 240.0 / 255,
                                                 alpha: 1.0)
    static let cellOddBackgroundColor = UIColor.white
    
    static let cellFavouriteImageName = "star.fill"
    
    //MARK: PreviewStocksTableView
    
    static let tableBackgroundColor = UIColor.white
    static let tableHeaderColor = UIColor.white
    static let tableHeaderFont = UIFont.systemFont(ofSize: 13, weight: .bold)
    static let tableHeaderHeight: CGFloat = 30
    
    //MARK: StockCellPresenter
    
    static let dollarCurrency = "$"
    static let positiveChange = "+"
}
