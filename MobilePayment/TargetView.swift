//
//  TargetView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/19.
//

import SwiftUI

struct TargetView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State private var contactClicked: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    contactClicked.toggle()
                }) {
                    Text("Insert Payee Detail")
                        .font(.title)
                        .foregroundColor(Color.black)
                        .fontWeight(.heavy)
                }.padding()
                    .buttonStyle(BorderlessButtonStyle())
                Button(action: {
                    contactClicked.toggle()
                }) {
                    Text("Contact")
                        .font(.title)
                        .foregroundColor(Color.black)
                        .fontWeight(.heavy)
                }.padding()
                    .buttonStyle(BorderlessButtonStyle())
            }.overlay(RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 2)))
            
            ZStack {
                payeeDetailView()
                    .opacity(contactClicked ? 0 : 1)
                ContactView()
                    .opacity(contactClicked ? 1 : 0)
            }
        }.padding()
            .background(Color.white)
    }
}

struct payeeDetailView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State private var userInput: String = ""
    @FocusState private var focusState: Bool
    
    var body: some View {
        VStack {
            TextField("Accout Number", text: $userInput)
                .padding()
                .keyboardType(.numberPad)
                .lineLimit(1)
                .focused($focusState)
                .font(.largeTitle)
                .fontWeight(.heavy)
//                .textFieldStyle(.roundedBorder)
                .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 2)))
            
            
            Spacer()
            
            Button(action: {
                if !userInput.isEmpty && userInput.count == 12 { // also whether it is valid account number from node.js
                    focusState = false
                    appData.userInfo.currentTarget = contact(name: "get from node.js", accountNumber: userInput, memo: "")
                    userInput = ""
                }
                else {
                    print("Invalid account")
                    userInput = ""
                    focusState = false
                }
            }) {
                Text("Confirm")
                    .font(.title)
                    
            }.padding()
                .foregroundColor(Color.black)
//                .background(Color("MyColor"))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 3))
        }
    }
}

struct TargetView_previews: PreviewProvider {
    static var previews: some View {
        TargetView().environmentObject(ApplicationData())
    }
}
