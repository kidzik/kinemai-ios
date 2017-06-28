//
//  Backend.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 22/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import Alamofire

class Backend
{
    class func registerNewUserIfNeeded(completion: @escaping (Bool) -> Void)
    {
        if UserDefaults.standard.bool(forKey: self.keyWasUserRegistered)
        {
            print("-- User was previously registered during earlier app launch ----")
            completion(true)
            return
        }
        
        self.registerNewUser(completion: completion)
    }
    
    class func authenticateLocalUser(completion: @escaping (Bool) -> Void)
    {
        if false == UserDefaults.standard.bool(forKey: self.keyWasUserRegistered)
        {
            print("---- Failed to authenticate: User was NOT registered previously ----")
            completion(false)
            return
        }
        
        if let _ = self.currentAccessToken()
        {
            print("---- Already received token ----")
            completion(true)
            return
        }
        
        self.requestAuthenticateLocalUser(completion: completion)
    }
    
    class func uploadVideo(
        videoURL: URL
        , creationDate: Date
        , completion: @escaping (String?) -> Void)
    {
        self.authenticateLocalUser { isAuthenticated in
            if isAuthenticated
            {
                self.requestUploadVideo(videoURL: videoURL, creationDate: creationDate, completion: completion)
                return
            }
            
            completion(nil)
        }
    }
    
    class func deleteVideo(videoID: String, completion: @escaping (Bool) -> Void)
    {
        self.authenticateLocalUser { isAuthenticated in
            if isAuthenticated
            {
                self.requestDeleteVideo(videoID: videoID, completion: completion)
                return
            }
            
            completion(false)
        }
    }
    
    class func allVideosByLocalUser(completion: @escaping ([[String: Any]]?) -> Void)
    {
        self.registerNewUserIfNeeded { isRegistered in
            if isRegistered
            {
                self.authenticateLocalUser { isAuthenticated in
                    if isAuthenticated
                    {
                        self.requestAllVideosByLocalUser(completion: completion)
                        return
                    }
                    
                    completion(nil)
                }
                
                return
            }
            
            completion(nil)
        }
    }
    
    class func sendApnsTokenToServer(apnsToken: String)
    {
        self.registerNewUserIfNeeded { isRegistered in
            if isRegistered
            {
                self.authenticateLocalUser { isAuthenticated in
                    if isAuthenticated
                    {
                        self.requestSendApnsTokenToServer(apnsToken: apnsToken)
                        return
                    }
                }
            }
        }
        
        
    }
    
    class func userLogout()
    {
        print("---- Removing current access token ----")
        let ud = UserDefaults.standard
        ud.set(nil, forKey: keyCurrentAccessToken)
        ud.synchronize()
    }
    
    class func currentAccessToken() -> String?
    {
        let ud = UserDefaults.standard
        return ud.string(forKey: keyCurrentAccessToken)
    }
    
    private init() {}
    
    
    internal static let ApiRoot = "https://golf.kinemai.com/api/"
    
    internal static let keyWasUserRegistered = "KEY_wasUserRegistered"
    internal static let keyUserEmail = "KEY_USER_EMAIL"
    internal static let keyUserPassword = "KEY_USER_PASSWORD"
    
    internal static let keyCurrentAccessToken = "KEY_USER_ACCESS_TOKEN"
}

// MARK: -
// MARK: Filepricate funcs
extension Backend
{
    fileprivate class func registerNewUser(completion: @escaping (Bool) -> Void)
    {
        let randomString = UUID().uuidString
        let email = randomString + "@kinemai.com"
        let password = email
        
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(self.ApiRoot + "register/"
            , method: .post
            , parameters: params
            , encoding: URLEncoding.default
            , headers: nil)
            
            .responseString { response in
                switch response.result
                {
                case .success(_):
                    let ud = UserDefaults.standard
                    ud.set(email, forKey: keyUserEmail)
                    ud.set(password, forKey: keyUserPassword)
                    ud.set(true, forKey: keyWasUserRegistered)
                    ud.synchronize()
                    
                    print("---- Registered new user ----")
                    print("email: \(email)")
                    print("password: \(password)")
                    
                    completion(true)
                    
                case .failure(let error):
                    print("---- Failed to register new user: '\(error.localizedDescription)' ----")
                    completion(false)
                }
            }
    }
    
