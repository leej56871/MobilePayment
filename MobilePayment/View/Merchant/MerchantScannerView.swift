//
//  MerchantScannerView.swift
//  MobilePayment
//
//  Created by 이주환 on 3/6/24.
//

import SwiftUI

struct MerchantScannerView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var buttonClicked: Bool = false
    @State var waiting: Bool = false
    @State var isDone: Bool = false
    @State var qrCodeURL: String?
    @State var observer: NSObjectProtocol?
    @State var observer2: NSObjectProtocol?
    @State var invitorID: String?
    @State var flag: String?
    
    var body: some View {
        VStack {
            if !buttonClicked && !isDone {
                QRCodeScanner()
                Spacer()
                Button(action: {
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("QRCodeURL"), object: nil, queue: nil, using: {
                        notification in
                        qrCodeURL = notification.object as! String
                        invitorID = String(qrCodeURL!.split(separator: "#")[0])
                        flag = String(qrCodeURL!.split(separator: "#")[2])
                        if (flag == "split") {
                            buttonClicked = true
                        }
                        updateView.updateView()
                        NotificationCenter.default.removeObserver(observer)
                    })
                }, label: {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 50))
                })
            } else if buttonClicked && !waiting {
                Spacer(minLength: 200)
                ScrollView {
                    ForEach(qrCodeURL!.split(separator: "#")[3].split(separator: ","), id: \.self) {
                        item in
                        let amount = String(item.split(separator: "-")[1])
                        let id = String(item.split(separator: "-")[0].split(separator: "+")[1])
                        let name = String(item.split(separator: "-")[0].split(separator: "+")[0])
                        HStack {
                            Text("\(name)(\(id)")
                                .font(.title)
                            Spacer()
                            Text("\(amount) HKD")
                        }.padding()
                    }
                }
                Spacer()
                Button(action: {
                    socketSession.sendMessage(message: "qrScannedByMerchant:\(invitorID!):\(appData.userInfo.userID)")
                    waiting = true
                    updateView.updateView()
                }, label: {
                    Text("Confirm Payment")
                })
                Spacer(minLength: 10)
            } else if waiting {
                if isDone {
                    NavigationStack {
                        Text("Payment Done!")
                            .font(.title)
                        NavigationLink(destination: MerchantMainView(), label: {
                            Text("Go back")
                        }).navigationBarBackButtonHidden(true)
                    }
                } else {
                    HStack {
                        Spacer()
                        Text("Payment in process...")
                            .font(.title)
                        Spacer()
                    }
                }
            }
        }.customToolBar(currentState: "scan", isMerchant: appData.userInfo.isMerchant)
            .onAppear(perform: {
                observer2 = NotificationCenter.default.addObserver(forName: Notification.Name("\(appData.userInfo.userID)paymentFinished"), object: nil, queue: nil, using: {
                    notification in
                    isDone = true
                    updateView.updateView()
                })
            })
    }
}
