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
    var invitationWaiting: [String] = []
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
            if arr[1] == "send"{
                flag = false
                newTransferHistory.append(TransferHistory(opponent: String(arr[2]), amount: String(arr[0]), receive: flag, date: String(arr[3]), detail: "", isDutchSplit: false))
            } else if arr[1] == "payment" {
                flag = false
                newTransferHistory.append(TransferHistory(opponent: String(arr[2]), amount: String(arr[0]), receive: flag, date: String(arr[3]), detail: String(arr[4]), isDutchSplit: false))
            } else if arr[1] == "dutchSplit" {
                if isMerchant {
                    newTransferHistory.append(TransferHistory(opponent: String(arr[2] + "+"), amount: String(arr[0]), receive: true, date: String(arr[3]), detail: String(arr[4]), isDutchSplit: true))
                } else {
                    newTransferHistory.append(TransferHistory(opponent: String(arr[2] + "+"), amount: String(arr[0]), receive: flag, date: String(arr[3]), detail: String(arr[4]), isDutchSplit: true))
                }
            } else {
                flag = true
            }
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
        self.invitationWaiting = updatedInfo["invitationWaiting"] as! [String]
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
    let detail: String?
    let isDutchSplit: Bool
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

extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
 }
 
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}


public extension View {
    func customToolBar(currentState: String, isMerchant: Bool) -> some View {
        var home: Bool = true
        var transfer: Bool = false
        var contact: Bool = false
        var scan: Bool = false
        var splitPay: Bool = false
        var qr: Bool = false
        
        if currentState == "transfer" {
            transfer = true
            home = false
            contact = false
            scan = false
            splitPay = false
            qr = false
            
        } else if currentState == "home" {
            home = true
            transfer = false
            contact = false
            scan = false
            splitPay = false
            qr = false
            
        } else if currentState == "scan" {
            scan = true
            home = false
            transfer = false
            contact = false
            splitPay = false
            qr = false
            
        } else if currentState == "contact" {
            contact = true
            home = false
            transfer = false
            scan = false
            splitPay = false
            qr = false
            
        } else if currentState == "splitPay" {
            splitPay = true
            contact = false
            home = false
            transfer = false
            scan = false
            qr = false
            
        } else if currentState == "qr" {
            splitPay = false
            contact = false
            home = false
            transfer = false
            scan = false
            qr = true
        }
        
        return self.toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if isMerchant {
                    HStack {
                        Spacer()
                        NavigationLink(destination: MainView(), label: {
                            VStack {
                                Image(systemName: "house")
                                Text("Home")
                            }.font(.body)
                            .foregroundColor(home ? Color.gray : Color.blue)
                        }).disabled(home)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                        NavigationLink(destination: TransferHistoryView(), label: {
                            VStack {
                                Image(systemName: "arrow.triangle.swap")
                                Text("Transfer")
                            }.font(.body)
                            .foregroundColor(transfer ? Color.gray : Color.blue)
                        }).disabled(transfer)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                        NavigationLink(destination: MerchantScannerView(), label: {
                            VStack {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                            }.font(.body)
                            .foregroundColor(scan ? Color.gray : Color.blue)
                        }).disabled(scan)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                    }
                } else {
                    HStack {
                        Spacer()
                        NavigationLink(destination: MainView(), label: {
                            VStack {
                                Image(systemName: "house")
                                Text("Home")
                            }.font(.body)
                                .foregroundColor(home ? Color.gray : Color.blue)
                        }).disabled(home)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                        NavigationLink(destination: TransferHistoryView(), label: {
                            VStack {
                                Image(systemName: "arrow.triangle.swap")
                                Text("Transfer")
                            }.font(.body)
                                .foregroundColor(transfer ? Color.gray : Color.blue)
                        }).disabled(transfer)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                        NavigationLink(destination: PaymentView(), label: {
                            VStack {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                            }.font(.body)
                                .foregroundColor(scan ? Color.gray : Color.blue)
                        }).disabled(scan)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                        NavigationLink(destination: ContactView(), label: {
                            VStack {
                                Image(systemName: "person.crop.rectangle.stack")
                                Text("Contact")
                            }.font(.body)
                                .foregroundColor(contact ? Color.gray : Color.blue)
                        }).disabled(contact)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                        NavigationLink(destination: DutchSplitPayInvitorView(), label: {
                            VStack {
                                Image(systemName: "person.3")
                                Text("1/n Pay")
                            }.font(.body)
                                .foregroundColor(splitPay ? Color.gray : Color.blue)
                        }).disabled(splitPay)
                            .navigationBarBackButtonHidden(true)
                        Spacer()
                    }
                }
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
