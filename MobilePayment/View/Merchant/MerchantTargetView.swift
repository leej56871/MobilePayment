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
    @State var alert: Bool = false
    @State var itemName: String = ""
    @State var itemPrice: String = ""
    
    var body: some View {
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
            }.alert("Add item", isPresented: $alert, actions: {
                TextField("Name", text: $itemName)
                TextField("Price", text: $itemPrice)
                    .keyboardType(.numberPad)
                HStack {
                    Button(action: {
                        alert.toggle()
                        merchantData.merchantMenu.menu.append(merchantItem(name: itemName, price: Int(itemPrice)!))
                        let HTTPSession = HTTPSession()
                        HTTPSession.updateUserInfo(id: appData.userInfo.userID, info: ["itemList": merchantData.returnMenuAsList()])
                        updateView.updateView()
                    }, label: {
                        Text("Add")
                    })
                    Button(role: .cancel, action: {
                        alert.toggle()
                    }, label: {
                        Text("Cancel")
                    })
                }
            })
            if !merchantData.merchantMenu.menu.isEmpty {
                ForEach(merchantData.merchantMenu.menu) {
                    menuElement in
                    var clicked = false
                    HStack {
                        Button(action: {
                            clicked.toggle()
                            if clicked {
                                inList.append(menuElement)
                            } else {
                                inList.removeAll(where: { $0.name == menuElement.name })
                            }
                        }, label: {
                            clicked ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
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
            NavigationLink(destination: MerchantTargetListView(list: inList), label: {
                Text("Confirm")
                    .font(.title)
                    .fontWeight(.bold)
            }).disabled(inList.isEmpty)
        }
    }
}

struct MerchantTargetListView: View {
    var list: [merchantItem]
    @State var quantityList: [String: String] = [:]
    
    var body: some View {
        List {
            ForEach(list) {
                listElement in
                HStack {
                    Text(listElement.name)
                    Spacer()
                    Text(quantityList[listElement.name]!)
                    Button(action: {
                        quantityList[listElement.name] = String(Int(quantityList[listElement.name]!)! + 1)
                    }, label: {
                        Image(systemName: "plus")
                    })
                    Button(action: {
                        if quantityList[listElement.name] != "0" {
                            quantityList[listElement.name] = String(Int(quantityList[listElement.name]!)! - 1)
                        }
                    }, label: {
                        Image(systemName: "minus")
                    })
                }
            }
        }.onAppear(perform: {
            for item in list {
                quantityList[item.getName()] = "1"
            }
        })
    }
}
