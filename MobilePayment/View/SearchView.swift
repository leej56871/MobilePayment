//
//  SearchView.swift
//  MobilePayment
//
//  Created by 이주환 on 1/5/24.
//

import SwiftUI
import Alamofire

struct SearchView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @State var list: [String] = []
    @State var text: String = ""
    @State var type: String
    @State var userList: [[String: Any]] = []
    @State var searchList: [searchElement] = []
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                HStack {
                    TextField("Search with ID", text: $text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .background(.white)
                    Spacer()
                    Button(action: {
                        let HTTPSession = HTTPSession()
                        if type == "searchFriend" {
                            HTTPSession.friendProcess(action: "search", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: text)
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("searchFriend"), object: nil, queue: nil, using: {
                                notification in
                                searchList = []
                                userList = notification.object as! [[String : Any]]
                                for user in userList {
                                    searchList.append(searchElement(userID: user["userID"] as! String, name: user["name"] as! String))
                                }
                                NotificationCenter.default.removeObserver(observer)
                            })
                        }
                    }, label: {
                        Text("Search")
                            .font(.title2)
                            .fontWeight(.bold)
                    }).padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange)
                }.padding()
                Divider()
                Spacer()
                ScrollView {
                    if (!searchList.isEmpty) {
                        ForEach(searchList) {
                            element in
                            VStack {
                                HStack {
                                    Text(element.name!)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("#" + element.userID!)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Button(action: {
                                        let HTTPSession = HTTPSession()
                                        HTTPSession.friendProcess(action: appData.userInfo.friendSend.contains(where: {
                                            contact -> Bool in
                                            if contact.userID == element.userID {
                                                return true
                                            } else {
                                                return false
                                            }
                                        }) ? "cancelSend" : "send", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: element.userID!)
                                        observer = NotificationCenter.default.addObserver(forName: Notification.Name(appData.userInfo.friendSend.contains(where: {
                                            contact -> Bool in
                                            if contact.userID == element.userID {
                                                return true
                                            } else {
                                                return false
                                            }
                                        }) ? "cancelSendFriend" : "sendFriend"), object: nil, queue: nil, using: {
                                            notification in
                                            HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                                                notification in
                                                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                                updateView.updateView()
                                                NotificationCenter.default.removeObserver(observer)
                                            })
                                        })
                                    }, label: {
                                        Image(systemName: "paperplane.circle")
                                            .font(.title)
                                            .foregroundStyle(appData.userInfo.friendSend.contains(where: {
                                                contact -> Bool in
                                                if contact.userID == element.userID {
                                                    return true
                                                } else {
                                                    return false
                                                }
                                            }) ? .gray : .blue)
                                    })
                                }.padding()
                                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                            }.padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                        }
                    } else {
                        Text("No user found!")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }.padding()
                    .onAppear(perform: {
                        UIApplication.shared.hideKeyboard()
                    })
                Spacer()
            }.padding()
                .background(Color.duck_light_yellow)
        }
    }
}

struct searchElement: Identifiable {
    var id = UUID()
    var userID: String?
    var name: String?
}
