//
//  LogInView.swift
//  MobilePayment
//
//  Created by 이주환 on 12/31/23.
//

import SwiftUI
import Alamofire
import Stripe

struct LogInView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var id: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            VStack {
                Text("Poly Pay")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    Text("ID   : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    TextField("Enter your ID", text: $id)
                        .padding()
                }.padding()
                HStack {
                    Text("PW : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    SecureField("Enter your Password", text: $password)
                        .padding()
                }.padding()
                Spacer()
                Button(action: {
                    let HTTPSession = HTTPSession()
                    HTTPSession.authenticationProcess(userID: id, userPassword: password)
                    NotificationCenter.default.addObserver(forName: Notification.Name("authentication"), object: nil, queue: nil, using: { notification in
                        if notification.object as! String != "ERROR" && notification.object as! String != "No such user in Database!" {
                            appData.userInfo.userID = notification.object as! String
                            HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                            NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                                notification in
                                let updatedInfo = notification.object as! [String: Any]
                                appData.userInfo.updateUserInfo(updatedInfo: updatedInfo)
                                if updatedInfo["isMerchant"] as! Bool {
                                    appData.userInfo.logInStatus = 5
                                } else {
                                    appData.userInfo.logInStatus = 3
                                }
                            })
                        } else {
                            print("LOG IN FAILED")
                            print(notification.object as! String)
                            appData.userInfo.logInStatus = 4
                        }
                    })
                    
                }, label: {
                    Text("Log in")
                        .font(.title)
                        .fontWeight(.bold)
                })
                Spacer()
                    .frame(height: 20)
                NavigationLink(destination: SignUpView(), label: {
                    Text("Sign Up")
                        .font(.title)
                        .fontWeight(.bold)
                }).navigationBarBackButtonHidden(true)
                Spacer()
            }.padding()
        }
    }
}

struct logInFailureView: View {
    @EnvironmentObject private var appData: ApplicationData
    var body: some View {
        VStack {
            Spacer()
            Text("Login Failed!")
            Button(action: {
                appData.userInfo.logInStatus = 1
            }, label: {
                Text("Try Again")
                    .font(.title)
                    .fontWeight(.bold)
            })
            Spacer()
        }
    }
}
