//
//  DeltaCounter.swift
//  Stocks
//
//  Created by Никита Гусев on 10.06.2021.
//

import Foundation

final class DeltaCounter {
    static func countDelta(openPrice: Double, currentPrice: Double) -> Double {
        return currentPrice - openPrice
    }
}
