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
    var stripeID: String = ""
    var balance: Int = 0
    var accountNumber: Int = 0
    var name: String = ""
    var transferHistoryList: [TransferHistory] = []
    var contactBook: [contact] = []
    var favContactBook: [contact] = []
    var currentTarget: contact = contact(name: "", accountNumber: "", memo: "")
    var current_client_secret: String?
    var current_publishable_key: String?
    var current_intent_id: String?
    var logInStatus: Int = 1
    
    var getbalance: String {
        return String(balance)
    }
    var getAccountNumber: String {
        return String(accountNumber)
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
    
    mutating func updateUserInfo(id: String, stripeID: String, balance: Int, name: String, transferHistoryList: [TransferHistory], contactBook: [contact], favContactBook: [contact]) {
        self.id = id
        self.stripeID = stripeID
        self.balance = balance
        self.name = name
        self.transferHistoryList = transferHistoryList
        self.contactBook = contactBook
        self.favContactBook = favContactBook
    }
    
    mutating func setCurrentTarget(target: contact) {
        self.currentTarget = target
    }

    mutating func addTransferHistory(history: TransferHistory) {
        self.transferHistoryList.append(history)
    }
    
    mutating func addContact(name: String, accountNumber: String, memo: String) -> Void {
        let temp = contact(name: name, accountNumber: accountNumber, memo: memo)
        self.contactBook.append(temp)
    }
}

public struct contact: Identifiable, Hashable {
    public let id = UUID()
    var name: String
    var accountNumber: String
    var memo: String
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
                        Text(opponent)
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
        var game: Bool = true
        
        if currentState == "transfer" {
            transfer = false
            home = true
            contact = true
            game = true
        }
        else if currentState == "home" {
            home = false
            transfer = true
            contact = true
            game = true
        }
        else if currentState == "game" {
            game = false
            home = true
            transfer = true
            contact = true
        }
        else if currentState == "contact" {
            contact = false
            home = true
            transfer = true
            game = true
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
                NavigationLink(destination: Text("Go Game/Promotion") , label: {
                    Label("Charge", systemImage: "gamecontroller.fill")
                }).font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(game ? Color.yellow : Color.gray)
                    .disabled(!game)
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
