//
//  MerchantMenu.swift
//  MobilePayment
//
//  Created by 이주환 on 2/8/24.
//

import SwiftUI

struct MerchantMenu: View {
    @EnvironmentObject private var merchantData: MerchantData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var alertState: Bool = false
    @State var itemName: String = ""
    @State var itemPrice: String = ""
    
    var body: some View {
        VStack {
            HStack {
                EditButton()
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    alertState = true
                }, label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .fontWeight(.bold)
                }).alert("Add item", isPresented: $alertState, actions: {
                    TextField("Item name", text: $itemName)
                    TextField("Price", text: $itemPrice)
                    Button(action: {
                        alertState = false
                        merchantData.merchantMenu.menu.append(merchantItem(name: itemName, price: Int(itemPrice)!))
                        updateView.updateView()
                    }, label: {
                        Text("Add")
                            .font(.title)
                    })
                    Button(role: .cancel, action: {
                        alertState = false
                    }, label: {
                        Text("Cancel")
                    })
                }).padding()
            }.padding()
        }
        List {
            if !merchantData.merchantMenu.menu.isEmpty {
                ForEach(merchantData.merchantMenu.menu) {
                    menuElement in
                    HStack {
                        Text(menuElement.name)
                        Spacer()
                        Text("\(menuElement.price) HKD")
                    }.padding()
                }
            }
        }
    }
}
