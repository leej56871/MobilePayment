//
//  QRCodeView.swift
//  MobilePayment
//
//  Created by 이주환 on 2023/09/20.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    @EnvironmentObject private var appData: ApplicationData
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
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let seed: String = appData.userInfo.userID + "#" + appData.userInfo.name +  "#" + dateFormatter.string(from: Date()) + "#" + "transaction"
        filter.message = Data(seed.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimage)
            }
        }
        return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
    }
}
