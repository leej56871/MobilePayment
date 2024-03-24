
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
    @EnvironmentObject private var updateView: UpdateView
    @State var permission: Bool = false
    @State var qrCodeScanned: Bool = false
    @State var buttonClicked: Bool = false
    @State var observer: NSObjectProtocol?
    @State var qrCodeURL: String?
    @State var flag: String?

    var body: some View {
        VStack {
            duckFace()
            Spacer()
            HStack {
                Text("Scan QR Code")
                .font(.largeTitle)
                .fontWeight(.bold)
            }.frame(maxHeight: 50)
            ZStack {
                if buttonClicked && qrCodeScanned {
                    if flag == "transaction" {
                        qrCodeUserProfile(name: String((qrCodeURL!.split(separator: "#")[1])), id: String((qrCodeURL!.split(separator: "#")[0])))
                    } else if flag == "payment" {
                        merchantPaymentView(name: String(qrCodeURL!.split(separator: "#")[1]), id: String(qrCodeURL!.split(separator: "#")[0]), amount: Int(qrCodeURL!.split(separator: "#")[4])!, item: String(qrCodeURL!.split(separator: "#")[5]), date: String(qrCodeURL!.split(separator: "#")[2]))
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
                                } else if count == 5 {
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
                                }
                                else {
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
        }.padding()
            .background(Color.duck_light_yellow)
    }
}

struct qrCodeUserProfile: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var name: String
    @State var id: String
    @State var sentFriend: Bool = false
    @State var observer: NSObjectProtocol?

    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Name : ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                HStack {
                    Spacer()
                    Text("ID : ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(id)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }.padding()
                    .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                Spacer()
                VStack {
                    Spacer()
                    NavigationLink(destination: TransferFromQRView(id: id, name: name), label: {
                        Text(" Transfer ")
                            .padding()
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                    })
                    if !appData.userInfo.contactBook.contains(where: {
                        contact in
                        return contact.userID == id
                    }) && !(appData.userInfo.favContactBook.contains(where: {
                        contact in
                        return contact.userID == id
                    })) && !(appData.userInfo.friendSend.contains(where: {
                        contact in
                        return contact.userID == id
                    })) {
                        Button(action: {
                            let HTTPSession = HTTPSession()
                            HTTPSession.friendProcess(action: "send", name: appData.userInfo.name, myID: appData.userInfo.userID, friendID: id)
                                sentFriend = true
                        }, label: {
                            Text("Add Friend")
                                .padding()
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }).disabled(sentFriend)
                            .customBorder(clipShape: "roundedRectangle", color: Color.duck_orange, radius: 10)
                        Spacer()
                    }
                    Spacer()
                }.padding()
            }
        }.padding()
            .background(Color.duck_light_yellow)
            .onAppear(perform: {
                if appData.userInfo.friendSend.contains(where: {
                    $0.userID == id
                }) {
                    sentFriend = true
                }
            })
    }
}

struct merchantPaymentView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var name: String
    @State var id: String
    @State var amount: Int
    @State var item: String
    @State var date: String
    @State var itemDict: [String: String] = [:]
    @State var backgroundReady: Bool = false
    
    func dateValidificator(date: String) -> Bool {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        let endDate = Date(timeInterval: 90, since: format.date(from: date)!)
        
        if endDate.timeIntervalSince(Date()) > 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        ZStack {
            Color.duck_light_yellow
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                if dateValidificator(date: date) && amount <= appData.userInfo.balance && backgroundReady {
                    VStack {
                        ScrollView {
                            ForEach(Array(itemDict.keys), id: \.self) {
                                key in
                                HStack {
                                    Text("\(String(itemDict[key]!)) x ")
                                    Divider()
                                    Text(String(key.split(separator: "+")[0]))
                                        .font(.callout)
                                    Text("(\(String(key.split(separator: "+")[1]))HKD)")
                                        .font(.callout)
                                }.padding()
                            }.customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        }
                        Text("Total : \(amount)HKD")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                    }
                    Divider()
                    HStack {
                        NavigationLink(destination: merchantPaymentProcessView(merchantID: id, amount: amount, item: item), label: {
                            Text("Confirm")
                                .padding()
                                .font(.title)
                                .fontWeight(.bold)
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        })
                        NavigationLink(destination: MainView(), label: {
                            Text(" Cancel")
                                .padding()
                                .font(.title)
                                .fontWeight(.bold)
                                .customBorder(clipShape: "roundedRectangle", color: Color.duck_light_orange, radius: 10)
                        })
                    }.padding()
                } else if amount > appData.userInfo.balance {
                    Text("Amount out of balance!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else if !dateValidificator(date: date) {
                    Text("QR code is outdated!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                Spacer()
            }
        }.background(Color.duck_light_yellow)
        .onAppear(perform: {
            let itemSplit = item.split(separator: ",")
            for itemElement in itemSplit {
                itemDict[String(itemElement.split(separator: "*")[0])] = String(itemElement.split(separator: "*")[1])
            }
            backgroundReady = true
        })
    }
}

struct merchantPaymentProcessView: View {
    @EnvironmentObject private var appData: ApplicationData
    @State var merchantID: String
    @State var amount: Int
    @State var item: String
    @State var isDone: Bool = false
    @State var errorState: Bool = false
    @State var observer: NSObjectProtocol?
    
    var body: some View {
        VStack {
            if !isDone {
                Text("Loading...")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                if !errorState {
                    Text("Successfully Done!")
                    NavigationLink(destination: MainView(), label: {
                        Text("Done")
                            .font(.title2)
                            .fontWeight(.bold)
                    }).navigationBarBackButtonHidden(true)
                } else {
                    Text("Error has occurred!")
                        .font(.title)
                        .fontWeight(.bold)
                    NavigationLink(destination: MainView(), label: {
                        Text("Back")
                            .font(.title2)
                            .fontWeight(.bold)
                    }).navigationBarBackButtonHidden(true)
                }
            }
        }.onAppear(perform: {
            let HTTPSession = HTTPSession()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm"
            
            HTTPSession.merchantProcess(action: "searchOne", name: appData.userInfo.name, myID: appData.userInfo.userID, merchantID: merchantID, amount: amount, date: format.string(from: Date()), item: item)
            
            observer = NotificationCenter.default.addObserver(forName: Notification.Name("searchOneMerchant"), object: nil, queue: nil, using: {
                notification in
                let temp = notification.object as! [String: Any]
                if temp.isEmpty {
                    errorState = true
                    isDone = true
                } else {
                    item = item.replacingOccurrences(of: "/", with: ",")
                    errorState = false
                    HTTPSession.merchantProcess(action: "payment", name: appData.userInfo.name, myID: appData.userInfo.userID, merchantID: merchantID, amount: amount, date: format.string(from: Date()), item: item)
                    isDone = true
                }
                NotificationCenter.default.removeObserver(observer)
            })
        })
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
        videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: view.layer.bounds.width - 33, height: view.layer.bounds.height)
        view.layer.addSublayer(videoPreviewLayer)
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
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
                qrCodeScanned = false
            }
        }
    }
}
