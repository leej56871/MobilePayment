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
    @State var currentRespondedDict: [String: String] = [:]
    @State var currentInvitationMessage: String = ""
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
                .environmentObject(merchantData)
                .environmentObject(socketSession)
                .environmentObject(updateView)
                .environmentObject(localNotificationManager)
                .onAppear(perform: {
                    NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil, using: {
                        notification in
                        if currentInvitationMessage != "" {
                            for i in currentRespondedDict.keys {
                                socketSession.sendMessage(message: "deleteRoom:\(appData.userInfo.userID):\(i):\(currentInvitationMessage)")
                            }
                        }
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("No Connection"), object: nil, queue: nil, using: {
                        notification in
                        connection = true
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                        notification in
                        appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("gotInvite"), object: nil, queue: nil, using: {
                        notification in
                        let HTTPSession = HTTPSession()
                        HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                        NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                            notification in
                            appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                            updateView.updateView()
                        })
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("updateCurrentInvitationDict"), object: nil, queue: nil, using: {
                        notification in
                        currentRespondedDict = notification.object as! [String: String]
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("updateCurrentInvitationMessage"), object: nil, queue: nil, using: {
                        notification in
                        currentInvitationMessage = notification.object as! String
                    })
                    updateView.updateView()
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
