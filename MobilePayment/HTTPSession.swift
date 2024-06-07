//
//  HTTPSession.swift
//  MobilePayment
//
//  Created by 이주환 on 12/14/23.
//

import Foundation
import Alamofire
import Stripe

public class HTTPSession : ObservableObject {
    @Published var stripePaymentStatus: STPPaymentHandlerActionStatus?
    @Published var stripePaymentIntentParams: STPPaymentIntentParams?
    @Published var stripeLastPaymentError: NSError?
    var stripePaymentMethodType: String?
    
//    let url = "http://127.0.0.1:3000/"
    let url = "https://0b98-203-186-109-110.ngrok-free.app/" // Change by every ngrok session
    
    func createNewUser(name: String, userID: String, userPassword: String, isMerchant: Bool) -> Void {
        let json: [String: Any] = [
            "name" : name,
            "userID" : userID,
            "userPassword" : userPassword,
            "isMerchant" : isMerchant
        ]
        AF.request(url + "newUser", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        if jsonData!["error"] != nil {
                            NotificationCenter.default.post(name: Notification.Name("error_duplicateUserID"), object: "duplicate")
                        } else {
                            NotificationCenter.default.post(name: Notification.Name("newUserInfo"), object: jsonData)
                        }
                    } catch {
                    }
                case .failure(let data):
                    NotificationCenter.default.post(name: Notification.Name("error_duplicateUserID"), object: "serverOFF")
                }
            }
    }
    
    func retrieveUserInfo(id: String) -> Void {
        let json: [String: Any] = [
            "id" : id
        ]
        AF.request(url + "getUserInfo", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("userInfo"), object: jsonData)
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func updateUserInfo(id: String, info: [String: Any]) -> Void {
        AF.request(url + "updateUserInfo/\(id)", method: .post, parameters: info ,encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("updatedUserInfo"), object: jsonData)
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func updateTransfer(userID: String, friendID: String, date: String, amount: Int) -> Void {
        let json: [String: Any] = [
            "userID" : userID,
            "friendID" : friendID,
            "amount" : amount,
            "date" : date
        ]
        
        AF.request(url + "updateTransfer", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("updateTransfer"), object: jsonData)
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func dutchSplitProcess(action: String, message: String, invitorID: String?, merchantID: String?) {
        let json: [String: Any] = [
            "message" : message
        ]
        AF.request(url + "dutchSplit/\(action)/\(merchantID ?? "undefined")", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData(completionHandler: {
                response in
                switch response.result {
                case .success(let data):
                    if action == "gotInvite" {
                        NotificationCenter.default.post(name: Notification.Name("gotInvite"), object: true)
                    } else if action == "deleteRoom" {
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID!)deleteRoom"), object: true)
                    } else if action == "payment" {
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID!)payment"), object: true)
                    }
                case .failure(let error):
                    break
                }
            })
        
    }
    
    func friendProcess(action: String, name: String, myID: String, friendID: String ) -> Void {
        let json: [String: Any] = [
            "action" : action,
            "name" : name,
            "myID" : myID,
            "friendID" : friendID,
        ]
        AF.request(url + "friend", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        if action == "search" {
                            let jsonDataForSearch = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                            NotificationCenter.default.post(name: Notification.Name("searchFriend"), object: jsonDataForSearch)
                        } else if action == "searchOne" {
                            let jsonDataForSearch = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                            NotificationCenter.default.post(name: Notification.Name("searchOneFriend"), object: jsonDataForSearch)
                        } else if action == "searchOneFromQRCode" {
                            let jsonDataForSearch = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                            NotificationCenter.default.post(name: Notification.Name("searchOneFromQRCode"), object: jsonDataForSearch)
                        }
                        else {
                            let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            
                            if action == "send" {
                                NotificationCenter.default.post(name: Notification.Name("sendFriend"), object: jsonData)
                            } else if action == "cancelSend" {
                                NotificationCenter.default.post(name: Notification.Name("cancelSendFriend"), object: jsonData)
                            } else if action == "accept" {
                                NotificationCenter.default.post(name: Notification.Name("acceptFriend"), object: jsonData)
                            } else if action == "decline" {
                                NotificationCenter.default.post(name: Notification.Name("declineFriend"), object: jsonData)
                            } else if action == "delete" {
                                NotificationCenter.default.post(name: Notification.Name("deleteFriend"), object: jsonData)
                            } else if action == "deleteFav" {
                                NotificationCenter.default.post(name: Notification.Name("deleteFavFriend"), object: jsonData)
                            } else if action == "doFav" {
                                NotificationCenter.default.post(name: Notification.Name("doFavFriend"), object: jsonData)
                            } else if action == "undoFav" {
                                NotificationCenter.default.post(name: Notification.Name("undoFavFriend"), object: jsonData)
                            }
                        }
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func merchantProcess(action: String, name: String, myID: String, merchantID: String, amount: Int, date: String, item: String) -> Void {
        let json: [String: Any] = [
            "item" : item
        ]
        AF.request(url + "merchant/\(action)/\(name)/\(myID)/\(merchantID)/\(amount)/\(date)", method:
                .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        if action == "search" {
                            let jsonData = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                            NotificationCenter.default.post(name: Notification.Name("searchMerchant"), object: jsonData)
                        } else if action == "searchOne" {
                            let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            NotificationCenter.default.post(name: Notification.Name("searchOneMerchant"), object: jsonData)
                        } else if action == "payment" {
                            let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                            NotificationCenter.default.post(name: Notification.Name("paymentMerchant"), object: jsonData)
                        }
                    } catch {
                    }
                case .failure(let data):
                    break
                    }
            }
    }
    
    func stripeRetrieveUserInfo(userID: String) -> Void {
        let json: [String: Any] = [
            "userID" : userID
        ]
        AF.request(url + "stripeUserID", method: .post, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                        NotificationCenter.default.post(name: Notification.Name("stripeUserInfo"), object: jsonData)
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func stripeRequestPaymentIntent(stripeID: String, paymentMethodType: String, currency: String, amount: String) -> Void {
        self.stripePaymentMethodType = paymentMethodType
        let json: [String: Any] = [
            "id" : stripeID,
            "paymentMethodType" : paymentMethodType,
            "currency" : currency,
            "amount" : amount + "00"
        ]
        
        AF.request(url + "stripePaymentRequest", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("client_secret"), object: jsonData!["client_secret"] as? String)
                        NotificationCenter.default.post(name: Notification.Name("intent_id"), object: jsonData!["id"] as? String)
                        
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func stripeCancelPaymentIntent(intent_id: String) -> Void {
        let json: [String: Any] = [
            "id" : intent_id
        ]
        AF.request(url + "stripeCancelPaymentIntent", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    break
                case .failure(let data):
                    break
                }
            }
    }
    
    func getStripePublishableKey() -> Void {
        AF.request(url + "stripePublishableKey", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch (response.result) {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("publishable_key"), object: jsonData!["Publishable Key"] as? String)
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func getOnlineFriendList(userID: String) -> Void {
        let json: [String: Any] = [
            "userID" : userID
        ]
        AF.request(url + "getOnlineFriendList", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData {
                response in
                switch (response.result) {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as! [String]
                        NotificationCenter.default.post(name: Notification.Name("onlineList"), object: jsonData)
                    } catch {
                    }
                case .failure(let data):
                    break
                }
            }
    }
    
    func authenticationProcess(userID: String, userPassword: String) -> Void {
        let json: [String: Any] = [
            "userID" : userID,
            "userPassword" : userPassword,
        ]
        AF.request(url + "authenticationProcess", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch (response.result) {
                case .success(let data):
                    NotificationCenter.default.post(name: Notification.Name("authentication"), object: String(decoding: data, as: UTF8.self))
                case .failure(let data):
                    NotificationCenter.default.post(name: Notification.Name("authentication"), object: "ERROR")
                }
            }
    }
}
