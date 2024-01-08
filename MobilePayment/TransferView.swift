//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/19.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var amountInput: String = ""
    @State var amount: Int = 0
    @FocusState var amountFocused: Bool
    var userID: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Receiver : \(appData.userInfo.getCurrentTarget.name)")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .fontWeight(.heavy)
                Spacer()
            }
            HStack {
                Text("ID : \(appData.userInfo.getCurrentTarget.userID)")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .fontWeight(.heavy)
                Spacer()
            }
            HStack {
                Text("Balance : \(appData.userInfo.getbalance)")
                    .font(.body)
                    .foregroundColor(Color.black)
                    .fontWeight(.heavy)
                Spacer()
            }.padding()
            
            HStack {
                TextField("", text: $amountInput)
                    .padding()
                    .keyboardType(.numberPad)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)
                    .focused($amountFocused)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 2)))
            }
            
            Spacer()
            Button(action: {
                if !amountInput.isEmpty && amountInput[amountInput.startIndex] != "0" {
                    amount = Int(amountInput)!
                    amountInput = ""
                    amountFocused = false
                    print("Confirm")
                }
                else{
                    amountInput = ""
                    amountFocused = false
                    print("Value is empty or 0")
                }
            }) {
                Text("Confirm")
                    .font(.title)
            }.padding()
                .foregroundColor(Color.white)
                .background(Color("MyColor"))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 3))
                
        }.padding()
            .onAppear(perform: {
//                appData.userInfo.currentTarget = target
            })
            .background(Color.white)
    }
}
