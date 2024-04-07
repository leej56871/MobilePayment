//
//  ContactView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/16.
//

import SwiftUI

struct ContactView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @State var isFavContactClicked: Bool = false
    @State var isContactClicked: Bool = false
    @State var isRequestClicked: Bool = false
    @State var observer: NSObjectProtocol?
    @State var asSubView: Bool
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                if !asSubView {
                    duckFace()
                }
                Spacer()
                HStack {
                    Button(action: {
                        isRequestClicked.toggle()
                    }, label: {
                        Text("Friend ")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(isRequestClicked ? .blue : .gray)
                    }).disabled(!isRequestClicked)
                        .padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                    Divider()
                    Button(action: {
                        isRequestClicked.toggle()
                    }, label: {
                        Text("Request")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(!isRequestClicked ? .blue : .gray)
                    }).disabled(isRequestClicked)
                        .padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                }.frame(maxHeight: 50)
                Divider()
                if isRequestClicked {
                    RequestListView()
                        .padding()
                } else {
                    ContactListView()
                        .padding()
                }
            }
        }.customToolBar(currentState: asSubView ? "transfer" : "contact", isMerchant: appData.userInfo.isMerchant)
            .padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
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
    }
}

struct ContactListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var isFavContactClicked: Bool = false
    @State var isContactClicked: Bool = false
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        VStack {
            HStack {
                EditButton()
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                Spacer()
                NavigationLink(destination: SearchView(type: "searchFriend"), label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .customBorder(clipShape: "capsule", color: Color.duck_orange)
                })
            }.padding()
        }
        List {
            if !(appData.userInfo.favContactBook.isEmpty) {
                ForEach(appData.userInfo.favContactBook.sorted(by: { $0.name < $1.name })) {
                    contactElement in
                    HStack {
                        NavigationLink(destination: TransferView(fromContactView: contactElement.userID), label: {
                            HStack {
                                Text(contactElement.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(contactElement.userID)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        })
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.friendProcess(action: "undoFav", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contactElement.userID)
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("undoFavFriend"), object: nil, queue: nil, using: {
                                notification in
                                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                updateView.updateView()
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
                        updateView.updateView()
                        NotificationCenter.default.removeObserver(observer)
                    })
                })
            }
            if !(appData.userInfo.contactBook.isEmpty) {
                ForEach(appData.userInfo.contactBook.sorted(by: { $0.name < $1.name })) {
                    contactElement in
                    HStack {
                        NavigationLink(destination: TransferView(fromContactView: contactElement.userID)) {
                            HStack {
                                Text(contactElement.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(contactElement.userID)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.friendProcess(action: "doFav", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: contactElement.userID)
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("doFavFriend"), object: nil, queue: nil, using: {
                                notification in
                                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                                updateView.updateView()
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
                        updateView.updateView()
                        NotificationCenter.default.removeObserver(observer)
                    })
                })
            }
        }
        .customBorder(clipShape: "rectangle", color: Color.duck_orange)
        .scrollContentBackground(.hidden)
        .background(Color.duck_light_orange)
        .onAppear {
            let HTTPSession = HTTPSession()
            HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
            observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                notification in
                appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                updateView.updateView()
                NotificationCenter.default.removeObserver(observer)
            })
        }
    }
}

struct RequestListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var isSend: Bool = true
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        HStack {
            Button(action: {
                isSend.toggle()
            }, label: {
                Text("Sent")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(isSend ? .gray : .blue)
            }).disabled(isSend)
                .padding()
                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
            Divider()
            Button(action: {
                isSend.toggle()
            }, label: {
                Text("Received")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(isSend ? .blue : .gray)
            }).disabled(!isSend)
                .padding()
                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
        }.frame(maxHeight: 50)
        Divider()
        ScrollView {
            if (isSend){
                if (!appData.userInfo.friendSend.isEmpty){
                    Spacer()
                    ForEach(appData.userInfo.friendSend) {
                        contact in
                        HStack {
                            Spacer()
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
                                    updateView.updateView()
                                    NotificationCenter.default.removeObserver(observer)
                                })
                            }, label: {
                                Image(systemName: "x.square")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            })
                            Spacer()
                        }.padding()
                    }
                    Spacer()
                } else {
                    HStack {
                        Spacer()
                        Text("No request!")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
            } else {
                if (!appData.userInfo.friendReceive.isEmpty){
                    Spacer()
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
                                    updateView.updateView()
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
                                    updateView.updateView()
                                    NotificationCenter.default.removeObserver(observer)
                                })
                            }, label: {
                                Image(systemName: "x.square")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                            })
                            
                        }.padding()
                    }
                    Spacer()
                } else {
                    HStack {
                        Spacer()
                        Text("No request!")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
            }
        }.padding()
            .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
        Spacer()
    }
}
