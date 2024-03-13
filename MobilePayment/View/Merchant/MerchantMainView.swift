//
//  MerchantMainView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/8/24.
//

import SwiftUI

struct MerchantMainView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var merchantData: MerchantData
    @EnvironmentObject private var socketSession: SocketSession
    @State var observer: NSObjectProtocol?
    @State var firstLogin: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Merchant Mode")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Welcome \(appData.userInfo.name)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Text("\(appData.userInfo.balance) HKD")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                NavigationLink(destination: MerchantTargetView(), label: {
                    Text("Generate QR Code")
                        .font(.title)
                })
                Spacer()
            }
        }.padding()
            .customToolBar(currentState: "home", isMerchant: appData.userInfo.isMerchant)
            .onAppear(perform: {
                if firstLogin {
                    socketSession.sendMessage(message: "id:\(appData.userInfo.userID)")
                    firstLogin = false
                }
                let HTTPSession = HTTPSession()
                HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                    notification in
                    let info = notification.object as! [String: Any]
                    merchantData.updateMenu(menuList: info["itemList"] as! [String])
                    NotificationCenter.default.removeObserver(observer)
                })
            })
    }
}
