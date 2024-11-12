//
//  APIManager.swift
//  MLCChat
//
//  Created by Debakshi Bhattacharjee on 12/11/24.
//

import Foundation
import Alamofire
import UIKit
import SVProgressHUD

struct APIErrorResponse: Decodable {
    let message: String
}

enum ParametersType {
    case encodable(Encodable)
    case dictionary([String: Any])
    case none
}

class GlobalAPIManager {
    
    class func getHeaderWithToken(accessToken: Bool, ContentType: String = "application/x-www-form-urlencoded", xToken: Bool , both : Bool) -> HTTPHeaders? {
         if accessToken {
            let headers: HTTPHeaders = [
                "Accept": "application/json",
                "Authorization": kAccessToken
            ]
            return headers
         }else{
             return nil
         }
    }
    
    // Global API request function using Alamofire
    static func performAPIRequest<Response: Decodable>(
        url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: ParametersType = .none,
        accessToken: Bool,
        both: Bool = false,
        showLoader: Bool,
        completion: @escaping (_ success: Bool, _ response: Response?, _ errorMsg: String?) -> Void
    ) {
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        // Convert ParametersType to Parameters
        var parametersData: Parameters?
        switch parameters {
        case .encodable(let encodable):
            if let jsonData = try? JSONEncoder().encode(AnyEncodable(encodable)),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? Parameters {
                parametersData = jsonObject
            }
        case .dictionary(let dictionary):
            parametersData = dictionary
        case .none:
            parametersData = nil
        }
        
        let startTime = Date()
        
        // Show loader
        if showLoader {
            SVProgressHUD.show()
        }
        
        AF.request(url, method: method, parameters: parametersData, encoding: encoding, headers: GlobalAPIManager.getHeaderWithToken(accessToken: accessToken, xToken: !accessToken, both: both)).validate().responseDecodable(of: Response.self) { response in
            
            let endTime = Date()
            let elapsedTime = endTime.timeIntervalSince(startTime)
            let minimumDisplayTime: TimeInterval = 2.0
            let remainingTime = minimumDisplayTime - elapsedTime
            
            func handleResponse() {
                switch response.result {
                case .success(let decodedResponse):
                    completion(true, decodedResponse, nil)
                case .failure(let error):
                    if let data = response.data {
                        do {
                            let apiErrorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                            print("API Request Failed: \(apiErrorResponse.message)")
                            completion(false, nil, apiErrorResponse.message)
                        } catch {
                            let errorMessage = String(data: data, encoding: .utf8) ?? "An unknown error occurred"
                            print("API Request Failed: \(errorMessage)")
                            completion(false, nil, errorMessage)
                        }
                    } else {
                        completion(false, nil, "An unknown error occurred")
                    }
                    print(error)
                }
            }
            
            if remainingTime > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
//                    HideLoader
                    SVProgressHUD.dismiss()
                    handleResponse()
                }
            } else {
                // HideLoader
                SVProgressHUD.dismiss()
                handleResponse()
            }
        }
    }
}

// Helper structure to handle Encodable
struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ value: T) {
        self.encode = value.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}

