//
//  ContentView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/12.
//

import SwiftUI
import Stripe

struct MainView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject var updateView: UpdateView
    @State var currentState: String = "home"
    
    var body: some View {
        NavigationView {
            if appData.userInfo.logInStatus == 1 {
                LogInView()
            } else if appData.userInfo.logInStatus == 2 {
                SignUpView()
            } else if appData.userInfo.logInStatus == 3 {
                NavigationStack {
                    VStack {
                        Home()
                            .foregroundStyle(Color.black)
                            .background(Color.white)
                    }.customToolBar(currentState: currentState, isMerchant: appData.userInfo.isMerchant)
                }
            } else if appData.userInfo.logInStatus == 4 {
                logInFailureView()
            } else if appData.userInfo.logInStatus == 5 {
                    MerchantMainView()
            } else if appData.userInfo.logInStatus == 6 {
                    connectionFailureView()
            }
        }.navigationBarBackButtonHidden(true)
            .onAppear(perform: {
                updateView.updateView()
            })
    }
}

struct Home: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var socketSession: SocketSession
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var observer: NSObjectProtocol?
    @State var firstLogin: Bool = true
    @State var logout: Bool = false
    @State var turnOff: Bool = false
    
    var body: some View {
        VStack {
            duckFace()
            VStack {
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
                HStack {
                    Spacer()
                    Text(appData.userInfo.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                }.padding()
                VStack {
                    Text(String(appData.userInfo.balance) + " HKD")
                        .lineLimit(0)
                        .font(.largeTitle)
                        .fixedSize(horizontal: true, vertical: true)
                        .fontWeight(.bold)
                        .padding()
                    HStack {
                        NavigationLink(destination: ChargeView()) {
                            Text("Charge")
                                .padding()
                                .lineLimit(0)
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.title)
                                .foregroundStyle(.blue)
                                .fontWeight(.bold)
                        }.navigationBarBackButtonHidden(true)
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 5, borderColor: Color.duck_orange)
                        NavigationLink(destination: TransferHistoryView()) {
                            Text("Transfer")
                                .padding()
                                .lineLimit(0)
                                .fixedSize(horizontal: true, vertical: false)
                                .font(.title)
                                .foregroundStyle(.blue)
                                .fontWeight(.bold)
                        }.navigationBarBackButtonHidden(true)
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 5, borderColor: Color.duck_orange)
                    }.padding()
                    QRCodeView()
                        .padding()
                    Spacer()
                }.padding()
            }.padding()
                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10, borderColor: Color.duck_light_orange)
            Spacer(minLength: 10)
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
                HTTPSession.getStripePublishableKey()
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("publishable_key"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.current_publishable_key = notification.object as? String
                    StripeAPI.defaultPublishableKey = appData.userInfo.current_publishable_key
                    NotificationCenter.default.removeObserver(observer)
                    updateView.updateView()
                })
                HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                    updateView.updateView()
                    NotificationCenter.default.removeObserver(observer)
                })
                updateView.updateView()
            }).onChange(of: appData.userInfo.logInStatus, {
                let HTTPSession = HTTPSession()
                HTTPSession.getStripePublishableKey()
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("publishable_key"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.current_publishable_key = notification.object as? String
                    StripeAPI.defaultPublishableKey = appData.userInfo.current_publishable_key
                    NotificationCenter.default.removeObserver(observer)
                })
                HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                    NotificationCenter.default.removeObserver(observer)
                })
            })
    }
}
