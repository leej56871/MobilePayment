//
//  HistoryDetailView.swift
//  MobilePayment
//
//  Created by 이주환 on 3/19/24.
//

import SwiftUI

struct HistoryDetailView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var backgroundReady: Bool = false
    @State var detailDict: [String: String] = [:]
    let flag: String
    let detail: String
    let opponent: String
    let amount: String
    let date: String
    let receive: Bool
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                HStack {
                    Text(date)
                        .font(.title2)
                        .fontWeight(.bold)
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange)
                HStack {
                    Spacer()
                    Text(flag == "payment" ? "Payer : " : "Sender : ")
                        .font(.title2)
                    Text(receive ? opponent : "\(appData.userInfo.name)(\(appData.userInfo.userID))")
                        .font(.title2)
                    Spacer()
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange)
                HStack {
                    Spacer()
                    Text(flag == "payment" ? "Payee : " : "Receiver : ")
                        .font(.title2)
                    Text(receive ? "\(appData.userInfo.name)(\(appData.userInfo.userID))" : opponent)
                        .font(.title2)
                    Spacer()
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange)
                HStack {
                    Spacer()
                    Text("Amount : \(amount) HKD")
                        .font(.title2)
                    Spacer()
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange)
                Divider()
                HStack {
                    if detail != "" {
                        VStack {
                            ScrollView {
                                if flag == "payment" {
                                    HStack {
                                        Spacer()
                                        Text("Receipt")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }.padding()
                                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange)
                                    Divider()
                                    ForEach(Array(detailDict.keys), id: \.self) {
                                        itemElement in
                                        HStack {
                                            Spacer()
                                            Text("\(String(itemElement.split(separator: "+")[0]))(\(String(itemElement.split(separator: "+")[1]))HKD)")
                                                .font(.title2)
                                                .padding()
                                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                                            Spacer()
                                            Divider()
                                            Text("Quantity : \(detailDict[itemElement]!)")
                                                .font(.title2)
                                                .padding()
                                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                                            Spacer()
                                        }.padding()
                                    }
                                } else if flag == "dutchSplit" {
                                    HStack {
                                        Spacer()
                                        Text("Payment List")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }.padding()
                                        .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange)
                                    ForEach(Array(detailDict.keys), id: \.self) {
                                        itemElement in
                                        Divider()
                                        HStack {
                                            Spacer()
                                            Text(itemElement)
                                                .font(.title2)
                                                .padding()
                                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                                            Spacer()
                                            Text("\(detailDict[itemElement]!)HKD")
                                                .font(.title2)
                                                .padding()
                                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                                            Spacer()
                                        }
                                        Divider()
                                    }
                                }
                            }
                        }.customBorder(clipShape: "roundedRectangle", color: Color.duck_orange)
                        Spacer()
                    }
                }.padding()
                Spacer()
            }.padding()
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                if flag == "payment" {
                    let detailArray = Array(detail.split(separator: ","))
                    for i in detailArray {
                        detailDict[String(i.split(separator: "*")[0])] = String(i.split(separator: "*")[1])
                    }
                } else if flag == "dutchSplit" {
                    let detailArray = Array(detail.split(separator: ","))
                    for i in detailArray {
                        detailDict["\(String(i.split(separator: "+")[0]))(\(String(i.split(separator: "+")[1].split(separator: "-")[0]))"] = String(i.split(separator: "-")[1])
                    }
                }
                backgroundReady = true
            })
    }
}
