////
////  SplitPayView.swift
////  MobilePayment
////
////  Created by 이주환 on 2/12/24.
////
//
//import SwiftUI
//
//struct SplitPayView: View {
//    @EnvironmentObject private var appData: ApplicationData
//    @EnvironmentObject private var socketSession: SocketSession
//    @ObservedObject var updateView: UpdateView = UpdateView()
//    @State var state: Bool = true
//    @State var observer: NSObjectProtocol?
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Button(action: {
//                    state.toggle()
//                    updateView.updateView()
//                }, label: {
//                    Text("  Pay  ")
//                        .font(.largeTitle)
//                        .foregroundStyle(!state ? .blue : .gray)
//                }).disabled(state)
//                Divider()
//                Button(action: {
//                    state.toggle()
//                    updateView.updateView()
//                }, label: {
//                    Text(" Accept")
//                        .font(.largeTitle)
//                        .foregroundStyle(state ? .blue : .gray)
//                }).disabled(!state)
//            }.padding()
//                .frame(maxHeight: 50)
//            Spacer()
//            if state {
//                PaymentView(isSplit: true)
//            } else {
//                acceptSplitListView()
//            }
//        }.customToolBar(currentState: "splitPay")
//    }
//}
//
//struct inviteSplit: View {
//    @EnvironmentObject private var appData: ApplicationData
//    @ObservedObject var updateView: UpdateView = UpdateView()
//    @State var invitationList: [contact] = []
//    @State var item: String
//    @State var amount: Int
//    @State var isDutch: Bool
//    
//    var body: some View {
//        ScrollView {
//            Text("Invite Friends")
//            ForEach(appData.userInfo.favContactBook) {
//                contact in
//                HStack{
//                    invitationList.contains(where: { $0.userID == contact.userID }) ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
//                    Text(contact.name)
//                    Text("#\(contact.userID)")
//                    Image(systemName: "star")
//                        .foregroundStyle(.yellow)
//                }.padding()
//            }
//            ForEach(appData.userInfo.contactBook) {
//                contact in
//                HStack{
//                    invitationList.contains(where: { $0.userID == contact.userID }) ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
//                    Text(contact.name)
//                    Text("#\(contact.userID)")
//                    Image(systemName: "star")
//                }.padding()
//            }
//            NavigationLink(destination: SplitPayProcessView(invitationList: invitationList, item: item, amount: amount, isDutch: isDutch), label: {
//                Text("Invite")
//                    .font(.title)
//                    .fontWeight(.bold)
//            })
//        }.onAppear(perform: {
//            let itemList = item.split(separator: "/")
//            for item in itemList {
//                let itemName = item.split(separator: "+")[0]
//                let itemPrice = item.split(separator: "+")[1]
//            }
//        })
//    }
//}
//
//struct SplitPayProcessView: View {
//    @EnvironmentObject private var appData: ApplicationData
//    @EnvironmentObject private var socketSession: SocketSession
//    @EnvironmentObject private var updateView: UpdateView
//    @State var respondedList: [String] = []
//    @State var observer: NSObjectProtocol?
//    @State var observer2: NSObjectProtocol?
//    @State var isGathered: Bool = false
//    var invitationList: [contact]
//    var item: String
//    var amount: Int
//    var isDutch: Bool
//    
//    var body: some View {
//        VStack {
//            Text("Waiting List")
//                .font(.title)
//                .fontWeight(.bold)
//            ForEach(invitationList) {
//                contact in
//                HStack {
//                    Text(contact.name)
//                    Spacer()
//                    Text(contact.userID)
//                    Spacer()
//                    Image(systemName: "circle.fill")
//                        .foregroundStyle(invitationList.contains(where: { $0.userID == contact.userID }) ? .green : .red)
//                    
//                }.padding()
//            }
//            NavigationLink(destination: SplitPaymentConfirmationView(), label: {
//                isGathered ?
//                Text("Confirm").font(.title).fontWeight(.bold) : Text("Waiting for all to respond...").font(.title).fontWeight(.bold)
//            }).disabled(!isGathered)
//        }.onAppear(perform: {
//            for i in invitationList {
//                socketSession.sendMessage(message: "request:\(i.userID):\(i.name):\(item):\(amount):\(isDutch)")
//            }
//            observer = NotificationCenter.default.addObserver(forName: Notification.Name("SocketGotRespond"), object: nil, queue: nil, using: {
//                notification in
//                let respondString = notification.object as! String
//                let respond = respondString.split(separator: ":")[1]
//                let friendID = respondString.split(separator: ":")[2]
//                if respond == "yes" {
//                    respondedList.append(String(friendID))
//                }
//                if invitationList.count == respondedList.count {
//                    isGathered = true
//                }
//                updateView.updateView()
//            })
//            observer2 = NotificationCenter.default.addObserver(forName: Notification.Name("SocketGotRequest"), object: nil, queue: nil, using: {
//                notification in
//                updateView.updateView()
//            })
//        })
//    }
//}
//
//struct SplitPaymentConfirmationView: View {
//    
//    var body: some View {
//        VStack {
//            
//        }
//    }
//}
//
//struct acceptSplitListView: View {
//    @EnvironmentObject private var appData: ApplicationData
//    var body: some View {
//        ScrollView {
//            ForEach(appData.userInfo.invitationWaiting, id: \.self) {
//                invite in
//                let invitorID = String(invite.split(separator: ":")[1])
//                let invitorName = String(invite.split(separator: ":")[2])
//                let itemList = invite.split(separator: ":")[3] as! [String]
//                let amount = Int(invite.split(separator: ":")[4])
//                let isDutch = invite.split(separator: ":")[5] as! Bool
//                NavigationLink(destination: acceptSplitView(invitorName: invitorName, invitorID: invitorID, itemList: itemList, amount: amount!, isDutch: isDutch, invitationString: invite), label: {
//                    HStack {
//                        Text("From: \(invitorName), ID: \(invitorID), Total: \(amount!) HKD")
//                            .font(.title)
//                    }.padding()
//                })
//            }
//        }.onAppear(perform: {
//            let HTTPSession = HTTPSession()
//            HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
//        })
//    }
//}
//
//struct acceptSplitView: View {
//    @EnvironmentObject private var appData: ApplicationData
//    @EnvironmentObject private var socketSession: SocketSession
//    @EnvironmentObject private var updateView: UpdateView
//    @State var invitorName: String
//    @State var invitorID: String
//    @State var itemList: [String]
//    @State var amount: Int
//    @State var isDutch: Bool
//    @State var invitationString: String
//    @State var isAccept: Bool = false
//    @State var isReady: Bool = false
//    @State var observer: NSObjectProtocol?
//    
//    var body: some View {
//        VStack {
//            if !isAccept {
//                Text("Your Friend")
//                Text("\(invitorName)(\(invitorID) has")
//                Text(isDutch ? "invited you in Dutch Pay!" : "invited you in Split Pay!")
//                Spacer()
//                HStack {
//                    Button(action: {
//                        let targetInvitation = appData.userInfo.invitationWaiting.firstIndex(where: )
//                        socketSession.sendMessage(message: "respond:\(invitorID):yes:\(invitationString)")
//                        updateView.updateView()
//                    }, label: {
//                        Text("Accept")
//                    })
//                    Spacer()
//                    Button(action: {
//                        socketSession.sendMessage(message: "respond:\(invitorID):no:\(invitationString)")
//                        let HTTPSession = HTTPSession().retrieveUserInfo(id: appData.userInfo.userID)
//                        updateView.updateView()
//                    }, label: {
//                        Text("Decline")
//                    })
//                }.padding()
//            } else {
//                Spacer()
//                if isReady{
//                    
//                } else {
//                    Text("Wait until the Invitor and other friends are ready...")
//                        .font(.title)
//                        .fontWeight(.bold)
//                }
//                Spacer()
//                NavigationLink(destination: acceptSplitDetailView(invitorName: invitorName, invitorID: invitorID, itemList: itemList, amount: amount, isDutch: isDutch), label: {
//                    Text("Proceed")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                }).disabled(!isReady)
//                Spacer()
//            }
//        }.padding()
//            .onAppear(perform: {
//                observer = NotificationCenter.default.addObserver(forName: Notification.Name("SplitReady"), object: nil, queue: nil, using: {
//                    notification in
//                    if notification.object as! Bool {
//                        isReady = true
//                        updateView.updateView()
//                        NotificationCenter.default.removeObserver(observer)
//                    }
//                })
//            })
//    }
//}
//
//
//struct acceptSplitDetailView: View {
//    @EnvironmentObject private var socketSession: SocketSession
//    @State var invitorName: String
//    @State var invitorID: String
//    @State var itemList: [String]
//    @State var amount: Int
//    @State var isDutch: Bool
//    @State var isWaitingDone: Bool = false
//    @State var observer: NSObjectProtocol?
//    
//    var body: some View {
//        VStack {
//            ScrollView {
//                Text("Invitor: \(invitorName)(\(invitorID)")
//                Text("Total amount: \(amount)")
//                ForEach(itemList, id: \.self) {
//                    item in
//                    let itemName = String(item.split(separator: "+")[0])
//                    let itemPrice = item.split(separator: "+")[1].split(separator: "*")[0]
//                    let itemQuantity = String(item.split(separator: "+")[1].split(separator: "*")[1])
//                    let totalPrice = String(Int(itemPrice)! * Int(itemQuantity)!)
//                    HStack {
//                        Text(itemName)
//                        Spacer()
//                        Text("x\(itemQuantity)")
//                        Spacer()
//                        Text("\(totalPrice) HKD")
//                    }.padding()
//                }
//            }
//            paymentBoard(invitationList: )
//
//        }
//    }
//}
//
//struct paymentBoard: View {
//    @EnvironmentObject private var appData: ApplicationData
//    @EnvironmentObject private var updateView: UpdateView
//    @EnvironmentObject private var socketSession: SocketSession
//    @State var invitationList: [String]
//    @State var userBoardDict: [String: Int] = [:]
//    @State var observer1: NSObjectProtocol?
//    @State var observer2: NSObjectProtocol?
//    @State var statusDict: [String: String] = [:]
//    @State var totalAmount: Int = 0
//    
//    var body: some View {
//        ScrollView {
//            Text("Total amount: \(String(totalAmount))")
//            if !statusDict.isEmpty {
//                ForEach(invitationList, id: \.self) {
//                    user in
//                    let userPrice = statusDict[user]! + "HKD"
//                    HStack {
//                        if let name = appData.userInfo.contactBook.first(where: {
//                            contact in
//                            contact.userID == user
//                        }) {
//                            Text(name.name)
//                                .font(.title)
//                        } else if let name = appData.userInfo.favContactBook.first(where: {
//                            contact in
//                            contact.userID == user
//                        }) {
//                            Text(name.name)
//                                .font(.title)
//                        }
//                        Text("\(user)")
//                            .font(.title)
//                        Spacer()
//                        Text(userPrice)
//                            .font(.title)
//                    }.padding()
//                }
//            }
//        }.onAppear(perform: {
//            for user in invitationList {
//                statusDict[user] = ""
//            }
//            observer1 = NotificationCenter.default.addObserver(forName: Notification.Name("updateOnPayment"), object: nil, queue: nil, using: {
//                notification in
//                let object =  notification.object as! String
//                let friendID = String(object.split(separator: ":")[1])
//                let price = String(object.split(separator: ":")[2])
//                statusDict[friendID] = price
//                var temp = 0
//                for user in invitationList {
//                    temp += Int(statusDict[user]!)!
//                }
//                totalAmount = temp
//                updateView.updateView()
//            })
//        })
//    }
//}
