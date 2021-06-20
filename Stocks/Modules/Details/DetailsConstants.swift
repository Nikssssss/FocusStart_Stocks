//
//  DetailsConstants.swift
//  Stocks
//
//  Created by Никита Гусев on 21.06.2021.
//

import Foundation
import UIKit

struct DetailsConstants {
    //MARK: DetailsView
    
    static let viewBackgroundColor = UIColor.white
    static let chartDaySegmentTitle = "День (ч.)"
    static let chartMonthSegmentTitle = "Месяц (д.)"
    static let chartYearSegmentTitle = "Год (м.)"
    
    //MARK: ChartView
    
    static let chartViewBackgroundColor = UIColor.white
    static let animationDuration: Double = 1
    static let chartYAxisFont = UIFont.boldSystemFont(ofSize: 12)
    static let chartYAxisLabelColor = UIColor.gray
    static let chartXAxisLineColor = UIColor.white
    static let chartLineWidth: CGFloat = 2
    static let chartLineColor = UIColor(red: 34 / 255.0,
                                        green: 128 / 255.0,
                                        blue: 59 / 255.0,
                                        alpha: 1.0)
    static let chartFillColor = UIColor(red: 34 / 255.0,
                                        green: 128 / 255.0,
                                        blue: 59 / 255.0,
                                        alpha: 1.0)
    static let chartFillAlpha: CGFloat = 0.2
    static let chartXLabelFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let chartXLabelTextColor = UIColor.darkGray
    
    //MARK: ChartStates
    
    static let yearChartWeekInterval: Double = 2
    static let monthChartDayInterval: Double = 2
    static let dayChartHourInterval: Double = 2
}
