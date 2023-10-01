//
//  MobilePaymentApp.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/12.
//

import SwiftUI

@main
struct MobilePaymentApp: App {
    @StateObject var appData = ApplicationData()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(ApplicationData())

        }
    }
}
