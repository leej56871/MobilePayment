//
//  ApplicationData.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/12.
//

import SwiftUI
import Foundation
import Stripe

struct userData {
    var id: String = ""
    var userID: String = ""
    var stripeID: String = ""
    var balance: Int = 0
    var name: String = ""
    var transferHistoryList: [TransferHistory] = []
    var contactBook: [contact] = []
    var favContactBook: [contact] = []
    var currentTarget: contact = contact(name: "", userID: "")
    var currentTargetBalance: Int?
    var friendSend: [contact] = []
    var friendReceive: [contact] = []
    var invitationList: [contact] = []
    var isMerchant: Bool = false
    var current_client_secret: String?
    var current_publishable_key: String?
    var current_intent_id: String?
    var logInStatus: Int = 1
    
    var getbalance: String {
        return String(balance)
    }
    var getCurrentTarget: contact {
        return currentTarget
    }
    var getFavBook: [contact] {
        return favContactBook
    }
    var getTransferHistoryList: [TransferHistory] {
        return self.transferHistoryList
    }
    var getContactBook: [contact] {
        return self.contactBook
    }
    
    mutating func updateUserInfo(updatedInfo: [String: Any]) {
        self.id = updatedInfo["_id"] as! String
        self.userID = updatedInfo["userID"] as! String
        self.stripeID = updatedInfo["stripeID"] as! String
        self.balance = updatedInfo["balance"] as! Int
        self.name = updatedInfo["name"] as! String
        self.isMerchant = updatedInfo["isMerchant"] as! Bool
        
        var newTransferHistory: [TransferHistory] = []
        for i in updatedInfo["transferHistory"] as! [String] {
            let arr = i.split(separator: "#")
            var flag = true
            if arr[1] == "send" || arr[1] == "payment" {
                flag = false
            } else {
                flag = true
            }
            newTransferHistory.append(TransferHistory(opponent: String(arr[2]), amount: String(arr[0]), receive: flag, date: String(arr[3])))
        }
        self.transferHistoryList = newTransferHistory
        
        var newContactBook: [contact] = []
        for i in updatedInfo["contact"] as! [String] {
            let arr = i.split(separator: "#")
            newContactBook.append(contact(name: String(arr[1]), userID: String(arr[0])))
        }
        self.contactBook = newContactBook
        
        var newFavContactBook: [contact] = []
        for i in updatedInfo["favContact"] as! [String] {
            let arr = i.split(separator: "#")
            newFavContactBook.append(contact(name: String(arr[1]), userID: String(arr[0])))
        }
        self.favContactBook = newFavContactBook
        
        var newFriendSend: [contact] = []
        for i in updatedInfo["friendSend"] as! [String] {
            let arr = i.split(separator: "#")
            newFriendSend.append(contact(name: String(arr[1]), userID: String(arr[0])))
        }
        self.friendSend = newFriendSend
        
        var newFriendReceive: [contact] = []
        for i in updatedInfo["friendReceive"] as! [String] {
            let arr = i.split(separator: "#")
            newFriendReceive.append(contact(name: String(arr[1]), userID: String(arr[0])))
        }
        self.friendReceive = newFriendReceive
    }
    mutating func setCurrentTarget(target: contact) {
        self.currentTarget = target
    }
}

public struct contact: Identifiable, Equatable {
    public let id = UUID()
    var name: String
    var userID: String
}

struct TransferHistory: View, Identifiable {
    var id = UUID()
    let opponent: String
    let amount: String
    let receive: Bool
    let date: String
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Spacer()
                NavigationLink(destination: Text("DETAIL")) {
                    HStack {
                        Text(date)
                            .font(.body)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.black)
                        Spacer()
                        Text(receive ? "From : " + opponent : "To : " + opponent)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.black)
                        Spacer()
                        Text("\(amount)")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(receive ? Color.green : Color.red)
                        Text(" HKD").font(.body)
                            .fontWeight(.heavy)
                            .foregroundColor(receive ? Color.green : Color.red)
                    }.frame(alignment: .leading)
                }
            }.padding()
                .border(receive ? Color.green : Color.red, width: 2)
        }.padding([.leading, .trailing], 5)
    }
}

public extension View {
    func customToolBar(currentState: String) -> some View {
        var home: Bool = false
        var transfer: Bool = true
        var contact: Bool = true
        var scan: Bool = true
        
        if currentState == "transfer" {
            transfer = false
            home = true
            contact = true
            scan = true
        }
        else if currentState == "home" {
            home = false
            transfer = true
            contact = true
            scan = true
        }
        else if currentState == "scan" {
            scan = false
            home = true
            transfer = true
            contact = true
        }
        else if currentState == "contact" {
            contact = false
            home = true
            transfer = true
            scan = true
        }
        else {
            contact = true
            home = true
            transfer = true
            scan = true
        }
        return self.toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                NavigationLink(destination: MainView(), label: {
                    Label("Home", systemImage: "house")
                }).font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(home ? Color.yellow : Color.gray)
                    .disabled(!home)
                    .navigationBarBackButtonHidden(true)
                Spacer()
                NavigationLink(destination: TransferHistoryView(), label: {
                    Label("Transfer", systemImage: "arrow.triangle.swap")
                }).font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(transfer ? Color.yellow : Color.gray)
                    .disabled(!transfer)
                    .navigationBarBackButtonHidden(true)
                
                Spacer()
                
                NavigationLink(destination: ContactView(), label: {
                    Label("Contact", systemImage: "person.3")
                }).font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(contact ? Color.yellow : Color.gray)
                    .disabled(!contact)
                    .navigationBarBackButtonHidden(true)
                Spacer()
                NavigationLink(destination: PaymentView(), label: {
                    Label("QRCode", systemImage: "qrcode.viewfinder")
                }).font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(scan ? Color.yellow : Color.gray)
                    .disabled(!scan)
                    .navigationBarBackButtonHidden(true)
                Spacer()
            }
        }
    }
}

class ApplicationData: ObservableObject {
    @Published var userInfo: userData
    init() {
        self.userInfo = userData()
    }
}

public class UpdateView: ObservableObject {
    @Published var flag: String = "update"
    func updateView() {
        if flag == "update" {
            flag = "update view"
        } else {
            flag = "update"
        }
    }
}
