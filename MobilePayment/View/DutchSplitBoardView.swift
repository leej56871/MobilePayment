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
    @State var inviteMessage: String?
    @State var invitorMessage: String?
    @State var isInvitor: Bool
    @State var isRoomDelete: Bool = false
    @State var backgroundReady: Bool = false
    
    
    var body: some View {
        VStack {
            if !isRoomDelete && backgroundReady {
                if isInvitor {
                    Text("Total Amount \(String(invitorMessage!.split(separator: ":")[4]))")
                } else {
                    Text("Total Amount \(String(inviteMessage!.split(separator: ":")[6]))")
                }
                HStack {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.title)
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(appData.userInfo.name)(\(appData.userInfo.userID)")
                    }.padding()
                }
                ScrollView {
                    ForEach(respondedList, id: \.self) {
                        user in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                            Spacer()
                            Text("\(invitedIDandName[user]!)(\(user))")
                            Text(user)
                        }.padding()
                    }
                    
                }
            }
        }.onAppear(perform: {
            let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
            let invitationListString = isInvitor ? String(invitorMessage!.split(separator: ":")[3]) : String(inviteMessage!.split(separator: ":")[5])
            let tempList = invitationListString.split(separator: ",")
            for i in tempList {
                let id = String(i.split(separator: "+")[0])
                let name = String(i.split(separator: "+")[1])
                invitedIDandName[id] = name
            }
            if !isInvitor {
                socketSession.sendMessage(message: "inRoom:\(invitorID):\(appData.userInfo.userID)")
            }
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
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)outRoom"), object: nil, queue: nil, using: {
                notification in
                let targetID = notification.object as! String
                respondedList.removeAll(where: {
                    $0 == targetID
                })
                updateView.updateView()
            })
            NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)deleteRoom"), object: nil, queue: nil, using: {
                notification in
                isRoomDelete = true
                updateView.updateView()
            })
            backgroundReady = true
        })
        .onDisappear(perform: {
            print("View is on Disappear!")
            let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
            if !isInvitor {
                socketSession.sendMessage(message: "outRoom:\(invitorID):\(appData.userInfo.userID)")
            } else {
                appData.userInfo.invitationWaiting.removeAll(where: {
                    $0 == inviteMessage
                })
                for i in invitedIDandName.keys {
                    socketSession.sendMessage(message: "deleteRoom:\(invitorID):\(i):\(inviteMessage)")
                }
            }
        })
    }
}
