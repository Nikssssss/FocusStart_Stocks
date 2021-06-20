//
//  SearchConstants.swift
//  Stocks
//
//  Created by Никита Гусев on 21.06.2021.
//

import Foundation
import UIKit

struct SearchConstants {
    //MARK: SearchUI
    
    static let navigationBarTitle = "Поиск"
    static let searchBarPlaceholder = "Введите тикер или название компании"
    
    //MARK: SearchView
    
    static let viewBackgroundColor = UIColor.white
    
    //MARK: PresenterStates
    
    static let defaultStateHeaderTitle = "Популярные запросы"
    static let searchStateHeaderTitle = "Результаты поиска"
    static let recentStateHeaderTitle = "Недавние поиски"
}
