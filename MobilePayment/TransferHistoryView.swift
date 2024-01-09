//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/14.
//

import SwiftUI

struct TransferHistoryView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var observer: NSObjectProtocol?
    var body: some View {
        NavigationStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("My ID : ")
                        .font(.body)
                        .fontWeight(.bold)
                    Text(appData.userInfo.userID)
                        .font(.body)
                        .fontWeight(.bold)
                }
                Spacer()
                Text(moneyFormat(money: Int(appData.userInfo.getbalance )!) + " HKD")
                    .lineLimit(1)
                    .font(.title3)
                    .fontWeight(.bold)
            }.padding()
            Spacer()
            transferPaymentButton()
            Divider()
            transferHistoryView()
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
            }).customToolBar(currentState: "transfer")
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
            }.buttonBorderShape(.roundedRectangle)
            Spacer()
            Divider()
            Spacer()
            NavigationLink(destination: Text("Payment")) {
                Text("Payment")
                    .font(.title)
            }.buttonBorderShape(.roundedRectangle)
            Spacer()
        }.frame(height: 50)
    }
}

struct transferHistoryView: View {
    @EnvironmentObject var appData: ApplicationData
    var body: some View {
        ScrollView {
            LazyVStack {
//                ForEach(appData.userInfo.getTransferHistoryDict["default"]!) { history in
//                    history
//                    
//                }
            }
        }
    }
}
