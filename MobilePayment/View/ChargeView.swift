//
//  ChargeView.swift
//  MobilePayment
//
//  Created by 이주환 on 12/23/23.
//

import SwiftUI
import Stripe

struct ChargeView: View {
    @EnvironmentObject private var appData: ApplicationData
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                Text("Charge Method")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink(destination: StripeChargeView().customToolBar(currentState: "others", isMerchant: appData.userInfo.isMerchant).navigationBarBackButtonHidden(true), label: {
                    Text("Stripe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }).navigationBarBackButtonHidden(true)
                    .padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                Spacer()
            }
        }.padding()
            .customToolBar(currentState: "transfer", isMerchant: appData.userInfo.isMerchant)
            .background(Color.duck_light_yellow)
    }
}

struct StripeChargeView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var amountInput: String = ""
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                Text("Balance : \(appData.userInfo.getbalance) HKD")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                HStack {
                    TextField("", text: $amountInput)
                        .padding()
                        .keyboardType(.numberPad)
                        .lineLimit(1)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .customBorder(clipShape: "roundedRectangle", color: .white, radius: 5)
                        .background(.white)
                }.padding()
                Spacer()
                NavigationLink(destination: StripeCardPaymentView(chargeAmount: amountInput).navigationBarBackButtonHidden(true), label: {
                    Text("Proceed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }).navigationBarBackButtonHidden(true)
                    .padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
            }.padding()
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
            })
    }
}
