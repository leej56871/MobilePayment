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
        ScrollView {
            LazyVStack {
                Spacer()
                NavigationLink(destination: StripeChargeView(), label: {
                    Text("Stripe")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                })
            }
        }
    }
}

struct StripeChargeView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var amountInput: String = ""
    @FocusState var amountFocused: Bool
    var body: some View {
        VStack {
            Text("Balance : \(appData.userInfo.getCurrentAmount) HKD")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            TextField("", text: $amountInput)
                .padding()
                .keyboardType(.numberPad)
                .lineLimit(1)
                .focused($amountFocused)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.black, style: StrokeStyle(lineWidth: 2)))
            Spacer()
            NavigationLink(destination: StripeCardPaymentView(chargeAmount: amountInput), label: {
                Text("Proceed")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            })
        }.padding()
    }
}
