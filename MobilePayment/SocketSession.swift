//
//  SocketSession.swift
//  MobilePayment
//
//  Created by 이주환 on 2/23/24.
//

import Foundation

class SocketSession: NSObject, ObservableObject {
    let url = URL(string: "https://2ba9-158-132-12-129.ngrok-free.app/")! // Change by every ngrok session
    var connected: Bool = false
    var request: URLRequest?
    var session: URLSession?
    var websocket: URLSessionWebSocketTask?
    var timer: Timer?
    
    override init() {
        super.init()
        print("Start Websocket")
        connectAndListen()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] timer in
            self?.websocket?.sendPing(pongReceiveHandler: { error in
                if let error = error {
                    print("Failed with Error \(error.localizedDescription)")
                } else {
                    print("Ping!")
                }
            })
        }
        timer?.fire()
    }
    func invalidateTimerForMerchant() {
        timer?.invalidate()
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
                    if string.description.contains("invite:") {
                        let invitorID = string.description.split(separator: ":")[1]
                        let invitorName = string.description.split(separator: ":")[2]
                        let myID = string.description.split(separator: ":")[3]
                        let manager = LocalNotificationManager.shared
                        if !manager.isGranted {
                            manager.requestPermission()
                        }
                        manager.addNotification(title: "Invitation on Split Pay!", content: "Your friend \(invitorName) with ID \(invitorID) has invited you in Split Pay!")
                        let HTTPSession = HTTPSession()
                        HTTPSession.dutchSplitProcess(action: "gotInvite", message: String(string.description), invitorID: nil)
                        
                        print("GOTINVITE!")
                        
                    } else if string.description.contains("inRoom:") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let targetID = String(string.description.split(separator: ":")[2])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)inRoom"), object: targetID)
                        
                    } else if string.description.contains("outRoom:") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let targetID = String(string.description.split(separator: ":")[2])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)outRoom"), object: targetID)
                        
                    } else if string.description.contains("deleteRoom:") {
                        let invitorID = String(string.description.split(separator: ":")[1])
                        let targetID = String(string.description.split(separator: ":")[2])
                        let HTTPSession = HTTPSession()
                        HTTPSession.dutchSplitProcess(action: "deleteRoom", message: String(string.description), invitorID: invitorID)
                    } else if string.description.contains("updateRoom:") {
                        let updatedList = String(string.description.split(separator: ":")[3])
                        let invitorID = String(string.description.split(separator: ":")[1])
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)updateRoom"), object: updatedList)
                    }
                    self.connectAndListen()
                }
            case .failure(let error):
                print("Message Receive Failed!")
                print(error.localizedDescription)
            }
        })
        print("Connected WebSocket!")
        print("Listening...")
    }
    
    func sendMessage(message: String) -> Void {
        self.websocket?.send(URLSessionWebSocketTask.Message.string(message), completionHandler: {
            [weak self] error in
            if let error = error {
                print("Send message failed with error \(error.localizedDescription)")
            } else {
                print("Message sent!")
            }
        })
    }
}

extension SocketSession: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Websocket Opened!")
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Websocket Closed!")
    }
}