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
    
    let url = "http://127.0.0.1:3000/"
    
    func createNewUser(name: String, userID: String, userPassword: String) -> Void {
        AF.request(url + "newUser/\(name)/\(userID)/\(userPassword)", method: .get, encoding: JSONEncoding.default)
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
                    print(data)
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
                        print(jsonData)
                        NotificationCenter.default.post(name: Notification.Name("userInfo"), object: jsonData)
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
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
                }
            }
    }
    
    func friendProcess(action: String, myID: String, friendID: String ) -> Void {
        AF.request(url + "friend/\(action)/\(myID)/\(friendID)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                        if action == "search" {
                            NotificationCenter.default.post(name: Notification.Name("searchFriend"), object: jsonData)
                        } else if action == "send" {
                            NotificationCenter.default.post(name: Notification.Name("sendFriend"), object: jsonData)
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
