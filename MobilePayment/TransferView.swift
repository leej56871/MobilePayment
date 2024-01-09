//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/19.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var flag: Bool = false
    var payeeBalance: Int?
    
    var body: some View {
        ZStack {
            TransferProcessView(flag: $flag, payeeBalance: payeeBalance)
                .opacity(!flag ? 1 : 0)
            transferSuccessfulView(flag: $flag)
                .opacity(!flag ? 0 : 1)
            
        }.padding()
    }
}

struct TransferProcessView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var amountInput: String = ""
    @State var amount: Int = 0
    @FocusState var amountFocused: Bool
    @State var observer: NSObjectProtocol?
    @State var amountAvailable: Bool = true
    @State var transferSuccessful: Bool = true
    @Binding var flag: Bool
    var payeeBalance: Int?
    
    var body: some View {
        VStack {
            HStack {
                Text("Receiver : \(appData.userInfo.getCurrentTarget.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text("ID : \(appData.userInfo.getCurrentTarget.userID)")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text("My Balance : \(appData.userInfo.balance)")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            Divider()
            HStack {
                TextField(amountAvailable ? "" : "Invalid Amount", text: $amountInput)
                    .padding()
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .focused($amountFocused)
                    .font(.title)
                    .fontWeight(.bold)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 2)))
            }
            Spacer()
            Button(action: {
                if !amountInput.isEmpty && amountInput[amountInput.startIndex] != "0" {
                    amount = Int(amountInput)!
                    amountInput = ""
                    if amount <= appData.userInfo.balance {
                        let HTTPSession = HTTPSession()
                        let deduct = appData.userInfo.balance - amount
                        HTTPSession.updateUserInfo(id: appData.userInfo.userID, info: ["balance" : appData.userInfo.balance - amount])
                        observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                            notification in
                            appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                            HTTPSession.updateUserInfo(id: appData.userInfo.getCurrentTarget.userID, info: ["balance" : payeeBalance! + amount])
                            NotificationCenter.default.removeObserver(observer)
                            updateView.updateView()
                        })
                        amountAvailable = true
                        flag.toggle()
                    } else {
                        updateView.updateView()
                        amountAvailable = amount < appData.userInfo.balance
                    }
                    amountFocused = false
                }
                else{
                    amountInput = ""
                    amountFocused = false
                    amountAvailable = false
                }
            }, label: {
                Text("Confirm")
                    .font(.title)
                    .fontWeight(.bold)
            }).padding()
        }.padding()
            .onAppear(perform: {
                let HTTPSession = HTTPSession()
                HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                    NotificationCenter.default.removeObserver(observer)
                })
            })
    }
}

struct transferSuccessfulView: View {
    @Binding var flag: Bool
    
    var body: some View {
        VStack {
            Text("Transfer Successful!")
                .font(.largeTitle)
                .fontWeight(.bold)
            NavigationLink(destination: MainView(), label: {
                Text("Click to Proceed")
                    .font(.title)
                    .fontWeight(.bold)
            }).simultaneousGesture(TapGesture().onEnded({
                flag.toggle()
            }))
        }
    }
}
