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
    @State var logout: Bool = false
    @State var turnOff: Bool = false
    
    var body: some View {
        VStack {
        HStack {
            Button(action: {
                logout = true
            }, label: {
                Text("Log out")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            })
            Spacer()
            Button(action: {
                turnOff = true
            }, label: {
                Image(systemName: "power.circle")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
            })
        }.padding()
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
            }
        }.padding()
            .alert(logout ? "Logout?" : "Turn off the app?", isPresented: logout ? $logout : $turnOff, actions: {
                Button(role: .cancel, action: {
                    logout ? logout.toggle() : turnOff.toggle()
                }, label: {
                    Text("No")
                })
                Button(action: {
                    socketSession.sendMessage(message: "logout:\(appData.userInfo.userID)")
                    if logout {
                        appData.userInfo.logInStatus = 1
                    } else {
                        exit(0)
                    }
                }, label: {
                    Text("Yes")
                })
            })
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
