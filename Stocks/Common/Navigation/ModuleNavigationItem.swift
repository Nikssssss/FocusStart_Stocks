//
//  ModuleNavigationItem.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation
import class UIKit.UIViewController

enum TabItemTag {
    case search, favourites
}

struct ModuleNavigationItem {
    let viewController: UIViewController
    let tabItemTag: TabItemTag?
}
