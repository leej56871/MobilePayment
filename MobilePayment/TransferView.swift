//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/19.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State private var amountInput: String = ""
    @State private var amount: Int = 0
    @FocusState private var amountFocused: Bool
    var target: contact
    
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
                Text("Account No. : \(appData.userInfo.getCurrentTarget.accountNumber)")
                    .font(.title)
                    .foregroundColor(Color.black)
                    .fontWeight(.heavy)
                Spacer()
            }
            HStack {
                Text("Current amount : \(appData.userInfo.getCurrentAmount)")
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
//                    .textFieldStyle(.roundedBorder)
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
                    
//                    var HTTPSession = HTTPSession()
//                    HTTPSession.stripeRetrieveUserID(userID: "cus_P2uEhrPXDJxbPG")
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
                appData.userInfo.currentTarget = target
            })
            .background(Color.white)
    }
}

struct TransferView_previews: PreviewProvider {
    static var previews: some View {
        TransferView(target: contact(name: "nil", accountNumber: "nil", memo: "nil")).environmentObject(ApplicationData())
    }
}
