//
//  MerchantTargetView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/8/24.
//

import SwiftUI

struct MerchantTargetView: View {
    @EnvironmentObject private var merchantData: MerchantData
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @State var inList: [merchantItem] = []
    @State var quantityList: [String: Int] = [:]
    @State var duplicateName: Bool = false
    @State var alert: Bool = false
    @State var itemName: String = ""
    @State var itemPrice: String = ""
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Text("Menu")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        Spacer()
                        Button(action: {
                            alert.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                        }).padding()
                            .customBorder(clipShape: "capsule", color: Color.duck_light_orange)
                    }
                }.padding()
                    .alert(duplicateName ? "Item already in!" : "Add item", isPresented: $alert, actions: {
                        TextField("Name", text: $itemName)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        TextField("Price", text: $itemPrice)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .keyboardType(.numberPad)
                        HStack {
                            Button(action: {
                                alert.toggle()
                                if merchantData.merchantMenu.menu.contains(where: { $0.name == itemName }) {
                                    duplicateName = true
                                } else {
                                    merchantData.merchantMenu.menu.append(merchantItem(name: itemName, price: Int(itemPrice)!))
                                    let HTTPSession = HTTPSession()
                                    HTTPSession.updateUserInfo(id: appData.userInfo.userID, info: ["itemList": merchantData.returnMenuAsList()])
                                    duplicateName = false
                                }
                                let HTTPSession = HTTPSession()
                                HTTPSession.updateUserInfo(id: appData.userInfo.userID, info: ["itemList": merchantData.returnMenuAsList()])
                                updateView.updateView()
                                itemPrice = ""
                                itemName = ""
                            }, label: {
                                Text("Add")
                            }).padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                            Button(role: .cancel, action: {
                                alert.toggle()
                                duplicateName = false
                                itemPrice = ""
                                itemName = ""
                            }, label: {
                                Text("Cancel")
                            }).padding()
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        }
                    })
                List {
                    if !merchantData.merchantMenu.menu.isEmpty {
                        ForEach(merchantData.merchantMenu.menu) {
                            menuElement in
                            HStack {
                                Spacer()
                                Button(action: {
                                    if inList.contains(where: { $0.name == menuElement.name }) {
                                        inList.removeAll(where: { $0.name == menuElement.name })
                                        quantityList[menuElement.name] = nil
                                    } else {
                                        inList.append(menuElement)
                                        quantityList[menuElement.name] = 1
                                    }
                                }, label: {
                                    inList.contains(where: { $0.name == menuElement.name }) ? Image(systemName: "checkmark.circle.fill").fontWeight(.bold) : Image(systemName: "checkmark.circle").fontWeight(.bold)
                                })
                                Divider()
                                Text(menuElement.name)
                                Spacer()
                                Text("\(menuElement.price) HKD")
                                Spacer()
                            }
                        }.onDelete(perform: { indexSet in
                            let HTTPSession = HTTPSession()
                            merchantData.merchantMenu.menu.removeAll(where: {
                                $0.name == merchantData.merchantMenu.menu[indexSet.first!].name
                            })
                            HTTPSession.updateUserInfo(id: appData.userInfo.userID, info: ["itemList": merchantData.returnMenuAsList()])
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("updatedUserInfo"), object: nil, queue: nil, using: {
                                notification in
                                let updatedInfo = notification.object as! [String: Any]
                                appData.userInfo.updateUserInfo(updatedInfo: updatedInfo)
                                updateView.updateView()
                                NotificationCenter.default.removeObserver(observer)
                            })
                        })
                        .padding()
                            .listRowBackground(Color.clear)
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                    }
                }.scrollContentBackground(.hidden)
                    .background(Color.duck_orange)
                NavigationLink(destination: MerchantTargetListView(list: inList, quantityList: quantityList), label: {
                    Text("Confirm")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                }).disabled(inList.isEmpty)
            }.padding()
        }.padding()
            .background(Color.duck_light_yellow)
            .customToolBar(currentState: "qr", isMerchant: appData.userInfo.isMerchant)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
            })
    }
}

struct MerchantTargetListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    var list: [merchantItem]
    @State var quantityList: [String: Int]
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Text("In Order")
                            .font(.largeTitle)
                        Spacer()
                    }.padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                }
                Spacer()
                ScrollView {
                    ForEach(list) {
                        listElement in
                        HStack {
                            Text("\(listElement.name)(\(listElement.price)HKD)")
                                .font(.title)
                            Spacer()
                            Text(String(quantityList[listElement.name]!))
                                .font(.title)
                            Divider()
                            Button(action: {
                                quantityList[listElement.name] = quantityList[listElement.name]! + 1
                                updateView.updateView()
                            }, label: {
                                Image(systemName: "plus")
                                    .font(.title)
                            })
                            Divider()
                            Button(action: {
                                if quantityList[listElement.name] != 0 {
                                    quantityList[listElement.name] = quantityList[listElement.name]! - 1
                                    updateView.updateView()
                                }
                            }, label: {
                                Image(systemName: "minus")
                                    .font(.title)
                            })
                        }.padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                    }.padding()
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                Spacer()
                VStack {
                    NavigationLink(destination: MerchantQRCodeView(list: list, quantityList: quantityList), label: {
                        Text("Confirm")
                            .font(.title)
                    })
                }
                Spacer()
            }.background(Color.duck_light_yellow)
        }.padding()
            .background(Color.duck_light_yellow)
            .customToolBar(currentState: "qr", isMerchant: appData.userInfo.isMerchant)
    }
}
