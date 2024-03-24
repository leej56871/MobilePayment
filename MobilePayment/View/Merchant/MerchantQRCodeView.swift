//
//  MerchantQRCodeView.swift
//  MobilePayment
//
//  Created by 이주환 on 2/8/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct MerchantQRCodeView: View {
    @EnvironmentObject private var appData: ApplicationData
    @EnvironmentObject private var merchantData: MerchantData
    let list: [merchantItem]
    let quantityList: [String: Int]
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                duckFace()
                Spacer()
                Text("Receipt")
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange)
                List {
                    ForEach(list, id: \.self) {
                        item in
                        HStack {
                            Spacer()
                            Text("\(item.name)(\(item.price)HKD)")
                                .font(.title)
                            Divider()
                            Text("x \(quantityList[item.name]!)")
                                .font(.title)
                            Spacer()
                        }.padding()
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                    }.listRowBackground(Color.duck_light_orange)
                }.scrollContentBackground(.hidden)
                    .background(Color.duck_light_orange)
                Image(uiImage: generateQRCode(appData: appData, list: list, quantityList: quantityList))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                Spacer()
            }.background(Color.duck_light_yellow)
        }
    }
    
    func generateQRCode(appData: ApplicationData, list: [merchantItem], quantityList: [String: Int]) -> UIImage {
        var amount = 0
        var itemName = ""
        for item in list {
            amount += quantityList[item.name]! * item.price
            itemName += String(item.name) + "+" + String(item.price) + "*" + String(quantityList[item.name]!) + ","
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let seed: String = appData.userInfo.userID + "#" + appData.userInfo.name +  "#" + dateFormatter.string(from: Date()) + "#" + "payment" + "#" + String(amount) + "#" + itemName
        filter.message = Data(seed.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimage)
            }
        }
        return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
    }
}

