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
    @EnvironmentObject var updateView: UpdateView
    @State var contactClicked: Bool = false
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                HStack {
                    Button(action: {
                        contactClicked.toggle()
                    }) {
                        Text("Insert Detail")
                            .font(.title2)
                            .foregroundStyle(contactClicked ? .blue : .gray)
                            .fontWeight(.bold)
                    }.padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10, borderColor: Color.duck_orange)
                        .disabled(!contactClicked)
                    Divider()
                    Button(action: {
                        contactClicked.toggle()
                    }) {
                        Text("  Contact    ")
                            .font(.title2)
                            .foregroundStyle(contactClicked ? .gray : .blue)
                            .fontWeight(.bold)
                    }.padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10, borderColor: Color.duck_orange)
                        .disabled(contactClicked)
                }.frame(maxHeight: 50)
                Divider()
                ZStack {
                    payeeDetailView()
                        .opacity(contactClicked ? 0 : 1)
                    ContactView(asSubView: true)
                        .opacity(contactClicked ? 1 : 0)
                }
                Spacer()
            }.padding()
        }.padding()
            .background(Color.duck_light_yellow)
    }
}

struct payeeDetailView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State private var userInput: String = ""
    @State var observer: NSObjectProtocol?
    @State var userAvailable: Bool = false
    @State var searchClicked: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField("Payee ID", text: $userInput)
                    .padding()
                    .lineLimit(1)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(minWidth: 200)
                    .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 10, borderColor: Color.gray)
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
                        .font(.title2)
                        .fontWeight(.bold)
                }.padding()
                    .customBorder(clipShape: "capsule", color: Color.duck_orange, borderColor: Color.duck_orange)
            }
            Spacer()
            NavigationLink(destination: TransferView(), label: {
                Text(userAvailable ? "Click to Proceed" : "Search Exact User ID")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(userAvailable ? .blue : .black)
            }).disabled(!userAvailable)
                .padding()
                .customBorder(clipShape: "roundedRectangle", color: userAvailable ? Color.duck_orange : Color.duck_light_orange, radius: 10, borderColor: userAvailable ? Color.duck_orange : Color.duck_light_orange)
            Spacer()
        }.padding()
            .background(Color.duck_light_orange)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
            })
    }
}
