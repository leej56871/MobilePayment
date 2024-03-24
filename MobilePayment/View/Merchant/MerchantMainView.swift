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
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                HStack {
                    Button(action: {
                        logout = true
                    }, label: {
                        Text("Log out")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }).padding()
                        .customBorder(clipShape: "capsule", color: Color.duck_orange, radius: 5, borderColor: Color.duck_orange)
                    Spacer()
                    Button(action: {
                        turnOff = true
                    }, label: {
                        Image(systemName: "power.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                    }).padding()
                        .customBorder(clipShape: "capsule", color: Color.duck_orange, radius: 5, borderColor: Color.duck_orange)
                }.padding()
                NavigationStack {
                    VStack {
                        Text("Merchant Mode")
                            .font(.title)
                            .fontWeight(.bold)
                        NavigationLink(destination: TransferHistoryView().navigationBarBackButtonHidden(true), label: {
                            HStack {
                                Text(appData.userInfo.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .minimumScaleFactor(0.4)
                                    .padding()
                                Image(systemName: "chevron.right")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }.padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                        })
                        Text("\(appData.userInfo.balance) HKD")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        Spacer()
                        NavigationLink(destination: MerchantTargetView(), label: {
                            Text("Generate QR Code")
                                .font(.title)
                                .padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                        })
                        Spacer()
                    }.padding()
                }.padding()
            }.padding()
                .background(Color.duck_light_yellow)
            Spacer()
        }.padding()
            .background(Color.duck_light_yellow)
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
