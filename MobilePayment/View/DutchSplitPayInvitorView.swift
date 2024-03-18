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
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        inviteMode.toggle()
                    }, label: {
                        Text("Invite")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(inviteMode ? .gray : .blue)
                    }).disabled(inviteMode)
                        .padding()
                        .customBorder(clipShape: "capsule", color: Color.duck_orange)
                    Divider()
                    Button(action: {
                        inviteMode.toggle()
                    }, label: {
                        Text("Accept")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(!inviteMode ? .gray : .blue)
                    }).disabled(!inviteMode)
                            .padding()
                            .customBorder(clipShape: "capsule", color: Color.duck_orange)
                    Spacer()
                }.frame(height: 50)
                if inviteMode {
                    inviteView()
                        .padding()
                } else {
                    DutchSplitPayAcceptView()
                        .padding()
                }
            }
        }.padding()
            .background(Color.duck_light_yellow)
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
    @State var onlineList: [String] = []
    @State var backgroundReady: Bool = false
    @State var amount: String = ""
    @State var isDutch: Bool = true
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                if backgroundReady {
                    TextField("Enter the amount", text: $amount)
                        .font(.title2)
                        .padding()
                        .keyboardType(.numberPad)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .background(.white)
                    Divider()
                    HStack {
                        isDutch ? Text("Dutch(1/N)").font(.callout)
                            .multilineTextAlignment(.center)
                        : Text("Split(Custom)").font(.callout)
                            .multilineTextAlignment(.center)
                        Toggle("Change mode", isOn: $isDutch)
                            .font(.callout)
                    }.padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    Spacer()
                    Divider()
                    Text("Online Friends")
                        .padding()
                        .font(.callout)
                        .customBorder(clipShape: "roundedRectangle", color: Color.white)
                    HStack {
                        Spacer()
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.getOnlineFriendList(userID: appData.userInfo.userID)
                            updateView.updateView()
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        })
                    }.padding()
                    Divider()
                    Spacer()
                    ScrollView {
                        if onlineList.isEmpty {
                            Text("No Online Friends!")
                                .multilineTextAlignment(.center)
                        }
                        ForEach(appData.userInfo.favContactBook) {
                            contact in
                            if onlineList.contains(where: { $0 == contact.userID }) {
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
                                }).padding()
                                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                            }
                        }
                        ForEach(appData.userInfo.contactBook) {
                            contact in
                            if onlineList.contains(where: { $0 == contact.userID }) {
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
                                }).padding()
                                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                            }
                        }
                    }
                    NavigationLink(destination: afterInvitationView(invitationList: invitationList, amount: amount, isDutch: isDutch), label: {
                        Text("Invite")
                            .font(.title)
                            .fontWeight(.bold)
                    }).disabled(amount == "" || amount.prefix(1) == "0" || invitationList.isEmpty)
                }
            }
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
                let HTTPSession = HTTPSession()
                HTTPSession.getOnlineFriendList(userID: appData.userInfo.userID)
                NotificationCenter.default.addObserver(forName: Notification.Name("onlineList"), object: nil, queue: nil, using: {
                    notification in
                    print("YES!")
                    onlineList = notification.object as! [String]
                    backgroundReady = true
                    updateView.updateView()
                })
            })
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
        }.background(Color.duck_light_yellow)
        .onAppear(perform: {
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
