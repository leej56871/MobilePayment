//
//  TransferView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/14.
//

import SwiftUI

struct TransferHistoryView: View {
    @EnvironmentObject private var appData: ApplicationData

    var body: some View {
        NavigationStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Acc.")
                        .font(.body)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                    Text(appData.userInfo.getAccountNumber)
                        .font(.body)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.white)
                }
                Spacer()
                Text(moneyFormat(money: Int(appData.userInfo.getbalance )!) + " HKD")
                    .lineLimit(1)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                
            }.padding()
                .background(Color("MyColor"))
                .cornerRadius(5)
            
            Spacer()
                .background(Color.clear)
            
            transferPaymentButton()
            
            Divider()
            
            transferHistoryView()
        }.padding()
            .background(Color.white)

        
    }
}

func moneyFormat(money: Int) -> String {
    let numberFormatter: NumberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter.string(from: NSNumber(value: money))!
}

struct transferPaymentButton: View {
    
    var body: some View {
        Divider()
        HStack {
            Spacer()
            NavigationLink(destination: TargetView()) {
                Text("Transfer")
                    .font(.title)
                    .foregroundColor(Color("MyColor"))
            }.buttonBorderShape(.roundedRectangle)
            
            Spacer()
            Divider()
            Spacer()
            
            NavigationLink(destination: Text("Payment")) {
                Text("Payment")
                    .font(.title)
                    .foregroundColor(Color("MyColor"))
            }.buttonBorderShape(.roundedRectangle)
            
            Spacer()
        }.background(Color.white)
            .cornerRadius(10)
            .frame(height: 50)
    }
}

struct transferHistoryView: View {
    @EnvironmentObject var appData: ApplicationData

    var body: some View {
        ScrollView {
            Button(action: {}){
                
                Image(systemName: "doc.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                
            }
            
            Button (action: { appData.userInfo.balance += 1000000}) {
                Image(systemName: "doc.fill.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(Color.red)
            }
            LazyVStack {
//                ForEach(appData.userInfo.getTransferHistoryDict["default"]!) { history in
//                    history
//                    
//                }
            }
        }.customToolBar(currentState: "transfer")
            .background(Color.white)
            .cornerRadius(5)
    }

}
