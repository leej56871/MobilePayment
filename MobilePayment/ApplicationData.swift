//
//  ApplicationData.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/12.
//

import SwiftUI

struct userData {
    var currentAmount: Int
    var accountNumber: Int
    var lastName: String
    var firstName: String
    var transferHistoryDict: [String: [TransferHistory]]
    var contactBook: [contact]
    var favBook: [contact]
    var currentTarget: contact
    
    var fullName: String {
        return lastName + " " + firstName
    }
    var getCurrentAmount: String {
        return String(currentAmount)
    }
    var getAccountNumber: String {
        return String(accountNumber)
    }
    var getCurrentTarget: contact {
        return currentTarget
    }
    var getFavBook: [contact] {
        return favBook
    }
    
    mutating func setCurrentTarget(target: contact) {
        currentTarget = target
    }

    mutating func addTransferHistory(history: TransferHistory, date: String) {
        if transferHistoryDict[date] != nil {
            transferHistoryDict[date]?.append(history)
        }
        else {
            transferHistoryDict.updateValue([history], forKey: date)
        }
    }
    
    mutating func addContact(name: String, accountNumber: String, memo: String) -> Void {
        let temp = contact(name: name, accountNumber: accountNumber, memo: memo)
        contactBook.append(temp)
    }
    
    var getTransferHistoryDict: Dictionary<String, Array<TransferHistory>> {
        return transferHistoryDict
    }
    
    var getContactBook: [contact] {
        return contactBook
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
    let opponentAcc: String
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
                    Label("Game/Promotion", systemImage: "gamecontroller.fill")
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
        userInfo = userData(currentAmount: 0, accountNumber: 123456789000, lastName: "Default", firstName: "Default", transferHistoryDict: ["default" : [TransferHistory(opponent: "test", opponentAcc: "test", amount: "test", receive: false, date: "test")]], contactBook: [], favBook: [], currentTarget: contact(name: "nil", accountNumber: "nil", memo: "nil"))
    }
    
}
