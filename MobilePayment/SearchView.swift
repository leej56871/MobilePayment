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
    @State var list: [String] = []
    @State var text: String = ""
    @State var type: String
    @State var userList: [[String: Any]] = []
    @State var searchList: [searchElement] = []
    @State var observer: NSObjectProtocol?
    @State var refresh: Bool = false
    var body: some View {
        HStack {
            TextField("Search with ID", text: $text)
                .font(.title2)
                .fontWeight(.bold)
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
            })
            Spacer()
        }.padding()
        Spacer()
        ScrollView {
            if (!searchList.isEmpty) {
                ForEach(searchList) {
                    element in
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
                                    refresh.toggle()
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
                        .border(.blue, width: 1)
                }
            } else {
                Text("No user found!")
                    .font(.title)
                    .fontWeight(.bold)
            }
        }.padding()
        Spacer()
    }
}

struct searchElement: Identifiable {
    var id = UUID()
    var userID: String?
    var name: String?
}
