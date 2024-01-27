
//
//  PaymentView.swift
//  MobilePayment
//
//  Created by 이주환 on 1/17/24.
//

import SwiftUI
import Alamofire
import AVFoundation

struct PaymentView: View {
    @EnvironmentObject private var appData: ApplicationData
    @ObservedObject var updateView: UpdateView = UpdateView()
    @State var qrCodeClicked: Bool = true
    @State var permission: Bool = false
    @State var qrCodeScanned: Bool = false
    @State var buttonClicked: Bool = false
    @State var observer: NSObjectProtocol?
    @State var qrCodeURL: String?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    qrCodeClicked.toggle()
                    updateView.updateView()
                }, label: {
                    Text("QR")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }).foregroundStyle(qrCodeClicked ? .gray : .blue)
                    .disabled(qrCodeClicked)
                Divider()
                Button(action: {
                    qrCodeClicked.toggle()
                    updateView.updateView()
                }, label: {
                    Text("ID")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }).foregroundStyle(qrCodeClicked ? .blue : .gray)
                    .disabled(!qrCodeClicked)
            }.frame(maxHeight: 50)
            ZStack {
                if buttonClicked && qrCodeScanned {
                    Text(String(qrCodeURL!))
                } else {
                    VStack {
                        QRCodeScanner()
                        Button(action: {
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("QRCodeURL"), object: nil, queue: nil, using: {
                                notification in
                                qrCodeURL = notification.object as? String
                                qrCodeScanned = true
                            })
                            buttonClicked = true
                            print("CLICKED!")
                        }, label: {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 50))
                        })
                    }
                }
            }
        }
    }
}


struct QRCodeScanner: UIViewControllerRepresentable {
    @StateObject var scannerViewController = QRCodeScannerViewController()
    func makeUIViewController(context: UIViewControllerRepresentableContext<QRCodeScanner>) -> UIViewController {
        return scannerViewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<QRCodeScanner>) {
    }
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ObservableObject {
    @Published var qrCodeScanned = false
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let input = try? AVCaptureDeviceInput(device: captureDevice!)
        captureSession.addInput(input!)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            print("metadataObject is empty!")
            qrCodeScanned = false
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let urlString = metadataObj.stringValue {
                DispatchQueue.main.async {
                    self.qrCodeScanned = true
                    NotificationCenter.default.post(name: Notification.Name("QRCodeURL"), object: urlString)
                }
            } else {
                print("metadataObj stringValue is nil!")
                qrCodeScanned = false
            }
        }
    }
}
