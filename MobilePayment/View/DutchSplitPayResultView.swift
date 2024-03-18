//
//  DutchSplitPayResultView.swift
//  MobilePayment
//
//  Created by 이주환 on 3/4/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct DutchSplitPayResultView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var updateView: UpdateView
    @EnvironmentObject private var socketSession: SocketSession
    @State var invitedIDandAmount: [String: String]
    @State var invitedIDandName: [String: String]
    @State var respondedList: [String]
    @State var invitorMessage: String
    @State var cancel: Bool = false
    @State var backgroundReady: Bool = false
    @State var receiptString: String = ""
    @State var observer: NSObjectProtocol?
    @State var isPaymentDone: Bool = false
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                if !cancel && backgroundReady && !isPaymentDone {
                    HStack {
                        Button(action: {
                            for i in respondedList {
                                socketSession.sendMessage(message: "deleteRoom:\(appData.userInfo.userID):\(i):\(invitorMessage)")
                            }
                            cancel = true
                        }, label: {
                            Image(systemName: "x.square")
                                .font(.title)
                                .foregroundStyle(.red)
                        })
                        Spacer()
                    }.padding()
                    Spacer()
                    ScrollView {
                        ForEach(respondedList, 
                                id: \.self) {
                            user in
                            HStack {
                                Text("\(invitedIDandName[user]!)(\(user))")
                                Spacer()
                                Text("\(invitedIDandAmount[user]!) HKD")
                            }.padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: CGFloat(10))
                                        .stroke(Color.duck_light_orange, lineWidth: 6)
                                )
                                .background(Color.duck_light_orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }.padding()
                    Divider()
                    DutchSplitQRCodeView(receiptString: receiptString)
                    Spacer()
                } else if cancel {
                    Text("You have canceled the Payment")
                    NavigationLink(destination: MainView(), label: {
                        Text("Go back")
                            .font(.title)
                    }).navigationBarBackButtonHidden(true)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: CGFloat(10))
                                .stroke(Color.duck_light_orange, lineWidth: 6)
                        )
                        .background(Color.duck_light_orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else if isPaymentDone {
                    VStack {
                        Text("Payment Process Done!")
                            .font(.title)
                        Spacer()
                        NavigationLink(destination: MainView(), label: {
                            Text("Go back")
                                .font(.title)
                        }).navigationBarBackButtonHidden(true)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: CGFloat(10))
                                    .stroke(Color.duck_light_orange, lineWidth: 6)
                            )
                            .background(Color.duck_light_orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                receiptString = "\(appData.userInfo.userID)#"
                for i in respondedList {
                    let temp = invitedIDandName[i]! + "+" + i + "-" + invitedIDandAmount[i]! + ","
                    receiptString += temp
                    socketSession.sendMessage(message: "lock:\(appData.userInfo.userID):\(i)")
                }
                receiptString.removeLast()
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateInString = dateFormatter.string(from: date)
                receiptString += "#" + dateInString
                NotificationCenter.default.addObserver(forName: Notification.Name("\(appData.userInfo.userID)qrScannedByMerchant"), object: nil, queue: nil, using: {
                    notification in
                    let merchantID = notification.object as! String
                    let HTTPSession = HTTPSession()
                    HTTPSession.dutchSplitProcess(action: "payment", message: receiptString, invitorID: appData.userInfo.userID, merchantID: merchantID)
                    observer = NotificationCenter.default.addObserver(forName: Notification.Name("\(appData.userInfo.userID)payment"), object: nil, queue: nil, using: {
                        notification in
                        isPaymentDone = true
                        socketSession.sendMessage(message: "paymentFinished:\(appData.userInfo.userID):\(merchantID)")
                        isPaymentDone = true
                        updateView.updateView()
                        NotificationCenter.default.removeObserver(observer)
                    })
                })
                backgroundReady = true
            })
            .onDisappear(perform: {
                for i in respondedList {
                    socketSession.sendMessage(message: "deleteRoom:\(appData.userInfo.userID):\(i):\(invitorMessage)")
                }
            })
    }
}

struct DutchSplitQRCodeView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var receiptString: String
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        Image(uiImage: generateQRCode(appData: appData))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 150, height: 150)
    }
    
    func generateQRCode(appData: ApplicationData) -> UIImage {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let seed: String = appData.userInfo.userID + "#" + appData.userInfo.name + "#" + "split" + "#" + receiptString.split(separator: "#")[1] + "#" + receiptString.split(separator: "#")[2]
        filter.message = Data(seed.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimage)
            }
        }
        return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
    }
}

