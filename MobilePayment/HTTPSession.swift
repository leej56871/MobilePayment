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
    let url = "https://2ba9-158-132-12-129.ngrok-free.app/" // Change by every ngrok session
    
    func createNewUser(name: String, userID: String, userPassword: String, isMerchant: Bool) -> Void {
        AF.request(url + "newUser/\(name)/\(userID)/\(userPassword)/\(isMerchant)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("newUserInfo"), object: jsonData)
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    NotificationCenter.default.post(name: Notification.Name("error_duplicateUserID"), object: true)
                    print("Creating New User Failed!")
                }
            }
    }
    
    func retrieveUserInfo(id: String) -> Void {
        AF.request(url + "getUserInfo/\(id)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("userInfo"), object: jsonData)
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print(data)
                    print("Retrieve Failed!")
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
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print("Update Failed!")
                    print(data.localizedDescription)
                }
            }
    }
    
    func updateTransfer(userID: String, friendID: String, amount: Int, date: String, amout: Int) -> Void {
        AF.request(url + "updateTransfer/\(userID)/\(friendID)/\(amount)/\(date)/\(amount)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                        NotificationCenter.default.post(name: Notification.Name("updateTransfer"), object: jsonData)
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print("Updating Transfer History Failed!")
                    print(data)
                }
            }
    }
    
    func dutchSplitProcess(action: String, message: String, invitorID: String?) {
        let json: [String: Any] = [
            "message" : message
        ]
        AF.request(url + "dutchSplit/\(action)", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData(completionHandler: {
                response in
                switch response.result {
                case .success(let data):
                    if action == "gotInvite" {
                        NotificationCenter.default.post(name: Notification.Name("gotInvite"), object: true)
                    } else if action == "deleteRoom" {
                        NotificationCenter.default.post(name: Notification.Name("\(invitorID)deleteRoom"), object: true)
                    }
                case .failure(let error):
                    print("Error on DutchSplit Process!")
                    print(error.localizedDescription)
                }
            })
    }
    
    func friendProcess(action: String, name: String, myID: String, friendID: String ) -> Void {
        AF.request(url + "friend/\(action)/\(name)/\(myID)/\(friendID)", method: .get, encoding: JSONEncoding.default)
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
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print("Friend Process Failed!")
                    print(data)
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
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print(data.localizedDescription)
                    print("Merchant Process Failed!")
                }
            }
    }
    
    func invitationProcess(action: String, addingInvitation: String, userID: String, friendID: String) -> Void {
        AF.request(url + "invitation/\(action)/\(addingInvitation)/\(friendID)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData(completionHandler: {
                response in
                switch response.result {
                case .success(let data):
                    do {
                        if action == "accept" {
                            NotificationCenter.default.post(name: Notification.Name("invitationAccept"), object: true)
                        }
                    }
                case .failure(let data):
                    print("Invitation Process Failed!")
                }
            })
        
    }
    
    func stripeRetrieveUserInfo(userID: String) -> Void {
        AF.request(url + "stripeUserID/\(userID)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                        NotificationCenter.default.post(name: Notification.Name("stripeUserInfo"), object: jsonData)
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print("Response in Failure!")
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
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print("Error on Posting Request for Payment Intent!")
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
                    print("Error on Posting Cancel for Payment Intent!")
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
                        print("JSON Serialization Failed")
                    }
                case .failure(let data):
                    print("Error on Getting Publishable Key")
                }
            }
    }
    
    func authenticationProcess(userID: String, userPassword: String) -> Void {
        AF.request(url + "authenticationProcess/\(userID)/\(userPassword)", method: .get, encoding: JSONEncoding.default)
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
