//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/19.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @State var flag: Bool = false
    @State var observer: NSObjectProtocol?
    @State var fromContactView: String?

    var body: some View {
        ZStack {
            TransferProcessView(flag: $flag)
                .opacity(!flag ? 1 : 0)
            transferSuccessfulView(flag: $flag)
                .opacity(!flag ? 0 : 1)
            
        }.padding()
            .onAppear(perform: {
                if fromContactView != nil {
                    let HTTPSession = HTTPSession()
                    HTTPSession.friendProcess(action: "searchOne", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: fromContactView!)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("searchOneFriend"), object: nil, queue: nil, using: {
                        notification in
                        let temp = notification.object as! [[String: Any]]
                        let tempElement = temp[0]
                        appData.userInfo.currentTarget = contact(name: tempElement["name"] as! String, userID: tempElement["userID"] as! String)
                        appData.userInfo.currentTargetBalance = tempElement["balance"] as! Int
                        NotificationCenter.default.removeObserver(observer)
                    })
                }
            })
    }
}

struct TransferFromQRView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var flag: Bool = false
    @State var observer: NSObjectProtocol?

    var body: some View {
        ZStack {
            TransferProcessView(flag: $flag)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                        )
            }
            Spacer()
            Button(action: {
                if !amountInput.isEmpty && amountInput[amountInput.startIndex] != "0" {
                    amount = Int(amountInput)!
                    amountInput = ""
                    if amount <= appData.userInfo.balance {
                        let HTTPSession = HTTPSession()
                        let date = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        let dateInString = dateFormatter.string(from: date)
                        HTTPSession.updateTransfer(userID: appData.userInfo.userID, friendID: appData.userInfo.getCurrentTarget.userID, amount: amount, date: dateInString, amout: amount)
                        observer = NotificationCenter.default.addObserver(forName: Notification.Name("updateTransfer"), object: nil, queue: nil, using: {
                            notification in
                            appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                            NotificationCenter.default.removeObserver(observer)
                            updateView.updateView()
                        })
                        updateView.updateView()
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
                UIApplication.shared.hideKeyboard()
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