    fileprivate class func requestAuthenticateLocalUser(completion: @escaping (Bool) -> Void)
    {
        let ud = UserDefaults.standard
        guard let email = ud.string(forKey: keyUserEmail)
            , let password = ud.string(forKey: keyUserPassword) else
        {
            print("---- Failed to authenticate local user: email and/or password not set ----")
            completion(false)
            return
        }
        
        let params: Parameters = [
            "username": email,
            "password": password
        ]
        
        Alamofire.request(self.ApiRoot + "auth/token/"
            , method: .post
            , parameters: params
            , encoding: URLEncoding.default
            , headers: nil)
        
            .validate(statusCode: 200 ..< 300 )
            .responseJSON { response in
                switch response.result
                {
                case .success(let json):
                    if let json = json as? [String: Any],
                        let token = json["token"] as? String
                    {
                        ud.set(token, forKey: keyCurrentAccessToken)
                        ud.synchronize()
                        
                        print("---- User authenticated. Token: \(token)----")
                        completion(true)
                    }
                    else
                    {
                        print("---- Failed to authenticate user: 'wrong server response' ----")
                        print("Response: '\(json)'")
                        completion(false)
                    }
                    
                case .failure(let error):
                    print("---- Failed to authenticate user: '\(error.localizedDescription)' ----")
                    print("\(response.description)")
                    completion(false)
                }
            }
    }
    
    fileprivate class func requestUploadVideo(
        videoURL: URL
        , creationDate: Date
        , completion: @escaping (String?) -> Void)
    {
        guard let accessToken = self.currentAccessToken() else
        {
            completion(nil)
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token " + accessToken,
            "Content-Type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { multipartData in
            multipartData.append(videoURL
                , withName: "video"
                , fileName: videoURL.lastPathComponent
                , mimeType: "video/mp4"
            )
        }
            , usingThreshold: UInt64.init()
            , to: self.ApiRoot + "submissions/"
            , method: .post
            , headers: headers
            , encodingCompletion: {
                encodingCompletion -> Void in
                switch encodingCompletion
                {
                case .success(request: let uploadRequest, _, _):
                    uploadRequest.responseJSON { response in
                        switch response.result
                        {
                        case .success(let json):
                            if let json = json as? [String: Any],
                                let videoID = json["id"] as? String
                            {
                                completion(videoID)
                            }
                            else
                            {
                                print("---- Failed to upload video: 'wrong server response' ----")
                                print("Response: '\(json)'")
                                completion(nil)
                            }
                            
                            
                        case .failure(let error):
                            print("---- Failed to upload video: '\(error.localizedDescription)' ----")
                            completion(nil)
                        }
                    }
                    break
                    
                case .failure(let error):
                    print("---- Failed to encode video: '\(error.localizedDescription)' ----")
                    completion(nil)
                }
            }
        )
    }
    
    fileprivate class func requestAllVideosByLocalUser(completion: @escaping ([[String: Any]]?) -> Void)
    {
        guard let token = self.currentAccessToken() else {
            completion(nil)
            return
        }
        
        let headers = [
            "Authorization": "Token " + token
        ]
        
        Alamofire.request(self.ApiRoot + "submissions/"
            , method: .get
            , parameters: nil
            , encoding: URLEncoding.default
            , headers: headers)
        
            .validate(statusCode: 200 ..< 300)
            .responseJSON { response in
                switch response.result
                {
                case .success(let json):
                    if let json = json as? [String: Any]
                    , let results = json["results"] as? [[String: Any]]
                    {
                        completion(results)
                    }
                    else
                    {
                        print("---- Failed to get all submissions by local user: failed to parse server response ----")
                        print("Response: \(json)")
                        completion(nil)
                    }
                    
                case .failure(let error):
                    print("---- Failed to get all submissions by local user: '\(error.localizedDescription)'----")
                    completion(nil)
                }
            }
    }
    
    fileprivate class func requestSendApnsTokenToServer(apnsToken: String)
    {
        guard let accessToken = self.currentAccessToken() else { return }
        
        let params: Parameters = [
            "registration_id": apnsToken
        ]
        
        let headers = [
            "Authorization": "Token " + accessToken
        ]
        
        Alamofire.request(self.ApiRoot + "device/apns/"
            , method: .post
            , parameters: params
            , encoding: URLEncoding.default
            , headers: headers)
        
            .responseString { response in
                switch response.result
                {
                case .success(let responseString):
                    print("---- Successfully sent deviceToken to server ----")
                    print("Server response: '\(responseString)'")
                    
                case .failure(let error):
                    print("---- Failed to send deviceToken to server: '\(error.localizedDescription)' ----")
                }
            }
    }
    
    fileprivate class func requestDeleteVideo(videoID: String, completion: @escaping (Bool) -> Void)
    {
        guard let accessToken = self.currentAccessToken() else {
            completion(false)
            return
        }
        
        let headers = [
            "Authorization": "Token " + accessToken
        ]
        
        let url = self.ApiRoot + "submissions/" + videoID + "/"
        Alamofire.request(url
            , method: .delete
            , parameters: nil
            , encoding: URLEncoding.default
            , headers: headers)
            
            .responseString { response in
                print("---- Request delete video '\(videoID)'----")
                print("---- Server response: '\(response.result)'")
                
                switch response.result
                {
                case .success(_):
                    completion(true)
                    
                case .failure(let error):
                    print("---- Failed to delete video '\(videoID)'----")
                    print("---- Reason: '\(error.localizedDescription)'")
                    completion(false)
                }
            }
    }
}
