//
//  ContactView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/16.
//

import SwiftUI

struct ContactView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var isFavContactClicked: Bool = false
    @State var isContactClicked: Bool = false
    @State var isRequestClicked: Bool = false
    @State var observer: NSObjectProtocol?
    @State var refresh: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isRequestClicked.toggle()
                }, label: {
                    Text("Friend ")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(isRequestClicked ? .gray : .blue)
                        .disabled(!isRequestClicked)
                })
                Divider()
                Button(action: {
                    isRequestClicked.toggle()
                }, label: {
                    Text("Request")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(isRequestClicked ? .blue : .gray)
                        .disabled(isRequestClicked)
                })
            }.frame(maxHeight: 50)
            Divider()
            if isRequestClicked {
                RequestListView(refresh: $refresh)
                    .padding()
            } else {
                ContactListView(refresh: $refresh)
                    .padding()
            }
        }.customToolBar(currentState: "contact")
    }
}

struct ContactListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var isFavContactClicked: Bool = false
    @State var isContactClicked: Bool = false
    @State var observer: NSObjectProtocol?
    @Binding var refresh: Bool
    
    var body: some View {
        VStack {
            HStack {
                EditButton()
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink(destination: SearchView(type: "searchFriend"), label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.bold)
                })
            }.padding()
        }
        List {
            if !(appData.userInfo.favContactBook.isEmpty) {
                ForEach(appData.userInfo.favContactBook) {
                    contact in
                    HStack {
                        NavigationLink(destination: TransferView(userID: contact.userID)) {
                            HStack {
                                Text(contact.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(contact.userID)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.friendProcess(action: "undoFav", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contact.userID)
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("undoFavFriend"), object: nil, queue: nil, using: {
                                notification in
                                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                refresh.toggle()
                                NotificationCenter.default.removeObserver(observer)
                            })
                        }){
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(Color.yellow)
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }.onDelete(perform: { indexSet in
                    let HTTPSession = HTTPSession()
                    HTTPSession.friendProcess(action: "deleteFav", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: appData.userInfo.favContactBook[indexSet.first!].userID)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("deleteFavFriend"), object: nil, queue: nil, using: {
                        notification in
                        appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                        refresh.toggle()
                        NotificationCenter.default.removeObserver(observer)
                    })
                })
            }
            if !(appData.userInfo.contactBook.isEmpty) {
                ForEach(appData.userInfo.contactBook) {
                    contact in
                    HStack {
                        NavigationLink(destination: TransferView(userID: contact.userID)) {
                            HStack {
                                Text(contact.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(contact.userID)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.friendProcess(action: "doFav", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contact.userID)
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("doFavFriend"), object: nil, queue: nil, using: {
                                notification in
                                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                refresh.toggle()
                                NotificationCenter.default.removeObserver(observer)
                            })
                        }){
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(Color.gray)
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }.onDelete(perform: { indexSet in
                    let HTTPSession = HTTPSession()
                    HTTPSession.friendProcess(action: "delete", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: appData.userInfo.contactBook[indexSet.first!].userID)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("deleteFriend"), object: nil, queue: nil, using: {
                        notification in
                        appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                        refresh.toggle()
                        NotificationCenter.default.removeObserver(observer)
                    })
                })
            }
        }
    }
}

struct RequestListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var isSend: Bool = true
    @State var observer: NSObjectProtocol?
    @Binding var refresh: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                isSend.toggle()
            }, label: {
                Text("Sent")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(isSend ? .blue : .gray)
            })
            Divider()
            Button(action: {
                isSend.toggle()
            }, label: {
                Text("Received")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(isSend ? .gray : .blue)
            })
        }
        .frame(maxHeight: 50)
        Divider()
        ScrollView {
            if (isSend){
                if (!appData.userInfo.friendSend.isEmpty){
                    ForEach(appData.userInfo.friendSend) {
                        contact in
                        HStack {
                            Text(contact.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text(contact.userID)
                                .font(.title2)
                                .fontWeight(.bold)
                            Button(action: {
                                let HTTPSession = HTTPSession()
                                HTTPSession.friendProcess(action: "cancelSend", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contact.userID)
                                observer = NotificationCenter.default.addObserver(forName: Notification.Name("cancelSendFriend"), object: nil, queue: nil, using: {
                                    notification in
                                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                    refresh.toggle()
                                    NotificationCenter.default.removeObserver(observer)
                                })
                            }, label: {
                                Image(systemName: "x.square")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            })
                        }.padding()
                    }
                } else {
                    Text("No request!")
                        .font(.title)
                        .fontWeight(.bold)
                }
            } else {
                if (!appData.userInfo.friendReceive.isEmpty){
                    ForEach(appData.userInfo.friendReceive) {
                        contact in
                        HStack {
                            Text(contact.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text(contact.userID)
                                .font(.title2)
                                .fontWeight(.bold)
                            Button(action: {
                                let HTTPSession = HTTPSession()
                                HTTPSession.friendProcess(action: "accept", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contact.userID)
                                observer = NotificationCenter.default.addObserver(forName: Notification.Name("acceptFriend"), object: nil, queue: nil, using: {
                                    notification in
                                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                    refresh.toggle()
                                    print(refresh)
                                    NotificationCenter.default.removeObserver(observer)
                                })
                            }, label: {
                                Image(systemName: "plus.app")
                                    .font(.title2)
                                    .foregroundStyle(.green)
                            })
                            Divider()
                            Button(action: {
                                let HTTPSession = HTTPSession()
                                HTTPSession.friendProcess(action: "decline", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contact.userID)
                                observer = NotificationCenter.default.addObserver(forName: Notification.Name("declineFriend"), object: nil, queue: nil, using: {
                                    notification in
                                    appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                    refresh.toggle()
                                    NotificationCenter.default.removeObserver(observer)
                                })
                            }, label: {
                                Image(systemName: "x.square")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            })
                            
                        }.padding()
                    }
                } else {
                    Text("No request!")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
        }
        Spacer()
    }
}
