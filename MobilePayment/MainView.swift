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
    @State var sceneChange: Bool = false
    @State var currentState: String = "home"

    var body: some View {
        NavigationView {
            if appData.userInfo.logInStatus == 1 {
                LogInView()
            }
            else if appData.userInfo.logInStatus == 2 {
                SignUpView()
            }
            else if appData.userInfo.logInStatus == 3 {
                NavigationStack {
                    VStack {
                        Home(currentState: $currentState, sceneChange: $sceneChange)
                            .foregroundColor(Color.black)
                            .background(Color.white)
                    }.customToolBar(currentState: currentState)
                }
            }
            else if appData.userInfo.logInStatus == 4 {
                logInFailureView()
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct Home: View {
    @EnvironmentObject private var appData: ApplicationData
    @Binding var currentState: String
    @Binding var sceneChange: Bool
    var body: some View {
        ScrollView {
            Text("Welcome!")
                .font(.title2)
            LazyHStack {
                Text(appData.userInfo.name)
                    .font(.title)
                    .fontWeight(.heavy)
                    .lineLimit(1)
                Spacer(minLength: 30)
                NavigationLink(destination: Text("Show notifications")) {
                    Image(systemName: "bell.circle")
                        .font(.title)
                        .foregroundColor(Color.orange)
                }
                NavigationLink(destination: Text("Move to Setting/User Info")) {
                    Image(systemName: "gearshape")
                        .font(.title)
                        .foregroundColor(Color.black)
                }
                NavigationLink(destination: Text("Show whole menu")) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                }
            }.padding()

            Spacer(minLength: 150)
            
            LazyVStack {
                NavigationLink(destination: Text(appData.userInfo.getbalance + " HKD")){
                    Text(appData.userInfo.getbalance + " HKD")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                HStack {
                    Spacer()
                    NavigationLink(destination: ChargeView().customToolBar(currentState: currentState)) {
                        Text("Charge")
                            .font(.title)
                            .fontWeight(.bold)
                    }.navigationBarBackButtonHidden(true)
                    Spacer()
                    NavigationLink(destination: TransferHistoryView()) {
                     Text("Transfer")
                        .font(.title)
                        .fontWeight(.bold)
                    }.navigationBarBackButtonHidden(true)
                    Spacer()
                }
                QRCodeView()
            }
        }.onAppear(perform: {
            let HTTPSession = HTTPSession()
            HTTPSession.getStripePublishableKey()
            NotificationCenter.default.addObserver(forName: Notification.Name("publishable_key"), object: nil, queue: nil, using: {
                notification in
                appData.userInfo.current_publishable_key = notification.object as? String
                StripeAPI.defaultPublishableKey = appData.userInfo.current_publishable_key
                NotificationCenter.default.removeObserver(self, name: Notification.Name("publishable_key"), object: nil)
            })
            sceneChange.toggle()
        }).onChange(of: sceneChange, {
            let HTTPSession = HTTPSession()
            HTTPSession.getStripePublishableKey()
            NotificationCenter.default.addObserver(forName: Notification.Name("publishable_key"), object: nil, queue: nil, using: {
                notification in
                appData.userInfo.current_publishable_key = notification.object as? String
                StripeAPI.defaultPublishableKey = appData.userInfo.current_publishable_key
            })
            HTTPSession.retrieveUserInfo(id: appData.userInfo.id)
            NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                notification in
                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
            })
        })
    }
}
