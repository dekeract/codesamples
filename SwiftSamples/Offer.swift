
import Foundation
import UIKit

enum OfferStatus: String {
    case Available, Expired, Claimed, Completed
}

class Offer: JSONModelProtocol {
    var id: Int = 0
    var imageURL: String?
    var name: String = ""
    var expiredString: String?
    var claimed: Bool = false
    var status: OfferStatus = .Expired
    var category: String = ""
    
    var formatterExpiredTime: String {
        guard let expiredTime = expiredString else {
            return ""
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let date = dateFormatter.dateFromString(expiredTime)
        dateFormatter.dateFormat = "hh a"
        if date != nil {
            return dateFormatter.stringFromDate(date!)
        } else {
            return ""
        }
        
    }
    
    init() {
        name = "Test offer"
    }
    
    required init(dict: Dictionary<String, AnyObject>) {
        id = dict["id"] as? Int ?? 0
        imageURL = dict["image"] as? String ?? ""
        expiredString = dict["expires"] as? String ?? ""
        name = dict["name"] as? String ?? ""
        category = dict["category"] as? String ?? ""
        
        status = OfferStatus(rawValue: dict["status"] as? String ?? "Expired")!
    }
    
    
    func discardOffer(completionClosure: ((success: Bool) -> ())?) {
        NetworkManager.sharedInstance.discardOffer(id) { [weak self] (success) in
            if success {
                self?.status = .Expired
            }
            
            if completionClosure != nil {
                completionClosure!(success: success)
            }
        }
    }
    
    func completeOffer(completionClosure: ((success: Bool) -> ())?) {
        NetworkManager.sharedInstance.completeOffer(id) { [weak self] (success) in
            if success {
                self?.status = .Completed
            }
            
            if completionClosure != nil {
                completionClosure!(success: success)
            }
        }
    }
    
    func loadImage(completionClosure: ((image: UIImage?) -> ())?) {
        NetworkManager.sharedInstance.loadImageFromURL(imageURL!) { (imageData) in
            if imageData != nil {
                let image = UIImage(data: imageData!, scale:1)
                
                if completionClosure != nil {
                    completionClosure!(image: image)
                }
            }
        }
    }
}
