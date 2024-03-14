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
        VStack {
            Text("Charge Method")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            NavigationLink(destination: StripeChargeView().customToolBar(currentState: "others", isMerchant: appData.userInfo.isMerchant).navigationBarBackButtonHidden(true), label: {
                Text("Stripe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }).navigationBarBackButtonHidden(true)
            Spacer()
        }.padding()
            .customToolBar(currentState: "transfer", isMerchant: appData.userInfo.isMerchant)
    }
}

struct StripeChargeView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var amountInput: String = ""
    
    var body: some View {
        VStack {
            Text("Balance : \(appData.userInfo.getbalance) HKD")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            TextField("", text: $amountInput)
                .padding()
                .keyboardType(.numberPad)
                .lineLimit(1)
                .font(.largeTitle)
                .fontWeight(.bold)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 2)
                    )
            Spacer()
            NavigationLink(destination: StripeCardPaymentView(chargeAmount: amountInput).navigationBarBackButtonHidden(true), label: {
                Text("Proceed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }).navigationBarBackButtonHidden(true)
        }.padding()
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
            })
    }
}
