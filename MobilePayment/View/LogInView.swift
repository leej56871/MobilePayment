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
    @State var wrongID: Bool = false
    @State var wrongPassword: Bool = false
    @State var observer: NSObjectProtocol?
    @State var observer2: NSObjectProtocol?
    
    var body: some View {
        VStack {
            VStack {
                duckFace()
                Spacer()
                HStack {
                    Text("ID   : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    TextField("Enter your ID", text: $id)
                        .padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 10)
                        .background(Color.white)
                }.padding()
                HStack {
                    Text("PW : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    SecureField("Enter your Password", text: $password)
                        .padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 10)
                        .background(Color.white)
                }.padding()
                Spacer()
                Button(action: {
                    let HTTPSession = HTTPSession()
                    HTTPSession.authenticationProcess(userID: id, userPassword: password)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("authentication"), object: nil, queue: nil, using: { notification in
                        if notification.object as! String != "ERROR" && notification.object as! String != "No such user in Database!" {
                            appData.userInfo.userID = notification.object as! String
                            HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                            observer2 = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                                notification in
                                let updatedInfo = notification.object as! [String: Any]
                                appData.userInfo.updateUserInfo(updatedInfo: updatedInfo)
                                if updatedInfo["isMerchant"] as! Bool {
                                    appData.userInfo.logInStatus = 5
                                } else {
                                    appData.userInfo.logInStatus = 3
                                }
                                NotificationCenter.default.removeObserver(observer2)
                            })
                        } else if notification.object as! String == "No such user in Database!" {
                            appData.userInfo.logInStatus = 4
                        } else if notification.object as! String == "ERROR" {
                            appData.userInfo.logInStatus = 6
                        }
                        NotificationCenter.default.removeObserver(observer)
                    })
                    id = ""
                    password = ""
                }, label: {
                    Text("Log in")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                }).padding()
                    .customBorder(clipShape: "capsule", color: Color.duck_orange, radius: 10)
                
                Spacer()
                    .frame(height: 20)
                NavigationLink(destination: SignUpView(), label: {
                    Text("Sign Up")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                }).padding()
                    .navigationBarBackButtonHidden(true)
                    .customBorder(clipShape: "capsule", color: Color.duck_orange, radius: 10)
                Spacer()
            }.padding()
        }.onAppear(perform: {
            UIApplication.shared.hideKeyboard()
        })
        .background(Color.duck_light_yellow)
    }
}

struct logInFailureView: View {
    @EnvironmentObject private var appData: ApplicationData
    var body: some View {
        VStack {
            Spacer()
            Text("Wrong user id or password!")
                .font(.largeTitle)
            Button(action: {
                appData.userInfo.logInStatus = 1
            }, label: {
                Text("Try Again")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
            }).padding()
                .customBorder(clipShape: "capsule", color: Color.duck_orange, radius: 10)
            Spacer()
        }.frame(maxWidth: .infinity)
            .padding()
            .background(Color.duck_light_yellow)
    }
}

struct connectionFailureView: View {
    @EnvironmentObject private var appData: ApplicationData
    
    var body: some View {
        VStack {
            Spacer()
            Text("Problem in connection or server!")
                .font(.title)
                .fontWeight(.bold)
            Text("If the problem continues, please contact the developer!")
                .font(.title3)
            Spacer()
            Button(action: {
                exit(0)
            }, label: {
                Text("Exit app")
                    .font(.title3)
            })
        }.frame(maxWidth: .infinity)
        .padding()
    }
}
