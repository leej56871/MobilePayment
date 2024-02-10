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
    @State var amount: Int
    @State var item: String
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        Image(uiImage: generateQRCode(appData: appData, amount: amount, item: item))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 150, height: 150)
    }
    
    func generateQRCode(appData: ApplicationData, amount: Int, item: String) -> UIImage {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let seed: String = appData.userInfo.userID + "#" + appData.userInfo.name +  "#" + dateFormatter.string(from: Date()) + "#" + "payment" + "#" + String(amount) + "#" + item
        filter.message = Data(seed.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimage)
            }
        }
        return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
    }
}

