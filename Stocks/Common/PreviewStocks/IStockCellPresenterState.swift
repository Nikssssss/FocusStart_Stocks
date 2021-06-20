//
//  IStockCellPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

protocol IStockCellPresenterState: class {
    func getNumberOfRows() -> Int
    func loadStocks(completion: @escaping ((Error?) -> Void))
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void))
    func titleForHeader() -> String
    func getStock(at row: Int) -> PreviewStockDto?
    func loadLogoImageData(using stock: PreviewStockDto, completion: @escaping ((Data?) -> Void))
    func refreshStocks(completion: @escaping ((Error?) -> Void))
    func stockPressed(stock: PreviewStockDto)
}
