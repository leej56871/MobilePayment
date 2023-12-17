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

    var body: some View {
        VStack {
            Spacer()
            STPPaymentCardTextField
                .Representable(paymentMethodParams: $paymentMethodParams)
                .padding()
            Spacer()
            Button(action: {
                let HTTPSession = HTTPSession()
                print(paymentMethodParams?.card?.number)
                print(paymentMethodParams?.card?.cvc)
                print(appData.userInfo.current_client_secret)
            }) {
                Text("Confirm")
            }
            Spacer()
        }
    }
}
