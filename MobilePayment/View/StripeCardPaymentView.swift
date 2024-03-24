//
//  StripeCardPayment.swift
//  MobilePayment
//
//  Created by 이주환 on 12/16/23.
//

import SwiftUI
import Stripe

struct StripeCardPaymentView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var paymentMethodParams: STPPaymentMethodParams?
    @State var paymentIntentParams: STPPaymentIntentParams?
    @State var isConfirm: Bool = false
    @State var processLoading: Bool = false
    @State var tag: Int?
    @State var observer: NSObjectProtocol?
    var chargeAmount: String
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                if tag == 1 {
                    NavigationLink(destination: MainView(), tag: 1, selection: self.$tag) {
                        MainView()
                    }.navigationBarBackButtonHidden(true)
                }
                else if tag == 2 {
                    resultView(tag: 2)
                }
                else if tag == 3 {
                    resultView(tag: 3)
                }
                else {
                    VStack {
                        Text("Amount : \(chargeAmount) HKD")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        STPPaymentCardTextField
                            .Representable(paymentMethodParams: $paymentMethodParams)
                            .padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.white, radius: 5)
                        Spacer()
                        if !processLoading {
                            HStack {
                                Spacer()
                                Button(action: {
                                    isConfirm = true
                                }, label: {
                                    Text("Charge")
                                        .font(.title)
                                        .foregroundStyle(.blue)
                                }).padding()
                                    .alert("Charge \(chargeAmount) HKD?", isPresented: $isConfirm, actions: {
                                        HStack {
                                            Button(action: {
                                                paymentIntentParams = STPPaymentIntentParams(clientSecret: appData.userInfo.current_client_secret!)
                                                paymentIntentParams!.paymentMethodParams = paymentMethodParams
                                                processLoading = true
                                                isConfirm = false
                                            }, label: {
                                                Text("Yes")
                                                    .font(.title)
                                            })
                                            Button(role: .cancel, action: {
                                                isConfirm = false
                                                processLoading = false
                                            }, label: {
                                                Text("No")
                                            })
                                        }.padding()
                                    })
                                    .customBorder(clipShape: "capsule", color: Color.duck_orange, borderColor: Color.duck_orange)
                                Spacer()
                                NavigationLink(destination: MainView(), label: {
                                    Text("Cancel")
                                        .font(.title)
                                        .foregroundStyle(.blue)
                                }).padding()
                                    .customBorder(clipShape: "capsule", color: Color.duck_orange, borderColor: Color.duck_orange)
                                Spacer()
                            }.padding()
                        }
                        else {
                            Button("Loading") {
                            }.paymentConfirmationSheet(isConfirmingPayment: $processLoading, paymentIntentParams: paymentIntentParams!, onCompletion: {
                                (status, paymentIntent, error) in
                                switch(status) {
                                case .succeeded:
                                    processLoading = false
                                    tag = 2
                                    let HTTPSession = HTTPSession()
                                    let addedAmount = appData.userInfo.balance + Int(chargeAmount)!
                                    HTTPSession.updateUserInfo(id: appData.userInfo.userID, info: ["balance" : addedAmount])
                                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("updatedUserInfo"), object: nil, queue: nil, using: {
                                        notification in
                                        HTTPSession.retrieveUserInfo(id: appData.userInfo.userID)
                                        observer = NotificationCenter.default.addObserver(forName: Notification.Name("userInfo"), object: nil, queue: nil, using: {
                                            notification in
                                            let updatedInfo = notification.object as! [String: Any]
                                            appData.userInfo.updateUserInfo(updatedInfo: updatedInfo)
                                            NotificationCenter.default.removeObserver(observer)
                                        })
                                        NotificationCenter.default.removeObserver(observer)
                                    })
                                    
                                case .failed:
                                    processLoading = false
                                    let HTTPSession = HTTPSession()
                                    HTTPSession.stripeCancelPaymentIntent(intent_id: appData.userInfo.current_intent_id!)
                                    tag = 3
                                    
                                case .canceled:
                                    processLoading = false
                                    tag = 1
                                }
                                
                            })
                        }
                        Spacer()
                    }.padding()
                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, borderColor: Color.duck_light_orange)
                }
            }
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
                let HTTPSession = HTTPSession()
                HTTPSession.stripeRequestPaymentIntent(stripeID: appData.userInfo.stripeID, paymentMethodType: "pm_card_visa", currency: "hkd", amount: chargeAmount)
                NotificationCenter.default.addObserver(forName: Notification.Name("client_secret"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.current_client_secret = notification.object as? String
                })
                NotificationCenter.default.addObserver(forName: Notification.Name("intent_id"), object: nil, queue: nil, using: {
                    notification in
                    appData.userInfo.current_intent_id = notification.object as? String
                })
            })
            .onDisappear(perform: {
                let HTTPSession = HTTPSession()
                HTTPSession.stripeCancelPaymentIntent(intent_id: appData.userInfo.current_intent_id!)
            })
    }
}

struct resultView: View {
    @State var tag: Int
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                if tag == 2 {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Successfully Done!")
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        Spacer()
                        NavigationLink(destination: TransferHistoryView(), label: {
                            Text("Return")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }).padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10, borderColor: Color.duck_orange)
                    }.padding()
                        .background(Color.duck_light_orange)
                }
                else if tag == 3 {
                    VStack {
                        Text("Failed")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        HStack {
                            NavigationLink(destination: ChargeView()) {
                                Text("Try again")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            }.navigationBarBackButtonHidden(true)
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10, borderColor: Color.duck_orange)
                            Spacer()
                            NavigationLink(destination: MainView()) {
                                Text("Back")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            }.navigationBarBackButtonHidden(true)
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10, borderColor: Color.duck_orange)
                        }.padding()
                    }.padding()
                }
                else if tag == 1 {
                    VStack {
                        Text("Canceled!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        NavigationLink(destination: MainView(), label: {
                            Text("Return")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }).padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10, borderColor: Color.duck_orange)
                    }
                }
            }.padding()
        }.padding()
            .background(Color.duck_light_yellow)
    }
}
