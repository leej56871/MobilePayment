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
    @ObservedObject var httpSession = HTTPSession()
    @State var paymentMethodParams: STPPaymentMethodParams?
    @State var paymentIntentParams: STPPaymentIntentParams?
    @State var processLoading: Bool = false
    @State var tag: Int?
    var chargeAmount: String
    
    var body: some View {
        ZStack {
            if tag == 1 {
                NavigationLink(destination: MainView(), tag: 1, selection: self.$tag) {
                    MainView()
                }
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
                    Spacer()
                    
                    if !processLoading {
                        HStack {
                            Spacer()
                            Button("Charge") {
                                paymentIntentParams = STPPaymentIntentParams(clientSecret: appData.userInfo.current_client_secret!)
                                paymentIntentParams!.paymentMethodParams = paymentMethodParams
                                processLoading = true
                                tag = 1
                            }
                            Spacer()
                            Button("Cancel") {
                                let HTTPSession = HTTPSession()
                                HTTPSession.stripeCancelPaymentIntent(id: appData.userInfo.current_intent_id!)
                                tag = 1
                            }
                            Spacer()
                        }.padding()
                    }
                    else {
                        Button("Loading") {
                        }.paymentConfirmationSheet(isConfirmingPayment: $processLoading, paymentIntentParams: paymentIntentParams!, onCompletion: {
                            (status, paymentIntent, error) in
                            switch(status) {
                            case .succeeded:
                                print("Payment Successful!")
                                processLoading = false
                                tag = 1
                                
                            case .failed:
                                print("Payment Failed!")
                                print(error)
                                processLoading = false
                                tag = 1
                                
                            case .canceled:
                                print("Payment Canceled!")
                                processLoading = false
                                tag = 1
                            }
                            
                        })
                    }
                    Spacer()
                }.padding()
                    .onAppear(perform: {
                        let HTTPSession = HTTPSession()
                        HTTPSession.stripeRequestPaymentIntent(userID: "cus_P2uEhrPXDJxbPG", paymentMethodType: "pm_card_visa", currency: "hkd", amount: chargeAmount)
                        NotificationCenter.default.addObserver(forName: Notification.Name("client_secret"), object: nil, queue: nil, using: {
                            notification in
                            print("This is notificaiton.object")
                            print(notification.object)
                            appData.userInfo.current_client_secret = notification.object as? String
                        })
                        NotificationCenter.default.addObserver(forName: Notification.Name("id"), object: nil, queue: nil, using: {
                            notification in
                            print("This is notification.object")
                            print(notification.object)
                            appData.userInfo.current_intent_id = notification.object as? String
                        })
                    })
            }
        }
    }
}
