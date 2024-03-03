//
//  DutchSplitPayInvitorView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/26/24.
//

import SwiftUI

struct DutchSplitPayInvitorView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var inviteMode: Bool = true
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    inviteMode.toggle()
                }, label: {
                    Text("Invite")
                        .font(.title)
                        .fontWeight(.bold)
                }).disabled(inviteMode)
                Divider()
                Button(action: {
                    inviteMode.toggle()
                }, label: {
                    Text("Accept")
                        .font(.title)
                        .fontWeight(.bold)
                }).disabled(!inviteMode)
                Spacer()
            }.frame(height: 50)
            if inviteMode {
                inviteView()
            } else {
                DutchSplitPayAcceptView()
            }
        }.padding()
            .onAppear(perform: {
                let HTTPSession = HTTPSession()
                NotificationCenter.default.addObserver(forName: Notification.Name("gotInvite"), object: nil, queue: nil, using: {
                    notification in
                    HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                        notification in
                        appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                        updateView.updateView()
                        NotificationCenter.default.removeObserver(observer)
                    })
                })
            })
    }
}

struct inviteView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var invitationList: [contact] = []
    @State var amount: String = ""
    @State var isDutch: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                isDutch ? Text("Dutch(1/N)").font(.title2) : Text("Split(Custom)").font(.title2)
                Toggle("Change mode", isOn: $isDutch)
            }.padding()
                .frame(height: 50)
            Spacer()
            TextField("Enter the amount", text: $amount)
                .font(.title)
                .keyboardType(.numberPad)
            Spacer()
            ScrollView {
                ForEach(appData.userInfo.favContactBook) {
                    contact in
                    Button(action: {
                        if !invitationList.contains(where: { $0.userID == contact.userID }) {
                            invitationList.append(contact)
                        } else {
                            invitationList.removeAll(where: { $0.userID == contact.userID })
                        }
                        updateView.updateView()
                    }, label: {
                        HStack {
                            invitationList.contains(where: { $0.userID == contact.userID }) ?
                            Image(systemName: "checkmark.circle.fill").font(.title2) : Image(systemName: "checkmark.circle")
                                .font(.title2)
                            Spacer()
                            Text("\(contact.name) (\(contact.userID))")
                                .font(.title2)
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                        }
                    })
                }
                ForEach(appData.userInfo.contactBook) {
                    contact in
                    Button(action: {
                        if !invitationList.contains(where: { $0.userID == contact.userID }) {
                            invitationList.append(contact)
                        } else {
                            invitationList.removeAll(where: { $0.userID == contact.userID })
                        }
                        updateView.updateView()
                    }, label: {
                        HStack {
                            invitationList.contains(where: { $0.userID == contact.userID }) ?
                            Image(systemName: "checkmark.circle.fill").font(.title2) : Image(systemName: "checkmark.circle")
                                .font(.title2)
                            Spacer()
                            Text("\(contact.name) (\(contact.userID))")
                                .font(.title2)
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        }
                    })
                }
            }
            NavigationLink(destination: afterInvitationView(invitationList: invitationList, amount: amount, isDutch: isDutch), label: {
                Text("Invite")
                    .font(.title)
                    .fontWeight(.bold)
            }).disabled(amount == "" || amount.prefix(1) == "0" || invitationList.isEmpty)
        }.padding()
    }
}

struct afterInvitationView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var invitationList: [contact]
    @State var amount: String
    @State var isDutch: Bool
    @State var invitorMessage: String?
    
    var body: some View {
        VStack {
            if invitorMessage != nil {
                DutchSplitBoardView(invitorMessage: invitorMessage, isInvitor: true)
            }
        }.onAppear(perform: {
            var invitationListString = appData.userInfo.userID + "+" + appData.userInfo.name + ","
            for contact in invitationList {
                invitationListString += contact.userID + "+" + contact.name + ","
            }
            invitationListString.removeLast()
            for contact in invitationList {
                socketSession.sendMessage(message: "invite:\(appData.userInfo.userID):\(appData.userInfo.name):\(contact.userID):\(contact.userID):\(invitationListString):\(amount):\(isDutch)")
            }
            invitorMessage =  "invite:\(appData.userInfo.userID):\(appData.userInfo.name):\(invitationListString):\(amount):\(isDutch)"
        })
    }
}
