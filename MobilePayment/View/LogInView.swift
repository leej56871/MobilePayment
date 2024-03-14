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
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                }.padding()
                HStack {
                    Text("PW : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    SecureField("Enter your Password", text: $password)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
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
        }.onAppear(perform: {
            UIApplication.shared.hideKeyboard()
        })
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
            })
            Spacer()
        }
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
        }.padding()
    }
}
