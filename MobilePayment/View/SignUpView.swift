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
    @EnvironmentObject private var updateView: UpdateView
    @State var id: String = ""
    @State var password: String = ""
    @State var name: String = ""
    @State var isMerchant: Bool = false
    @State var errorState: Bool = false
    @State var wrongID: Bool = false
    @State var wrongPassword: Bool = false
    @State var serverOFF: Bool = false
    @State var observer: NSObjectProtocol?
    @State var observer2: NSObjectProtocol?
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea()
            VStack {
                duckFace()
                Spacer()
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    VStack {
                        Text("*** ID and Name should be less than 20 letters")
                            .font(.callout)
                            .foregroundStyle(wrongID ? .red : .black)
                        Text("and cannot use '#', '+', '-', ',', '*'")
                            .font(.callout)
                            .foregroundStyle(wrongID ? .red : .black)
                    }
                    Spacer()
                }.padding()
                HStack {
                    Text("Name : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    TextField("Enter your Name", text: $name)
                        .padding()
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .background(.white)
                }.padding()
                HStack {
                    Text("ID : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    TextField("Enter your ID", text: $id)
                        .padding()
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .background(.white)
                }.padding()
                HStack {
                    Text("Password : ")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    SecureField("Enter your Password", text: $password)
                        .padding()
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .background(.white)
                }.padding()
                HStack {
                    VStack {
                        Text("*** Password must at least be 8 characters")
                            .font(.callout)
                            .foregroundStyle(wrongPassword ? .red : .black)
                        Text("and cannot use'#', '+', '-', ',', '*'")
                            .foregroundStyle(wrongPassword ? .red : .black)
                    }
                    .font(.callout)
                    Spacer()
                }.padding()
                Spacer()
                HStack {
                    Button(action: {
                        isMerchant.toggle()
                    }, label: {
                        HStack {
                            Image(systemName: "square.fill")
                                .foregroundStyle(isMerchant ? .blue : .white)
                                .font(.largeTitle)
                            Text("Are you a merchant?")
                                .font(.title2)
                        }.padding()
                    })
                }.padding()
                Spacer()
                Button(action: {
                    if  id.contains("#") || id.contains("+") || id.contains("-") || id.contains(",") || id.contains("*") || id.count >= 20 || name.contains("#") || name.contains("+") || name.contains("-") || name.contains(",") || name.contains("*") || name.count >= 20 {
                        wrongID = true
                        wrongPassword = false
                        updateView.updateView()
                    } else if password.contains("#") || password.contains(",") || password.contains("*") || password.contains("#") || password.contains("+") || password.contains("-") || password.count < 8 {
                        wrongPassword = true
                        wrongID = false
                        updateView.updateView()
                    } else if password.count < 8 {
                        wrongPassword = true
                        wrongID = false
                        updateView.updateView()
                    } else {
                        wrongID = false
                        wrongPassword = false
                        updateView.updateView()
                        
                        let HTTPSession = HTTPSession()
                        appData.userInfo.name = name
                        HTTPSession.createNewUser(name: name, userID: id, userPassword: password, isMerchant: isMerchant)
                        NotificationCenter.default.addObserver(forName: Notification.Name("error_duplicateUserID"), object: nil, queue: nil, using: {
                            notification in
                            let errorMessage = notification.object as! String
                            if errorMessage.contains("duplicate") {
                                errorState = true
                            } else {
                                serverOFF = true
                            }
                        })
                        observer2 = NotificationCenter.default.addObserver(forName: Notification.Name("newUserInfo"), object: nil, queue: nil, using: {
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
                            NotificationCenter.default.removeObserver(observer2)
                        })
                    }
                }, label: {
                    Text("Confirm")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                }).padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 15)
                    .alert("User ID already in exist!", isPresented: $errorState, actions: {
                        Button(role: .cancel, action: {
                            errorState = false
                        }, label: {
                            Text("Back")
                        })
                    })
                Spacer()
            }.padding()
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
            })
        
    }
}
