//
//  DutchSplitBoardView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/26/24.
//

import SwiftUI

struct DutchSplitBoardView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var respondedList: [String] = []
    @State var invitedIDandName: [String: String] = [:]
    @State var invitedIDandAmount: [String: String] = [:]
    @State var invitedIDandReady: [String: Bool] = [:]
    @State var invitedList: [String] = []
    @State var inviteMessage: String?
    @State var invitorMessage: String?
    @State var observer: NSObjectProtocol?
    @State var isInvitor: Bool
    @State var isRoomDelete: Bool = false
    @State var backgroundReady: Bool = false
    @State var amount: String = ""
    @State var ready: Bool = false
    
    
    var body: some View {
        HStack {
            NavigationLink(destination: MainView(), label: {
                Image(systemName: "x.square")
                    .font(.title)
                    .foregroundStyle(.red)
            }).navigationBarBackButtonHidden(true)
            Spacer()
        }.padding()
        Spacer()
        ScrollView {
            if !isRoomDelete && backgroundReady {
                if isInvitor {
                    Text("Total Amount \(String(invitorMessage!.split(separator: ":")[4]))")
                } else {
                    Text("Total Amount \(String(inviteMessage!.split(separator: ":")[4]))")
                }
                Divider()
                HStack {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.title)
                            .foregroundStyle(ready ? .green : .red)
                        Spacer()
                        Text("\(appData.userInfo.name)(\(appData.userInfo.userID)")
                        Spacer()
                        Text("\(invitedIDandAmount[appData.userInfo.userID]!) HKD")
                    }.padding()
                        .border(Color.blue.opacity(0.8))
                }
                ScrollView {
                    ForEach(respondedList, id: \.self) {
                        user in
                        if user != appData.userInfo.userID {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.title)
                                    .foregroundStyle(invitedIDandReady[user] ?? false ? .green : .red)
                                Spacer()
                                Text("\(invitedIDandName[user]!)(\(user))")
                                Spacer()
                                Text("\(invitedIDandAmount[user] ?? "0") HKD")
                            }.padding()
                        }
                    }
                    ForEach(invitedList, id: \.self) {
                        user in
                        if !respondedList.contains(where: { $0 == user }) {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text("\(invitedIDandName[user]!)(\(user))")
                                Spacer()
                                Text("- HKD")
                            }.padding()
                        }
                    }
                }
                Divider()
                VStack {
                    TextField("Enter Amount", text: $amount)
                        .keyboardType(.numberPad)
                        .padding()
                        .font(.largeTitle)
                    HStack {
                        Spacer()
                        Button(action: {
                            ready.toggle()
                            let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
                            for i in respondedList {
                                if i != appData.userInfo.userID {
                                    socketSession.sendMessage(message: "ready:\(invitorID):\(i):\(appData.userInfo.userID):\(ready):\(amount)")
                                }
                            }
                            invitedIDandAmount[appData.userInfo.userID] = amount
                        }, label: {
                            Text(ready ? "Undo" : "Ready")
                                .font(.title)
                                .foregroundStyle(.green)
                        }).disabled(amount.isEmpty || amount.first == "0")
                        Spacer()
                    }
                }
            } else if isRoomDelete {
                VStack {
                    Spacer(minLength: 300)
                    Text("The session got expired!")
                        .font(.largeTitle)
                    Text("Invitor has ended the session.")
                        .font(.title)
                    NavigationLink(destination: {
                        MainView()
                    }, label: {
                        Text("Back")
                            .font(.title3)
                    }).navigationBarBackButtonHidden(true)
                    Spacer()
                }
            }
        }.onAppear(perform: {
            let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
            let invitationListString = isInvitor ? String(invitorMessage!.split(separator: ":")[3]) : String(inviteMessage!.split(separator: ":")[3])
            let tempList = invitationListString.split(separator: ",")
            for i in tempList {
                let id = String(i.split(separator: "+")[0])
                let name = String(i.split(separator: "+")[1])
                invitedIDandName[id] = name
            }
            invitedIDandName[appData.userInfo.userID] = appData.userInfo.name
            invitedIDandAmount[appData.userInfo.userID] = "0"
            for i in invitedIDandName.keys {
                invitedList.append(i)
            }
            if !isInvitor {
                socketSession.sendMessage(message: "inRoom:\(invitorID):\(appData.userInfo.userID)")
            }
            respondedList.append(appData.userInfo.userID)
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)currentList"), object: nil, queue: nil, using: {
                notification in
                let message = notification.object as! String
                let updatedCurrentList = message.split(separator: ":")[3]
                var newList: [String] = []
                for i in updatedCurrentList.split(separator: ",") {
                    newList.append(String(i))
                }
                respondedList = newList
                updateView.updateView()
            })
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)ready"), object: nil, queue: nil, using: {
                notification in
                let message = notification.object as! String
                let targetID = String(message.split(separator: ":")[3])
                let readyState = Bool(String(message.split(separator: ":")[4]))
                let amount = String(message.split(separator: ":")[5])
                invitedIDandReady[targetID] = readyState
                invitedIDandAmount[targetID] = amount
                updateView.updateView()
            })
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)updateRoom"), object: nil, queue: nil, using: {
                notification in
                let updatedString = notification.object as! String
                let updatedList = updatedString.split(separator: ",")
                var tempList: [String] = []
                for i in updatedList {
                    tempList.append(String(i))
                }
                respondedList = tempList
                updateView.updateView()
            })
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)inRoom"), object: nil, queue: nil, using: {
                notification in
                let targetID = notification.object as! String
                respondedList.append(targetID)
                invitedIDandAmount[targetID] = "0"
                invitedIDandReady[targetID] = false
                var updatedInfo = ""
                for i in respondedList {
                    updatedInfo += i + ","
                }
                updatedInfo.removeLast()
                if isInvitor {
                    for i in respondedList {
                        socketSession.sendMessage(message: "updateRoom:\(appData.userInfo.userID):\(i):\(updatedInfo)")
                    }
                    socketSession.sendMessage(message: "currentList:\(appData.userInfo.userID):\(targetID):\(updatedInfo)")
                }
                updateView.updateView()
            })
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)outRoom"), object: nil, queue: nil, using: {
                notification in
                let targetID = notification.object as! String
                invitedIDandAmount[targetID] = nil
                invitedIDandReady[targetID] = nil
                respondedList.removeAll(where: {
                    $0 == targetID
                })
                var updatedInfo = ""
                for i in respondedList {
                    updatedInfo += i + ","
                }
                updatedInfo.removeLast()
                if isInvitor {
                    for i in respondedList {
                        socketSession.sendMessage(message: "updateRoom:\(appData.userInfo.userID):\(i):\(updatedInfo)")
                    }
                }
                updateView.updateView()
            })
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)deleteRoom"), object: nil, queue: nil, using: {
                notification in
                isRoomDelete = true
                
                let HTTPSession = HTTPSession()
                HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                    updateView.updateView()
                    NotificationCenter.default.removeObserver(observer)
                })
                updateView.updateView()
            })
            backgroundReady = true
            updateView.updateView()
        })
        .onDisappear(perform: {
            let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
            if !isInvitor {
                socketSession.sendMessage(message: "outRoom:\(invitorID):\(appData.userInfo.userID)")
            } else if isInvitor {
                for i in invitedIDandName.keys {
                    socketSession.sendMessage(message: "deleteRoom:\(invitorID):\(i):\(String(invitorMessage!))")
                }
            }
        })
    }
}
