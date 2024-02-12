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
        Image(uiImage: generateQRCode(appData: appData, list: list, quantityList: quantityList))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 150, height: 150)
    }
    
    func generateQRCode(appData: ApplicationData, list: [merchantItem], quantityList: [String: Int]) -> UIImage {
        var amount = 0
        var itemName = ""
        for item in list {
            amount += quantityList[item.name]! * item.price
            itemName += item.name + "/"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
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

