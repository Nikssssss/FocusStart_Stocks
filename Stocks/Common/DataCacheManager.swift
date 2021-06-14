//
//  DataCacher.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import Foundation

protocol IDataCacheManager: class {
    func saveData(_ data: Data, for key: String)
    func removeData(from key: String)
    func getData(from ket: String) -> Data?
}

final class DataFileManager: IDataCacheManager {
    private let fileManager = FileManager.default
    
    func saveData(_ data: Data, for key: String) {
        guard let fileUrl = self.makeURL(forFileNamed: key)
        else { return }
        if self.fileManager.fileExists(atPath: fileUrl.path) == false {
            print(self.fileManager.createFile(atPath: fileUrl.path, contents: data))
        } else {
            try? "".write(to: fileUrl, atomically: true, encoding: .utf8)
            try? data.write(to: fileUrl)
        }
    }
    
    func removeData(from key: String) {
        guard let fileUrl = self.makeURL(forFileNamed: key),
              self.fileManager.fileExists(atPath: fileUrl.path)
        else { return }
        try? self.fileManager.removeItem(at: fileUrl)
    }
    
    func getData(from key: String) -> Data? {
        guard let fileUrl = self.makeURL(forFileNamed: key),
              self.fileManager.fileExists(atPath: fileUrl.path)
        else { return nil }
        return try? Data(contentsOf: fileUrl)
    }
    
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .cachesDirectory,
                                         in: .userDomainMask).first
        else { return nil }
        return url.appendingPathComponent(fileName)
    }
}
