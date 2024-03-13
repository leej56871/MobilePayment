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
    @StateObject var merchantData = MerchantData()
    @StateObject var socketSession = SocketSession()
    @StateObject var updateView = UpdateView()
    @StateObject var localNotificationManager = LocalNotificationManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
                .environmentObject(merchantData)
                .environmentObject(socketSession)
                .environmentObject(updateView)
                .environmentObject(localNotificationManager)
        }
    }
}
