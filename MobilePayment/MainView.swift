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
    @State var currentState: String = "home"

    var body: some View {
        NavigationStack {
            VStack {
                Home(currentState: $currentState, appData: appData)
                    .foregroundColor(Color.black)
                    .background(Color.white)
                
            }.customToolBar(currentState: currentState)

        }.onAppear(perform: {
            let HTTPSession = HTTPSession()
            HTTPSession.getStripePublishableKey()
            NotificationCenter.default.addObserver(forName: Notification.Name("publishable_key"), object: nil, queue: nil, using: {
                notification in
                print("This is notification.object")
                print(notification.object)
                appData.userInfo.current_publishable_key = notification.object as? String
                StripeAPI.defaultPublishableKey = appData.userInfo.current_publishable_key
                
                print("Publishable Key is", appData.userInfo.current_publishable_key)
            })
        })
    }
    
}

struct Home: View {
    @Binding var currentState: String
    let appData: ApplicationData
    var body: some View {
        ScrollView {
            Text("Welcome!")
                .font(.title2)
            LazyHStack {
                Text(appData.userInfo.fullName)
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
                .cornerRadius(25)
                .background(Color("MyColor"))

            Spacer(minLength: 150)
            
            LazyVStack {
                NavigationLink(destination: Text(appData.userInfo.getCurrentAmount + " HKD")){
                    Text(appData.userInfo.getCurrentAmount + " HKD")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                HStack {
                    Spacer()
                    NavigationLink(destination: ChargeView()) {
                        Text("Charge")
                            .font(.title)
                            .fontWeight(.bold)
                    }.navigationBarBackButtonHidden(true)
                    Spacer()
                    NavigationLink(destination: TransferHistoryView()) {
                     Text("Transfer")
                        .font(.title)
                        .fontWeight(.bold)
                    }
                    Spacer()
                }
                
                QRCodeView()
                
                
            }
        }
    }
    
}
