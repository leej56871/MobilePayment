//
//  SplitPayView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/12/24.
//

import SwiftUI

struct SplitPayView: View {
    @EnvironmentObject private var appData: ApplicationData
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    
                }, label: {
                    Text("1/n Pay")
                })
                Divider()
                Button(action: {
                    
                }, label: {
                    Text("Split Pay")
                })
            }.padding()
                .frame(maxHeight: 100)
            Spacer()
        }.customToolBar(currentState: "splitPay")
    }
}
