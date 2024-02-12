//
//  TargetView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/19.
//

import SwiftUI
import Stripe

struct TargetView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var contactClicked: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    contactClicked.toggle()
                }) {
                    Text("Insert Detail")
                        .font(.title2)
                        .foregroundStyle(contactClicked ? .blue : .gray)
                        .fontWeight(.bold)
                }.padding()
                    .disabled(!contactClicked)
                Divider()
                Button(action: {
                    contactClicked.toggle()
                }) {
                    Text("   Contact   ")
                        .font(.title2)
                        .foregroundStyle(contactClicked ? .gray : .blue)
                        .fontWeight(.bold)
                }.padding()
                    .disabled(contactClicked)
            }.frame(maxHeight: 50)
            Divider()
            ZStack {
                payeeDetailView()
                    .opacity(contactClicked ? 0 : 1)
                ContactView()
                    .opacity(contactClicked ? 1 : 0)
            }
            Spacer()
        }.padding()
    }
}

struct payeeDetailView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State private var userInput: String = ""
    @FocusState private var focusState: Bool
    @State var observer: NSObjectProtocol?
    @State var userAvailable: Bool = false
    @State var searchClicked: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Payee ID", text: $userInput)
                    .padding()
                    .lineLimit(1)
                    .focused($focusState)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    let HTTPSession = HTTPSession()
                    HTTPSession.friendProcess(action: "searchOne", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: userInput)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("searchOneFriend"), object: nil, queue: nil, using: {
                        notification in
                        let temp = notification.object as! [[String: Any]]
                        if temp.isEmpty {
                            userAvailable = false
                        } else {
                            let tempElement = temp[0]
                            if tempElement["userID"] as! String == "nil" {
                                userAvailable = false
                                updateView.updateView()
                            } else {
                                appData.userInfo.currentTarget = contact(name: tempElement["name"] as! String, userID: tempElement["userID"] as! String)
                                appData.userInfo.currentTargetBalance = tempElement["balance"] as! Int
                                userAvailable = true
                                updateView.updateView()
                            }
                        }
                        NotificationCenter.default.removeObserver(observer)
                        updateView.updateView()
                    })
                }) {
                    Text("Search")
                        .font(.title)
                        .fontWeight(.bold)
                }.padding()
            }
            Spacer()
            NavigationLink(destination: TransferView(), label: {
                Text(userAvailable ? "Confirm" : "Search valid user")
                    .font(.title)
                    .fontWeight(.bold)
            }).disabled(!userAvailable)
            Spacer()
        }.padding()
    }
}
