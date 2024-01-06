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
    var body: some View {
        HStack {
            TextField("Search with the name", text: $text)
            Spacer()
            Button(action: {
                let HTTPSession = HTTPSession()
                if type == "searchFriend" {
                    HTTPSession.friendProcess(action: "search", myID: appData.userInfo.id, friendID: text)
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
                    .font(.caption)
                    .fontWeight(.bold)
            })
            Spacer()
        }.padding()
        Spacer()
        LazyVStack {
            ForEach(searchList) {
                element in
                Button(action: {
                    print("CLICKED!")
                }, label: {
                    HStack {
                        Text(element.name!)
                        Spacer()
                        Text("#" + element.userID!)
                    }
                })
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
