//
//  DutchSplitBoardView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/26/24.
//

import SwiftUI

struct DutchSplitBoardView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var invitedIDandName: [String: String] = [:]
    @State var invitedIDandAmount: [String: String] = [:]
    @State var invitedIDandReady: [String: Bool] = [:]
    @State var invitedList: [String] = []
    @State var collectedAmount: Int = 0
    @State var inviteMessage: String?
    @State var invitorMessage: String?
    @State var observer: NSObjectProtocol?
    @State var isInvitor: Bool
    @State var isRoomDelete: Bool = false
    @State var backgroundReady: Bool = false
    @State var amount: String = ""
    @State var totalAmount: String = ""
    @State var lock: Bool = false
    @State var isDone: Bool = false
    @State var notEnoughBalance: Bool = false
    @State var dutchNotEnoughBalance: Bool = false
    @State var isDutch: Bool
    @State var dutchInvitorAmount: String = ""
    @State var dutchOthersAmount: String = ""

    func updateCollectedAmount() -> Void {
        var tempInt = 0
        for i in invitedIDandAmount.keys {
            tempInt += Int(invitedIDandAmount[i]!)!
        }
        collectedAmount = tempInt
        updateView.updateView()
    }
    
    func divideTotalAmount() -> Void {
        let number = invitedIDandName.keys.count
        dutchOthersAmount = String(Int(totalAmount)! / number)
        dutchInvitorAmount = String(Int(dutchOthersAmount)! + Int(totalAmount)! % number)
    }
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                HStack {
                    NavigationLink(destination: MainView(), label: {
                        Image(systemName: "x.square")
                            .font(.title)
                            .foregroundStyle(.red)
                    }).navigationBarBackButtonHidden(true)
                    Spacer()
                }.padding()
                Spacer()
                VStack {
                    if !isRoomDelete && backgroundReady && !lock && !isDone {
                        if isInvitor {
                            Text("Total Amount : \(String(invitorMessage!.split(separator: ":")[4])) HKD")
                                .padding()
                                .font(.title3)
                                .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 10)
                        } else {
                            Text("Total Amount \(String(inviteMessage!.split(separator: ":")[4])) HKD")
                                .padding()
                                .font(.title3)
                                .minimumScaleFactor(0.6)
                                .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 10)
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Text("Collected Amount : \(collectedAmount) HKD")
                                    .padding()
                                    .lineLimit(0)
                                    .minimumScaleFactor(0.6)
                                    .font(.title3)
                                    .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 10)
                                Divider()
                                Text("My Balance : \(appData.userInfo.balance) HKD")
                                    .padding()
                                    .lineLimit(0)
                                    .minimumScaleFactor(0.6)
                                    .font(.title3)
                                    .customBorder(clipShape: "roundedRectangle", color: notEnoughBalance ? Color.red : Color.white, radius: 10)
                            }
                            Divider()
                            HStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "circle.fill")
                                        .padding()
                                        .font(.title3)
                                        .foregroundStyle(.green)
                                    Spacer()
                                    Text("\(appData.userInfo.name)(\(appData.userInfo.userID))")
                                        .font(.title3)
                                        .minimumScaleFactor(0.4)
                                    Spacer()
                                    if !isDutch {
                                        Text("\(invitedIDandAmount[appData.userInfo.userID]!) HKD")
                                            .font(.title3)
                                            .minimumScaleFactor(0.4)
                                    } else {
                                        Text("\(isInvitor ? dutchInvitorAmount : dutchOthersAmount) HKD")
                                            .font(.title3)
                                            .minimumScaleFactor(0.4)
                                    }
                                    Spacer()
                                }.padding(.horizontal)
                                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                            }
                            Spacer()
                        }
                        Divider()
                        ScrollView {
                            Spacer()
                            ForEach(Array(invitedIDandName.keys), id: \.self) {
                                user in
                                if user != appData.userInfo.userID {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "circle.fill")
                                            .padding()
                                            .font(.title3)
                                            .foregroundStyle(invitedIDandReady[user] == true ? .green : .gray)
                                        Spacer()
                                        Text("\(invitedIDandName[user]!)(\(user))")
                                            .padding(.horizontal)
                                            .font(.title3)
                                            .minimumScaleFactor(0.4)
                                        Spacer()
                                        if isDutch {
                                            Text("\(invitedIDandAmount[user] ?? "0") HKD")
                                                .padding(.horizontal)
                                                .font(.title3)
                                                .minimumScaleFactor(0.4)
                                        } else {
                                            Text("\(invitedIDandAmount[user] ?? "0") HKD")
                                                .padding(.horizontal)
                                                .font(.title3)
                                                .minimumScaleFactor(0.4)
                                        }
                                    }.padding(.horizontal)
                                }
                            }
                            Spacer()
                        }.customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                            .frame(minHeight: 100)
                        Divider()
                        Spacer()
                        VStack {
                            if !isDutch {
                                HStack {
                                    TextField("Enter Amount", text: $amount)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .font(.title3)
                                        .background(.white)
                                }.padding()
                                HStack {
                                    Button(action: {
                                        if Int(amount)! > Int(appData.userInfo.balance) {
                                            notEnoughBalance = true
                                        } else {
                                            notEnoughBalance = false
                                            let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
                                            for i in invitedIDandName.keys {
                                                if i != appData.userInfo.userID && invitedIDandReady[i] == true {
                                                    socketSession.sendMessage(message: "ready:\(invitorID):\(i):\(appData.userInfo.userID):\(true):\(amount)")
                                                }
                                            }
                                            if isDutch {
                                                invitedIDandAmount[appData.userInfo.userID] = isInvitor ? dutchInvitorAmount : dutchOthersAmount
                                            } else {
                                                invitedIDandAmount[appData.userInfo.userID] = amount
                                            }
                                            updateCollectedAmount()
                                            updateView.updateView()
                                        }
                                    }, label: {
                                        Text("Change amount")
                                            .font(.title3)
                                            .padding()
                                            .foregroundStyle(.green)
                                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                                    }).disabled(amount.isEmpty || amount.first == "0")
                                }
                            }
                            if isInvitor {
                                NavigationLink(destination: DutchSplitPayResultView(invitedIDandAmount: invitedIDandAmount, invitedIDandName: invitedIDandName, invitedIDandReady: invitedIDandReady, invitorMessage: invitorMessage!), label: {
                                    Text("Proceed")
                                        .font(.title3)
                                        .padding()
                                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                                }).disabled(!(String(collectedAmount) == totalAmount))
                                    .simultaneousGesture(TapGesture().onEnded({
                                        if String(collectedAmount) == totalAmount {
                                            self.lock = true
                                        }
                                    }))
                            }
                        }
                    } else if isRoomDelete {
                        VStack {
                            Spacer(minLength: 300)
                            Text("The session got expired!")
                                .font(.largeTitle)
                            Text("Invitor has ended the session.")
                                .font(.title)
                            NavigationLink(destination: {
                                MainView()
                            }, label: {
                                Text("Back")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                            }).navigationBarBackButtonHidden(true)
                                .padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                            Spacer()
                        }
                    } else if lock && !isRoomDelete && !isDone {
                        NavigationStack {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("Wait until payment is done...")
                                        .padding()
                                        .font(.largeTitle)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }.padding()
                    } else if lock && isRoomDelete && !isDone {
                        VStack {
                            Spacer(minLength: 300)
                            Text("The session got expired!")
                                .font(.largeTitle)
                            Text("Invitor has ended the session.")
                                .font(.title)
                            NavigationLink(destination: {
                                MainView()
                            }, label: {
                                Text("Back")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                            }).navigationBarBackButtonHidden(true)
                                .padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                            Spacer()
                        }
                    } else if isDone {
                        NavigationStack {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("Payment Done!")
                                        .font(.largeTitle)
                                        .padding()
                                    Spacer()
                                }
                                NavigationLink(destination: MainView(), label: {
                                    Text("Back!")
                                        .font(.title)
                                        .foregroundStyle(.blue)
                                }).navigationBarBackButtonHidden(true)
                                    .padding()
                                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                                Spacer()
                            }
                        }
                    }
                }.background(Color.duck_light_orange)
            }
        }.padding()
            .alert("Not Enough Balance for Dutch!", isPresented: $dutchNotEnoughBalance, actions: {
                NavigationLink(destination: DutchSplitPayInvitorView().navigationBarBackButtonHidden(true), label: {
                    Text("Go back")
                }).navigationBarBackButtonHidden(true)
            })
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
                let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
                let invitationListString = isInvitor ? String(invitorMessage!.split(separator: ":")[3]) : String(inviteMessage!.split(separator: ":")[3])
                let tempList = invitationListString.split(separator: ",")
                totalAmount = isInvitor ? String(invitorMessage!.split(separator: ":")[4]) : String(inviteMessage!.split(separator: ":")[4])
                for i in tempList {
                    let id = String(i.split(separator: "+")[0])
                    let name = String(i.split(separator: "+")[1])
                    invitedIDandName[id] = name
                }
                if isDutch {
                    divideTotalAmount()
                    if isInvitor {
                        dutchNotEnoughBalance = Int(dutchInvitorAmount)! > appData.userInfo.balance
                    } else {
                        dutchNotEnoughBalance = Int(dutchOthersAmount)! > appData.userInfo.balance
                    }
                }
                if !dutchNotEnoughBalance {
                    if isInvitor {
                        NotificationCenter.default.post(name: Notification.Name("updateCurrentInvitationDict"), object: invitedIDandName)
                        NotificationCenter.default.post(name: Notification.Name("updateCurrentInvitationMessage"), object: String(invitorMessage!))
                    }
                    invitedIDandName[appData.userInfo.userID] = appData.userInfo.name
                    if isDutch {
                        invitedIDandAmount[appData.userInfo.userID] = isInvitor ? dutchInvitorAmount : dutchOthersAmount
                    } else {
                        invitedIDandAmount[appData.userInfo.userID] = "0"
                    }
                    invitedIDandReady[appData.userInfo.userID] = true
                    if !isInvitor {
                        if isDutch {
                            socketSession.sendMessage(message: "inRoom:\(invitorID):\(appData.userInfo.userID):\(true):\(dutchOthersAmount)")
                        } else {
                            socketSession.sendMessage(message: "inRoom:\(invitorID):\(appData.userInfo.userID):\(true):0")
                        }
                    }
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)lock"), object: nil, queue: nil, using: {
                        notification in
                        lock = true
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)inRoom"), object: nil, queue: nil, using: {
                        notification in
                        let targetID = notification.object as! String
                        invitedIDandReady[targetID] = true
                        invitedIDandAmount[targetID] = isDutch ? dutchOthersAmount : "0"
                        var updatedInfo = ""
                        for i in invitedIDandReady.keys {
                            if invitedIDandReady[i] == true {
                                updatedInfo += i + "+"
                                + invitedIDandAmount[i]! + ","
                                if i != appData.userInfo.userID {
                                    if !isDutch {
                                        socketSession.sendMessage(message: "ready:\(invitorID):\(i):\(targetID):\(true):0")
                                    } else {
                                        socketSession.sendMessage(message: "ready:\(invitorID):\(i):\(targetID):\(true):\(dutchOthersAmount)")
                                    }
                                }
                            }
                        }
                        updatedInfo.removeLast()
                        socketSession.sendMessage(message: "firstJoin:\(appData.userInfo.userID):\(targetID):\(updatedInfo)")
                        updateCollectedAmount()
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)firstJoin"), object: nil, queue: nil, using: {
                        notification in
                        let message = notification.object as! String
                        let updatedInfo = message.split(separator: ",")
                        for i in updatedInfo {
                            invitedIDandReady[String(i.split(separator: "+")[0])] = true
                            invitedIDandAmount[String(i.split(separator: "+")[0])] = String(i.split(separator: "+")[1])
                        }
                        updateCollectedAmount()
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)ready"), object: nil, queue: nil, using: {
                        notification in
                        let message = notification.object as! String
                        let targetID = String(message.split(separator: ":")[3])
                        let amount = String(message.split(separator: ":")[5])
                        invitedIDandReady[targetID] = true
                        invitedIDandAmount[targetID] = amount
                        updateCollectedAmount()
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)outRoom"), object: nil, queue: nil, using: {
                        notification in
                        let targetID = notification.object as! String
                        invitedIDandAmount[targetID] = nil
                        invitedIDandReady[targetID] = false
                        updateCollectedAmount()
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)done"), object: nil, queue: nil, using: {
                        notification in
                        let HTTPSession = HTTPSession()
                        HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                        observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                            notification in
                            appData.userInfo.updateUserInfo(updatedInfo: notification.object as! [String: Any])
                            updateView.updateView()
                            NotificationCenter.default.removeObserver(observer)
                        })
                        lock = false
                        isRoomDelete = false
                        isDone = true
                        updateView.updateView()
                    })
                    NotificationCenter.default.addObserver(forName: Notification.Name("\(invitorID)deleteRoom"), object: nil, queue: nil, using: {
                        notification in
                        isRoomDelete = true
                    })
                    backgroundReady = true
                    updateCollectedAmount()
                    updateView.updateView()
                }
            })
            .onDisappear(perform: {
                let invitorID = isInvitor ? String(invitorMessage!.split(separator: ":")[1]) : String(inviteMessage!.split(separator: ":")[1])
                if !isInvitor {
                    for i in invitedIDandName.keys {
                        if invitedIDandReady[i] == true && i != appData.userInfo.userID {
                            socketSession.sendMessage(message: "outRoom:\(invitorID):\(i):\(appData.userInfo.userID)")
                        }
                    }
                } else if isInvitor {
                    if !lock {
                        for i in invitedIDandName.keys {
                            socketSession.sendMessage(message: "deleteRoom:\(invitorID):\(i):\(String(invitorMessage!))")
                        }
                    } else {
                        for i in invitedIDandName.keys {
                            socketSession.sendMessage(message: "lock:\(invitorID):\(i):\(String(invitorMessage!))")
                        }
                    }
                }
            })
    }
}
