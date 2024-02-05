
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
    @State var flag: String?

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
                    if flag == "transaction" {
                        qrCodeUserProfile(name: String((qrCodeURL!.split(separator: "#")[1])), id: String((qrCodeURL!.split(separator: "#")[0])))
                    } else if flag == "payment" {
                        
                    } else {
                        VStack {
                            Text("Invalid QR Code")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Button(action: {
                                buttonClicked = false
                                qrCodeScanned = false
                            }, label: {
                                Text("Back")
                                    .font(.title)
                                    .fontWeight(.bold)
                            })
                        }.padding()
                    }
                } else {
                    VStack {
                        QRCodeScanner()
                        Button(action: {
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("QRCodeURL"), object: nil, queue: nil, using: {
                                notification in
                                let temp = notification.object as? String
                                let count = temp?.filter { $0 == "#" }.count
                                if count == 3 {
                                    qrCodeURL = notification.object as? String
                                    if String((qrCodeURL!.split(separator: "#")[0])) == appData.userInfo.userID {
                                        flag = "invalid"
                                    } else {
                                        let id = String((qrCodeURL!.split(separator: "#")[0]))
                                        let HTTPSession = HTTPSession()
                                        HTTPSession.friendProcess(action: "searchOneFromQRCode", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: id)
                                        flag = String((qrCodeURL?.split(separator: "#")[3])!)
                                    }
                                    qrCodeScanned = true
                                } else {
                                    qrCodeURL = ""
                                    flag = "invalid"
                                }
                                NotificationCenter.default.removeObserver(observer)
                            })
                            
                            observer = NotificationCenter.default.addObserver(forName: Notification.Name("searchOneFromQRCode"), object: nil, queue: nil, using: {
                                notification in
                                let temp = notification.object as! [[String: Any]]
                                if temp.isEmpty {
                                    flag = "no user in database"
                                } else {
                                    let tempElement = temp[0]
                                    appData.userInfo.currentTarget = contact(name: tempElement["name"] as! String, userID: tempElement["userID"] as! String)
                                    appData.userInfo.currentTargetBalance = tempElement["balance"] as! Int
                                }
                                NotificationCenter.default.removeObserver(observer)
                            })
                            
                            buttonClicked = true
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

struct qrCodeUserProfile: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var name: String
    @State var id: String
    @State var sentFriend: Bool = false
    @State var observer: NSObjectProtocol?

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(id)
                    .font(.title)
                Spacer()
                VStack {
                    Spacer()
                    NavigationLink(destination: TransferFromQRView(), label: {
                        Text(" Transfer ")
                            .font(.largeTitle)
                                .fontWeight(.bold)
                        })
                    if (!appData.userInfo.contactBook.contains(where: {
                        contact in
                        return contact.userID == id
                    }) && !(appData.userInfo.favContactBook.contains(where: {
                        contact in
                        return contact.userID == id
                    }))) {
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.friendProcess(action: "send", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: id)
                                sentFriend = true
                        }, label: {
                            Text("Add Friend")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }).disabled(sentFriend)
                        Spacer()
                    }
                }.padding()
                Spacer()
            }
        }.padding()
    }
}

//struct merchantPaymentView: View {
//    var body: some View {
//        
//    }
//}

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
