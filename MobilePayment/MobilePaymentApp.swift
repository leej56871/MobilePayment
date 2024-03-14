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
    @State var connection: Bool = false
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
                .environmentObject(merchantData)
                .environmentObject(socketSession)
                .environmentObject(updateView)
                .environmentObject(localNotificationManager)
                .onAppear(perform: {
                    NotificationCenter.default.addObserver(forName: Notification.Name("No Connection"), object: nil, queue: nil, using: {
                        notification in
                        connection = true
                    })
                }).alert("Lost connection from server!", isPresented: $connection, actions: {
                    Button(action: {
                        exit(0)
                    }, label: {
                        Text("Quit app")
                    })
                })
            
        }
    }
}
