//
//  StorageManager.swift
//  Stocks
//
//  Created by Никита Гусев on 10.06.2021.
//

import Foundation
import CoreData

protocol IStorageManager: IUserStorage & IStockStorage {
}

protocol IUserStorage: class {
    func loadUser(user: UserStorageDto) -> Bool
    func addUser(user: UserStorageDto) -> Bool
}

protocol IStockStorage: class {
    var retrievedStocks: [PreviewStockDto] { get }
    
    func loadDefaultStocks()
    func loadRecentSearchedStocks()
    func loadFavouriteStocks()
    func addDefaultStock(stockDto: PreviewStockDto, to user: UserStorageDto)
    func addRecentSearchedStock(stockDto: PreviewStockDto)
    func addFavouriteStock(stockDto: PreviewStockDto)
    func removeStockFromFavourites(stockDto: PreviewStockDto)
    func isFavouriteStock(stockDto: PreviewStockDto) -> Bool
    func updateStockQuote(of ticker: String, price: Double, delta: Double)
    func checkIfStockFavourite(ticker: String) -> Bool
}

final class StorageManager: IStorageManager {
    private let persistentContainer: NSPersistentContainer
    private let mainContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    private var stocks = [Stock]()
    private var user: User?
    
    init() {
        self.persistentContainer = NSPersistentContainer(name: "Stocks")
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("\(description.description) \(error.localizedDescription)")
            }
        }
        self.mainContext = self.persistentContainer.viewContext
        self.backgroundContext = self.persistentContainer.newBackgroundContext()
    }
}

extension StorageManager: IUserStorage {
    func loadUser(user: UserStorageDto) -> Bool {
        guard let user = self.getUserIfExists(user: user) else { return false }
        self.user = user
        return true
    }
    
    func addUser(user: UserStorageDto) -> Bool {
        guard self.getUserIfExists(user: user) == nil else { return false }
        let newUser = User(context: mainContext)
        newUser.login = user.login
        try? self.mainContext.save()
        return true
    }
}

extension StorageManager: IStockStorage {
    var retrievedStocks: [PreviewStockDto] {
        return self.stocks.compactMap { stock in StockMapper.stockToPreview(stock) }
    }
    
    func loadDefaultStocks() {
        let predicate = NSPredicate(format: "\(#keyPath(Stock.isDefault)) = %@",
                                    NSNumber(booleanLiteral: true))
        self.loadStocks(with: predicate)
    }
    
    func loadRecentSearchedStocks() {
        let predicate = NSPredicate(format: "\(#keyPath(Stock.isRecent)) = %@",
                                    NSNumber(booleanLiteral: true))
        self.loadStocks(with: predicate)
    }
    
    func loadFavouriteStocks() {
        let predicate = NSPredicate(format: "\(#keyPath(Stock.isFavourite)) = %@",
                                    NSNumber(booleanLiteral: true))
        self.loadStocks(with: predicate)
    }
    
    func addDefaultStock(stockDto: PreviewStockDto, to user: UserStorageDto) {
        guard let user = self.getUserIfExists(user: user) else { return }
        if let existingStock = self.getStockIfExists(ticker: stockDto.ticker) {
            existingStock.isDefault = true
        } else {
            let newStock = self.createStock(using: stockDto)
            newStock.isDefault = true
            user.addToStocks(newStock)
        }
        try? self.mainContext.save()
    }
    
    func addRecentSearchedStock(stockDto: PreviewStockDto) {
        guard let user = self.user else { return }
        if let existingStock = self.getStockIfExists(ticker: stockDto.ticker) {
            existingStock.isRecent = true
        } else {
            let newStock = self.createStock(using: stockDto)
            newStock.isRecent = true
            user.addToStocks(newStock)
        }
        try? self.mainContext.save()
    }
    
    func addFavouriteStock(stockDto: PreviewStockDto) {
        guard let user = self.user else { return }
        if let existingStock = self.getStockIfExists(ticker: stockDto.ticker) {
            existingStock.isFavourite = true
        } else {
            let newStock = self.createStock(using: stockDto)
            newStock.isFavourite = true
            user.addToStocks(newStock)
        }
        try? self.mainContext.save()
    }
    
    func removeStockFromFavourites(stockDto: PreviewStockDto) {
        guard let user = self.user else { return }
        if let existingStock = self.getStockIfExists(ticker: stockDto.ticker) {
            existingStock.isFavourite = false
            if existingStock.isDefault == false
                && existingStock.isRecent == false {
                user.removeFromStocks(existingStock)
            }
        }
        try? self.mainContext.save()
    }
    
    func isFavouriteStock(stockDto: PreviewStockDto) -> Bool {
        if let existingStock = self.getStockIfExists(ticker: stockDto.ticker),
           existingStock.isFavourite {
            return true
        }
        return false
    }
    
    func updateStockQuote(of ticker: String, price: Double, delta: Double) {
        guard let stock = self.getStockIfExists(ticker: ticker) else { return }
        stock.price = price
        stock.delta = delta
        try? self.mainContext.save()
    }
    
    func checkIfStockFavourite(ticker: String) -> Bool {
        guard let stock = self.getStockIfExists(ticker: ticker) else { return false }
        return stock.isFavourite
    }
}

private extension StorageManager {
    func getUserIfExists(user: UserStorageDto) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(User.login)) = %@", user.login)
        let user = try? self.mainContext.fetch(request).first
        return user
    }
    
    func loadStocks(with predicate: NSPredicate) {
        guard let user = self.user else { return }
        guard let stocksSet = user.stocks?.filtered(using: predicate) as? Set<Stock> else {
            self.stocks = []
            return
        }
        self.stocks = stocksSet.sorted(by: {
            if let ticker1 = $0.ticker, let ticker2 = $1.ticker {
                return ticker1 < ticker2
            } else {
                return $0.price < $1.price
            }
        })
    }
    
    func getStockIfExists(ticker: String) -> Stock? {
        guard let user = self.user else { return nil }
        let stocks = user.stocks
        let tickerPredicate = NSPredicate(format: "\(#keyPath(Stock.ticker)) = %@", ticker)
        let stock = stocks?.filtered(using: tickerPredicate).first as? Stock
        return stock
    }
    
    func createStock(using stockDto: PreviewStockDto) -> Stock {
        let stock = Stock(context: self.mainContext)
        stock.ticker = stockDto.ticker
        stock.companyName = stockDto.companyName
        stock.logoUrl = stockDto.logoUrl
        stock.price = stockDto.price
        stock.delta = stockDto.delta
        return stock
    }
}
