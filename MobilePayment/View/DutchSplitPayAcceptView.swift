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
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            ScrollView {
                ForEach(appData.userInfo.invitationWaiting, id: \.self) {
                    invite in
                    let invitorID = String(invite.split(separator: ":")[1])
                    let invitorName = String(invite.split(separator: ":")[2])
                    let amount = String(invite.split(separator: ":")[4])
                    NavigationLink(destination: accpetView(inviteMessage: String(invite)), label: {
                        HStack {
                            Text("\(invitorName)(\(invitorID))")
                                .font(.title3)
                            Spacer()
                            Text("\(amount) HKD")
                                .font(.title3)
                        }.padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                    })
                    
                }
            }.padding()
                .background(Color.duck_light_yellow)
        }.padding()
    }
}

struct accpetView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var inviteMessage: String
    @State var isDutch: Bool = false
    @State var isBackgroundReady: Bool = false
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                if isBackgroundReady {
                    Text("Your friend")
                        .font(.title)
                    Text("\(String(inviteMessage.split(separator: ":")[2]))(\(String(inviteMessage.split(separator: ":")[1])))")
                        .font(.title)
                    Text("has invited you!")
                        .font(.title)
                    Text("Total Amount: \(String(inviteMessage.split(separator: ":")[4]))")
                    HStack {
                        Spacer()
                        NavigationLink(destination: DutchSplitBoardView(inviteMessage: inviteMessage, isInvitor: false, isDutch: isDutch), label: {
                            Text("Accept")
                                .padding()
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        })
                        Spacer()
                        NavigationLink(destination: MainView(), label: {
                            Text("Decline")
                                .padding()
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        }).navigationBarBackButtonHidden(true)
                        Spacer()
                    }.padding()
                    Spacer()
                }
            }.padding()
                .background(Color.duck_light_yellow)
        }.onAppear(perform: {
            let tempBool = String(inviteMessage.split(separator: ":")[5])
            isDutch = Bool(tempBool) ?? false
            isBackgroundReady = true
        })
    }
}
