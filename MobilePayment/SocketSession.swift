//
//  SocketSession.swift
//  MobilePayment
//
//  Created by 이주환 on 2/23/24.
//

import Foundation

class SocketSession: NSObject, ObservableObject {
    let url = URL(string: "https://c5b3-202-82-161-121.ngrok-free.app/")! // Change by every ngrok session
    var connected: Bool = false
    var request: URLRequest?
    var session: URLSession?
    var websocket: URLSessionWebSocketTask?
    var timer: Timer?
    
    override init() {
        super.init()
        connectAndListen()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] timer in
            self?.websocket?.sendPing(pongReceiveHandler: { error in
                if let error = error {
                    timer.invalidate()
                }
            })
        }
        timer?.fire()
    }
    
    func connectAndListen() {
        if !self.connected {
            self.request = URLRequest(url: url)
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.websocket = session!.webSocketTask(with: request!)
            self.websocket?.resume()
            self.connected = true
        }
        self.websocket?.receive(completionHandler: {
            result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.connectAndListen()
                case .string(let string):
                    if string.description.split(separator: ":")[0].contains("invite") {
                        let invitorID = string.description.split(separator: ":")[1]
                        let invitorName = string.description.split(separator: ":")[2]
                        let myID = string.description.split(separator: ":")[3]
                        let manager = LocalNotificationManager.shared
                        if !manager.isGranted {
                            manager.requestPermission()
                        }
                        manager.addNotification(title: "Invitation on Split Pay!", content: "Your friend \(invitorName) with ID \(invitorID) has invited you in Split Pay!")
                        let HTTPSession = HTTPSession()
                        HTTPSession.dutchSplitProcess(action: "gotInvite", message: String(string.description), invitorID: nil, merchantID: nil)
                        
                    } else if string.description.split(separator: ":")[0].contains("inRoom") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let targetID = String(string.description.split(separator: ":")[2])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)inRoom"), object: targetID)
                        
                    } else if string.description.split(separator: ":")[0].contains("outRoom") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let targetID = String(string.description.split(separator: ":")[3])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)outRoom"), object: targetID)
                        
                    } else if string.description.split(separator: ":")[0].contains("firstJoin") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let updatedInfo = String(string.description.split(separator: ":")[3])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)firstJoin"), object: updatedInfo)
                        
                    } else if string.description.split(separator: ":")[0].contains("deleteRoom") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let targetID = String(string.description.split(separator: ":")[2])
                        let HTTPSession = HTTPSession()
                        HTTPSession.dutchSplitProcess(action: "deleteRoom", message: String(string.description), invitorID: invitorID, merchantID: nil)
                        HTTPSession.retrieveUserInfo(id: targetID)
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)deleteRoom"), object: true)
                        
                    } else if string.description.split(separator: ":")[0].contains("ready") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)ready"), object: String(string.description))
                        
                    } else if string.description.split(separator: ":")[0].contains("lock") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)lock"), object: true)
                        
                    } else if string.description.split(separator: ":")[0].contains("done") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)done"), object: true)   
                        
                    } else if string.description.split(separator: ":")[0].contains("paymentFinished") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let merchantID = String(string.description.split(separator: ":")[2])
                        NotificationCenter.default.post(name: Notification.Name("\(merchantID)paymentFinished"), object: true)
                        
                    } else if string.description.split(separator: ":")[0].contains("qrScannedByMerchant") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let merchantID = String(string.description.split(separator: ":")[2])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)qrScannedByMerchant"), object: merchantID)
                    }
                    self.connectAndListen()
                }
            case .failure(let error):
                NotificationCenter.default.post(name: Notification.Name("No Connection"), object: true)
                
            }
        })
    }
    
    func sendMessage(message: String) -> Void {
        self.websocket?.send(URLSessionWebSocketTask.Message.string(message), completionHandler: {
            [weak self] error in
            if let error = error {
                print("Send message failed with error \(error.localizedDescription)")
            }
        })
    }
}

extension SocketSession: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
    }
}
