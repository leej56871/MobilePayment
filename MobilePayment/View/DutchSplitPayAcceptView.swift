//
//  DutchSplitPayAcceptView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/26/24.
//

import SwiftUI

struct DutchSplitPayAcceptView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var observer1: NSObjectProtocol?
    @State var observer2: NSObjectProtocol?
    
    var body: some View {
        ScrollView {
            ForEach(appData.userInfo.invitationWaiting, id: \.self) {
                invite in
                let invitorID = String(invite.split(separator: ":")[1])
                let invitorName = String(invite.split(separator: ":")[2])
                let amount = String(invite.split(separator: ":")[4])
                let invitationListString = String(invite.split(separator: ":")[3])
                
                NavigationLink(destination: accpetView(inviteMessage: String(invite)), label: {
                    HStack {
                        Text("\(invitorName)(\(invitorID)")
                            .font(.title)
                        Spacer()
                        Text("\(amount) HKD")
                            .font(.title)
                    }.padding()
                })
                
            }
        }
    }
}

struct accpetView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var inviteMessage: String
    
    var body: some View {
        VStack {
            Text("Your friend)")
                .font(.title)
            Text("\(String(inviteMessage.split(separator: ":")[2]))(\(String(inviteMessage.split(separator: ":")[1])))")
                .font(.title)
            Text("has invited you!")
                .font(.title)
            Text("Total Amount: \(String(inviteMessage.split(separator: ":")[4]))")
            
            HStack {
                Spacer()
                NavigationLink(destination: DutchSplitBoardView(inviteMessage: inviteMessage, isInvitor: false), label: {
                    Text("Accept")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                })
                Spacer()
                NavigationLink(destination: MainView(), label: {
                    Text("Decline")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                }).navigationBarBackButtonHidden(true)
                Spacer()
            }.padding()
        }.padding()
    }
}
