//
//  MerchantItemData.swift
//  MobilePayment
//
//  Created by 이주환 on 2/8/24.
//

import SwiftUI

class MerchantData: ObservableObject {
    @Published var merchantReceipt: merchantReceipt
    @Published var merchantMenu: merchantMenu
    init() {
        self.merchantReceipt = MobilePayment.merchantReceipt()
        self.merchantMenu = MobilePayment.merchantMenu()
    }
    
    func updateMenu(menuList: [String]) -> Void {
        var newMenuList: [merchantItem] = []
        for item in menuList {
            newMenuList.append(merchantItem(name: String(item.split(separator: "#").first!), price: Int(item.split(separator: "#").last!)!))
        }
        merchantMenu.menu = newMenuList
    }
    func returnMenuAsList() -> [String] {
        var menuList: [String] = []
        for item in merchantMenu.menu {
            menuList.append(String(item.name) + "#" + String(item.price))
        }
        return menuList
    }
}

struct merchantReceipt {
    var receipt: [merchantItem] = []
    var totalPrice: Int = 0
}

struct merchantMenu {
    var menu: [merchantItem] = []
}

struct merchantItem: Identifiable, Hashable, Equatable {
    var id = UUID()
    var name: String
    var price: Int
    
    func getName() -> String {
        return name
    }
}
