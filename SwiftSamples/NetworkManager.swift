
import Foundation
import Alamofire

struct ApiURLs {
    
    #if DEBUG
    static let baseURL = "some_url"
    #else
    static let baseURL = "another_url"
    #endif
    
    static let loginURL = "/auth"
    static let regURL = "/auth/signup"
    static let logoutURL = "/auth/logout"
    static let forgotPasswordURL = "/auth/reset"
    static let categoriesURL = "url"
    static let offersURL = "url"
    static let newOfferURL = "url"
    static let discardOfferURL = "url"
    static let getOfferImageURL = "url"
    static let completeOfferURL = "url"
    static let storageURL = "url"
    static let profileURL = "url"
    static let uploadOfferImage = "url"
}

struct Constants {
    static let progressNotification = "progressUpdatedForOffer"
    static let imageUploadedNotification = "imageUploaded"
    static let progressKey = "progress"
    static let uploadedImageKey = "image"
}

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    fileprivate init() {}
    
    fileprivate let tokenKey = "token"
    fileprivate var token: String? {
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
        
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
    }
    
    var loggedIn: Bool {
        return token != nil
    }
    
    func login(_ email: String, password: String, completionClosure: ((_ success: Bool, _ errorMessage: String?) -> ())?) {
        sendPOSTRequest(ApiURLs.loginURL, params: ["email": email as AnyObject, "password": password as AnyObject], addToken: false) { (resultJSON, success, errorMessage) in
            
            var result = success
            if resultJSON != nil {
                self.token = resultJSON!["data"]?.object(forKey: "token") as? String
                if let userDict = resultJSON!["data"]?["model"] as? Dictionary<String, AnyObject> {
                    let user = User(dict: userDict)
                    CacheManager.sharedInstance.openingTimes = user.days
                }
            } else {
                result = false
            }
            
            if completionClosure != nil {
                completionClosure!(result, errorMessage)
            }
            
            if success {
                let delegate = UIApplication.shared.delegate as! AppDelegate
                if delegate.pushID != nil {
                    var mainDict = [String: AnyObject]()
                    mainDict["push_id"] = delegate.pushID! as AnyObject?
                    self.updateUserProfile(mainDict, infoDict: nil, locationDict: nil, days: nil, completionClosure: nil)
                }
            }
        }
    }
    
    func registration(_ model: User, completionClosure: ((_ success: Bool, _ errorMessage: String?) -> ())?) {
        sendPOSTRequest(ApiURLs.regURL, params: model.toRegDict(), addToken: false) { (resultJSON, success, error) in
            var result = success
            if resultJSON == nil {
                result = false
            }
            
            if result {
                CacheManager.sharedInstance.openingTimes = model.days
                
                self.login(model.email!, password: model.password!, completionClosure: { (success, errorMessage) in
                    if completionClosure != nil {
                        completionClosure!(success, errorMessage)
                    }
                })
            } else {
                if completionClosure != nil {
                    completionClosure!(result, error)
                }
            }
        }
    }
    
    func logout(_ completionClosure: ((_ success: Bool) -> ())?) {
        sendPOSTRequest(ApiURLs.logoutURL, addToken: true) { (resultJSON, success, errorMessage) in
            if success {
                self.token  = nil
            }
            
            if completionClosure != nil {
                completionClosure!(success)
            }
        }
    }
    
    func resetPassword(_ email: String, completionClosure: ((_ success: Bool, _ errorMessage: String?) -> ())?) {
        sendPOSTRequest(ApiURLs.forgotPasswordURL, params: ["email": email as AnyObject], addToken: false) { (resultJSON, success, errorMessage) in
            if completionClosure != nil {
                completionClosure!(success, errorMessage)
            }
        }
    }
    
    func getCategories(_ completionClosure: ((_ success: Bool, _ categories: [Category]?) -> ())?) {
        sendGETRequest(ApiURLs.categoriesURL, addToken: true) { (resultJSON, success, errorMessage) in
            var categories: [Category]?
            var result = false
            
            if success {
                if let categoriesDict = resultJSON!["data"] as? [Dictionary<String, AnyObject>] {
                    categories = [Category]()
                    result = true
                    for categoryDict in categoriesDict {
                        let category = Category(dict: categoryDict)
                        categories!.append(category)
                    }
                    
                    if categories!.count > 0 {
                        CacheManager.sharedInstance.cacheCategories(categories!)
                    }
                }
            }
            
            if completionClosure != nil {
                completionClosure!(result, categories)
            }
        }
    }
    
    func getOffers(_ completionClosure: ((_ success: Bool, _ offers: [Offer]?) -> ())?) {
        let statuses: [String] = ["claimed", "available", "queued"]
         
        sendGETRequest(ApiURLs.offersURL, params: ["status": statuses as AnyObject], addToken: true) { (resultJSON, success, errorMessage) in
            var offers: [Offer]?
            var result = false
            
            if success {
                if let offersDict = resultJSON!["data"] as? [Dictionary<String, AnyObject>] {
                    offers = [Offer]()
                    result = true
                    for offerDict in offersDict {
                        let offer = Offer(dict: offerDict)
                        offers!.append(offer)
                    }
                }
            }
            
            if completionClosure != nil {
                completionClosure!(result, offers)
            }
        }
    }
    
    func placeOffer(_ name: String, categoryID: Int, expiredAt: String, completionClosure: ((_ success: Bool, _ offerID: Int?, _ errorMessage: String?) -> ())?) {

        sendPOSTRequest(ApiURLs.newOfferURL, params: ["name": name as AnyObject, "category_id": categoryID as AnyObject, "expired_at": expiredAt as AnyObject], addToken: true) { (resultJSON, success, errorMessage) in
            if completionClosure != nil {
                if success {
                    let id = resultJSON!["data"]!["id"] as? Int
                    completionClosure!(success, id, errorMessage)
                } else {
                    completionClosure!(success, nil, errorMessage)
                }
            }
        }
    }
    
    func uploadImage(_ imageData: Data, forOffer offerID: Int, completionClosure: ((_ success: Bool, _ imageURL: String?, _ errorMessage: String?) -> ())?) {
        
        let url = ApiURLs.uploadOfferImage.replacingOccurrences(of: "{id}", with: String(offerID))
        let targetURL = ApiURLs.baseURL + url
        let authHeader: HTTPHeaders = ["Authorization": "Bearer " + token!]
        
        Alamofire.upload(multipartFormData: { (multiPartFormData) in
            multiPartFormData.append(imageData, withName: "image", fileName: "image.png", mimeType: "image/png")
            }, to: targetURL, headers: authHeader) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success:
                            if let value = response.result.value as? [String: AnyObject] {
                                let parsedValue = self.parseValue(value)
                                var imageURL: String? = nil
                                
                                if let data = value["data"] as? [String: AnyObject] {
                                    imageURL = data["url"] as? String
                                }
                                
                                if (completionClosure != nil) {
                                    completionClosure!(parsedValue.resultResponse, imageURL, parsedValue.errorMessage)
                                }
                                print("Request to upload offer image was successful")
                                
                                if imageURL != nil {
                                    let name = Notification.Name(Constants.imageUploadedNotification + String(offerID))
                                    NotificationCenter.default.post(name: name, object: nil, userInfo: [Constants.uploadedImageKey: imageURL!])
                                }
                            } else if (completionClosure != nil) {
                                completionClosure!(false, nil, "Something went wrong. Please try again later".localized)
                            }
                        case .failure:
                            if completionClosure != nil {
                                completionClosure!(false, nil, "Something went wrong. Please try again later".localized)
                            }
                            print("Request to upload offer image was failed")
                        }
                    }
                    
                    upload.uploadProgress(closure: { (progress) in
                        let name = Notification.Name(Constants.progressNotification + String(offerID))
                        let percentage = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                        NotificationCenter.default.post(name: name, object: nil, userInfo: [Constants.progressKey: percentage])
                    })
                case .failure(let error):
                    print(error)
                    if completionClosure != nil {
                        completionClosure!(false, nil, "Something went wrong. Please try again later".localized)
                    }
                }
        }
    }
    
    func getOfferImage(_ offerID: Int, completionClosure: ((_ success: Bool) -> ())?) {
        let targetURL = ApiURLs.getOfferImageURL.replacingOccurrences(of: "{id}", with: String(offerID))
        sendGETRequest(targetURL, addToken: true) { (resultJSON, success, errorMessage) in
            if success {
                
            }
        }
    }
    
    func loadImageFromURL(_ URL: String, completionClosure: ((_ imageData: Data?) -> ())?) {
        Alamofire.request(URL).responseData { (response) in
            switch response.result {
            case .success:
                
                if completionClosure != nil {
                    completionClosure!(response.result.value)
                }
                
            case .failure(let error):
                print("Failed to load user image - \(URL)")
                print(error)
                if completionClosure != nil {
                    completionClosure!(nil)
                }
            }
        }
    }
    
    func getProfileInfo(_ completionClosure: ((_ success: Bool, _ user: User?) -> ())?) {
        sendGETRequest(ApiURLs.profileURL, addToken: true) { (resultJSON, success, errorMessage) in
            var result = false
            var user: User?
            
            if success {
                if let JSON = resultJSON!["data"] as? Dictionary<String, AnyObject> {
                    result = true
                    user = User(dict: JSON)
                    CacheManager.sharedInstance.openingTimes = user!.days
                }
            }
            
            if completionClosure != nil {
                completionClosure!(result, user)
            }
        }
    }
    
    
    func changePassword(_ oldPassword: String, newPassword: String, confirmPassword: String, completionClosure: ((_ success: Bool, _ errorMessage: String?) -> ())?) {
        
        let params = ["password": ["old": oldPassword, "new": newPassword, "new_confirmation": confirmPassword]]
        
        sendPOSTRequest(ApiURLs.profileURL, params: params as [String : AnyObject]?, addToken: true) { (resultJSON, success, errorMessage) in
            if completionClosure != nil {
                completionClosure!(success, errorMessage)
            }
        }
    }
    
    fileprivate func sendPOSTRequest(_ targetURL: String, params: [String: AnyObject]? = nil, addToken: Bool, completionClosure: ((_ resultJSON: [String: AnyObject]?, _ success: Bool, _ errorMessage: String?) -> ())?) {
        var authHeader = nil as [String: String]?
        if addToken {
            authHeader = ["Authorization": "Bearer " + token!] as [String: String]?
        }
        
        if let parameters: Parameters = params {
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
                
                print(string)
            } catch {
                print("Cannot display params for url \(targetURL)")
                return
            }
        }
        
        Alamofire.request(ApiURLs.baseURL + targetURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: authHeader)
        .validate()
        .responseJSON { (response) in
            switch response.result {
            case .success:
                print("Request to \(targetURL) was successful")
                
                if let value = response.result.value as? [String: AnyObject] {
                    let parsedValue = self.parseValue(value)
                    
                    if (completionClosure != nil) {
                        completionClosure!(value, parsedValue.resultResponse, parsedValue.errorMessage)
                    }
                } else if (completionClosure != nil) {
                    completionClosure!(nil, false, "Something went wrong. Please try again later".localized)
                }
            case .failure(let error):
                print("Request to \(targetURL) was failed")
                print(error)
                var errorMessage = "Something went wrong. Please try again later".localized
                if response.response?.statusCode == 401 {
                    errorMessage = "Wrong username or password".localized
                }
                if (completionClosure != nil) {
                    completionClosure!(nil, false, errorMessage)
                }
            }
        }
    }
    
    fileprivate func sendGETRequest(_ targetURL: String, params: [String: AnyObject]? = nil, addToken: Bool, completionClosure: ((_ resultJSON: [String: AnyObject]?, _ success: Bool, _ errorMessage: String?) -> ())?) {
        var authHeader = nil as [String: String]?
        if addToken {
            authHeader = ["Authorization": "Bearer " + token!] as [String: String]?
        }
        
        if let parameters = params {
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
                
                print(string)
            } catch {
                print("Cannot display params for url \(targetURL)")
                return
            }
        }
        
        Alamofire.request(ApiURLs.baseURL + targetURL, method: .get, parameters: params, headers: authHeader)
            .validate()
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("Request to \(targetURL) was successful")
                    
                    if let value = response.result.value as? [String: AnyObject] {
                        let parsedValue = self.parseValue(value)
                        
                        if (completionClosure != nil) {
                            completionClosure!(value, parsedValue.resultResponse, parsedValue.errorMessage)
                        }
                    } else if (completionClosure != nil) {
                        completionClosure!(nil, false, "Something went wrong. Please try again later".localized)
                    }
                case .failure(let error):
                    print("Request to \(targetURL) was failed")
                    print(error)
                    if (completionClosure != nil) {
                        completionClosure!(nil, false, "Something went wrong. Please try again later".localized)
                    }
                }
        }
    }
    
    fileprivate func parseValue(_ value: [String: AnyObject]) -> (resultResponse: Bool, errorMessage: String?) {
        var resultResponse: Bool = true
        var errorMessage: String? = nil
        
        if let success = value["success"] as? Bool {
            resultResponse = success
        }
        
        if resultResponse == false {
            errorMessage = "Something went wrong. Please try again later".localized
        }
        
        if let errors = value["error"] as? [String: AnyObject] {
            if let messsage = errors["message"] as? String {
                errorMessage = messsage
            }
        }
        
        return (resultResponse, errorMessage)
    }    
}
