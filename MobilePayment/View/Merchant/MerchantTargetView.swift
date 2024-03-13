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
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var inList: [merchantItem] = []
    @State var quantityList: [String: Int] = [:]
    @State var duplicateName: Bool = false
    @State var alert: Bool = false
    @State var itemName: String = ""
    @State var itemPrice: String = ""
    
    var body: some View {
        VStack {
            List {
                VStack {
                    HStack {
                        Spacer()
                        Text("Menu")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            alert.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                        })
                    }
                }.alert(duplicateName ? "Item already in!" : "Add item", isPresented: $alert, actions: {
                    TextField("Name", text: $itemName)
                    TextField("Price", text: $itemPrice)
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
                        }, label: {
                            Text("Add")
                        })
                        Button(role: .cancel, action: {
                            alert.toggle()
                            duplicateName = false
                        }, label: {
                            Text("Cancel")
                        })
                    }
                })
                if !merchantData.merchantMenu.menu.isEmpty {
                    ForEach(merchantData.merchantMenu.menu) {
                        menuElement in
                        HStack {
                            Button(action: {
                                if inList.contains(where: { $0.name == menuElement.name }) {
                                    inList.removeAll(where: { $0.name == menuElement.name })
                                    quantityList[menuElement.name] = nil
                                } else {
                                    inList.append(menuElement)
                                    quantityList[menuElement.name] = 1
                                }
                            }, label: {
                                inList.contains(where: { $0.name == menuElement.name }) ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
                            })
                            Divider()
                            Text(menuElement.name)
                            Spacer()
                            Text("\(menuElement.price) HKD")
                        }.padding()
                    }
                }
            }
            VStack {
                NavigationLink(destination: MerchantTargetListView(list: inList, quantityList: quantityList), label: {
                    Text("Confirm")
                        .font(.title)
                        .fontWeight(.bold)
                }).disabled(inList.isEmpty)
            }
        }.customToolBar(currentState: "qr", isMerchant: appData.userInfo.isMerchant)
    }
}

struct MerchantTargetListView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    var list: [merchantItem]
    @State var quantityList: [String: Int]
    
    var body: some View {
        VStack {
            Text("In Order")
                .font(.largeTitle)
        }.padding()
        Spacer()
        ScrollView {
            ForEach(list) {
                listElement in
                HStack {
                    Text(listElement.name)
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
            }.padding()
        }
        Spacer()
        VStack {
            NavigationLink(destination: MerchantQRCodeView(list: list, quantityList: quantityList), label: {
                Text("Confirm")
                    .font(.title)
            })
        }.padding()
            .customToolBar(currentState: "qr", isMerchant: appData.userInfo.isMerchant)
    }
}
