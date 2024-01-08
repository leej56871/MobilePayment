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
            Spacer()
            HStack {
                Text("Password : ")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                SecureField("Enter your Password", text: $password)
                    .padding()
            }
            Spacer()
            Button(action: {
                let HTTPSession = HTTPSession()
                appData.userInfo.name = name
                HTTPSession.createNewUser(name: name, userID: id, userPassword: password)
                NotificationCenter.default.addObserver(forName: Notification.Name("newUserInfo"), object: nil, queue: nil, using: {
                    notification in
                    let data = notification.object as! [String: Any]
                    print(data["userID"])
                    appData.userInfo.stripeID = data["stripeID"] as! String
                    appData.userInfo.userID = data["userID"] as! String
                    print("AFTER")
                    print(appData.userInfo.userID)
                    appData.userInfo.logInStatus = 3
                })
            }, label: {
                Text("Confirm")
                    .font(.title)
                    .fontWeight(.bold)
            })
        }.padding()
    }
}
