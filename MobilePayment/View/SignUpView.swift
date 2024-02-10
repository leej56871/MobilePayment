//
//  SignUpView.swift
//  MobilePayment
//
//  Created by 이주환 on 12/31/23.
//

import SwiftUI
import Stripe
import Alamofire

struct SignUpView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var id: String = ""
    @State var password: String = ""
    @State var name: String = ""
    @State var isMerchant: Bool = false
    @State var errorState: Bool = false
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            HStack {
                Text("Name : ")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                TextField("Enter your Name", text: $name)
                    .padding()
            }
            HStack {
                Text("ID : ")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                TextField("Enter your ID", text: $id)
                    .padding()
            }
            HStack {
                Text("Password : ")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                SecureField("Enter your Password", text: $password)
                    .padding()
            }
            Spacer()
            HStack {
                Button(action: {
                    isMerchant.toggle()
                }, label: {
                    Image(systemName: isMerchant ? "square.fill" : "square")
                        .font(.largeTitle)
                })
                Text("Are you a merchant?")
                    .font(.title2)
            }.padding()
            Spacer()
            Button(action: {
                let HTTPSession = HTTPSession()
                appData.userInfo.name = name
                HTTPSession.createNewUser(name: name, userID: id, userPassword: password, isMerchant: isMerchant)
                NotificationCenter.default.addObserver(forName: Notification.Name("error_duplicateUserID"), object: nil, queue: nil, using: {
                    notification in
                    if notification.object as! Bool == true {
                        print("ERROR_DUPLICATEUSERID")
                        errorState = true
                    }
                })
                
                NotificationCenter.default.addObserver(forName: Notification.Name("newUserInfo"), object: nil, queue: nil, using: {
                    notification in
                    let data = notification.object as! [String: Any]
                    appData.userInfo.stripeID = data["stripeID"] as! String
                    appData.userInfo.userID = data["userID"] as! String
                    appData.userInfo.isMerchant = data["isMerchant"] as! Bool
                    if data["isMerchant"] as! Bool {
                        appData.userInfo.logInStatus = 5
                    } else {
                        appData.userInfo.logInStatus = 3
                    }
                })
            }, label: {
                Text("Confirm")
                    .font(.title)
                    .fontWeight(.bold)
            }).alert("User ID already in exist!", isPresented: $errorState, actions: {
                Button(role: .cancel, action: {
                    errorState = false
                }, label: {
                    Text("Back")
                })
            })
        }.padding()
    }
}
