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
    var currency: String?
    var client_secret: String?
    var intentID: String?
    var publishable_key: String?
    
    let url = "http://127.0.0.1:3000/"
    
    func stripeRetrieveUserID(userID: String) -> Void {
        AF.request(url + "userID/\(userID)", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                        print(jsonData)
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                    
                case .failure(let data):
                    print("Response in Failure!")
                }
            }
    }
    
    func stripeRequestPaymentIntent(userID: String, paymentMethodType: String, currency: String, amount: String) -> Void {
        self.stripePaymentMethodType = paymentMethodType
        self.currency = currency
        
        let json: [String: Any] = [
            "id" : userID,
            "paymentMethodType" : paymentMethodType,
            "currency" : currency,
            "amount" : amount + "00"
        ]
        
        AF.request(url + "paymentRequest", method: .post, parameters: json, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        self.client_secret = jsonData!["client_secret"] as? String
                        self.intentID = jsonData!["id"] as? String
                        NotificationCenter.default.post(name: Notification.Name("client_secret"), object: jsonData!["client_secret"] as? String)
                        NotificationCenter.default.post(name: Notification.Name("id"), object: jsonData!["id"] as? String)
                        
                    } catch {
                        print("JSON Serialization Failed!")
                    }
                case .failure(let data):
                    print("Error on Posting Request for Payment Intent!")
                }
            }
    }
    
    func stripeCancelPaymentIntent(id: String) -> Void {
        print("Intent ID")
        print(id)
        let json: [String: Any] = [
            "id" : id
        ]
        AF.request(url + "cancelPaymentIntent", method: .post, parameters: json, encoding: JSONEncoding.default)
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
        AF.request(url + "getPublishableKey", method: .get, encoding: JSONEncoding.default)
            .validate()
            .responseData { response in
                switch (response.result) {
                case .success(let data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        self.publishable_key = jsonData!["Publishable Key"] as? String
                        NotificationCenter.default.post(name: Notification.Name("publishable_key"), object: jsonData!["Publishable Key"] as? String)
                    } catch {
                        print("JSON Serialization Failed")
                    }
                case .failure(let data):
                    print("Error on Getting Publishable Key")
                    print(data)
                }
            }
    }
}
