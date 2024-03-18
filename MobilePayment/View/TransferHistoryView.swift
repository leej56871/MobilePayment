//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/14.
//

import SwiftUI

struct TransferHistoryView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @State var observer: NSObjectProtocol?
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            NavigationStack {
                duckFace()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("My ID : ")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(appData.userInfo.userID)
                                .lineLimit(0)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Text(moneyFormat(money: Int(appData.userInfo.getbalance )!) + " HKD")
                            .lineLimit(0)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }.padding()
                    Spacer()
                    transferPaymentButton()
                    Divider()
                    transferHistoryView()
                    Spacer()
                }.customBorder(clipShape: "rectangle", color: Color.duck_light_orange, radius: nil)
            }.padding()
                .onAppear(perform: {
                    let HTTPSession = HTTPSession()
                    HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                        notification in
                        appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                        updateView.updateView()
                        NotificationCenter.default.removeObserver(observer)
                    })
                    updateView.updateView()
                }).padding()
                .customBorder(clipShape: "rectangle", color: Color.duck_light_yellow, radius: nil)
                .customToolBar(currentState: "transfer", isMerchant: appData.userInfo.isMerchant)
        }
    }
}

func moneyFormat(money: Int) -> String {
    let numberFormatter: NumberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter.string(from: NSNumber(value: money))!
}

struct transferPaymentButton: View {
    var body: some View {
        Divider()
        HStack {
            Spacer()
            NavigationLink(destination: TargetView()) {
                Text("Transfer")
                    .font(.title)
            }.padding()
                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 15, borderColor: Color.duck_orange)
            Spacer()
            Divider()
            Spacer()
            NavigationLink(destination: Text("Payment")) {
                Text("Payment")
                    .font(.title)
            }.padding()
                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 15, borderColor: Color.duck_orange)
            Spacer()
        }.frame(height: 50)
    }
}

struct transferHistoryView: View {
    @EnvironmentObject var appData: ApplicationData
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(appData.userInfo.getTransferHistoryList) { history in
                    history
                }
            }
        }.padding()
            .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
    }
}
