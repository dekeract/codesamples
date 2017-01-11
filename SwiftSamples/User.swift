
import Foundation
import CoreLocation
import SAMKeychain

class User: JSONModelProtocol {
    private let keychainName = "appx"
    private let dateFormat = "hh:mm"
    
    var id: Int = 0
    var nameOfBussiness: String = ""
    var location: CLLocationCoordinate2D?
    var address: String?
    var days = [OpeningDay]()
    var phoneNumber: String?
    var email: String?
    var password: String?
    
    var deviceID: String {
        if let deviceIdentifier = SAMKeychain.passwordForService(keychainName, account: keychainName) {
            return deviceIdentifier
        } else {
            let deviceIdentifier = UIDevice.currentDevice().identifierForVendor?.UUIDString
            SAMKeychain.setPassword(deviceIdentifier, forService: keychainName, account: keychainName)
            return deviceIdentifier!
        }
    }
    
    var formattedDaysString: String {
        var formattedString = ""
        for day in days {
            if !day.isDayOff {
                let string = day.name
                formattedString.appendContentsOf(string.substringToIndex(string.startIndex.advancedBy(3)))
                formattedString = formattedString + ", "
            }
        }
        let charctersSet = NSCharacterSet(charactersInString: ", ")
        return formattedString.stringByTrimmingCharactersInSet(charctersSet)
    }
    
    init() {
        initDays()
    }
    
    required init(dict: Dictionary<String, AnyObject>) {
        
        initDays()
        
        id = dict["id"] as? Int ?? 0
        email = dict["email"] as? String ?? ""
        nameOfBussiness = dict["name"] as? String ?? ""
        phoneNumber = dict["phone"] as? String ?? ""
        
        if let locationDict = dict["location"] as? [String: AnyObject] {
            address = locationDict["address"] as? String ?? ""
            let latitude = locationDict["lat"] as? Double
            let longtitude = locationDict["lng"] as? Double
            
            if latitude != nil && longtitude != nil {
                location = CLLocationCoordinate2D(latitude: latitude!, longitude: longtitude!)
            }
        }
        
        if let scheduleDict = dict["schedules"] as? Array<[String: AnyObject]> {
            for dayDict in scheduleDict {
                if let day = dayForIndex((dayDict["day"] as? Int ?? 0)) {
                    let timeOnString = dayDict["open_time"] as? String ?? ""
                    day.timeOn = timeOnString.toDate("HH:mm:ss")
                    
                    let timeOffString = dayDict["close_time"] as? String ?? ""
                    day.timeOff = timeOffString.toDate("HH:mm:ss")
                }
            }
        }
    }
    
    func toRegDict() -> [String: AnyObject] {
        return ["main": ["email": email!, "password": password!, "device_id": deviceID, "push_id": deviceID],
                "info": ["name": nameOfBussiness, "phone": phoneNumber!.toDecimal()],
                "location": ["address": address!, "lat": location!.latitude, "lng": location!.longitude],
                "schedules": getDaysDict()]
    }
    
    func getDaysDict() -> Array<[String: AnyObject]> {
        var daysDictArray = [[String: AnyObject]]()
        for day in days {
            if !day.isDayOff {
                daysDictArray.append(["day": day.index, "open_time": (day.timeOn?.toString(dateFormat))!, "close_time": (day.timeOff?.toString(dateFormat))!])
            }
        }
        return daysDictArray
    }
    
    private func initDays() {
        days.append(OpeningDay(name: "Monday"))
        days.append(OpeningDay(name: "Tuesday"))
        days.append(OpeningDay(name: "Wednesday"))
        days.append(OpeningDay(name: "Thursday"))
        days.append(OpeningDay(name: "Friday"))
        days.append(OpeningDay(name: "Saturday"))
        days.append(OpeningDay(name: "Sunday"))
    }
    
    private func dayForIndex(index: Int) -> OpeningDay? {
        for day in days {
            if day.index == index {
                return day
            }
        }
        return nil
    }
    
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String, completionClosure: ((success: Bool, errorMessage: String?) -> ())?) {
        NetworkManager.sharedInstance.changePassword(oldPassword, newPassword: newPassword, confirmPassword: confirmPassword) { (success, errorMessage) in
            if completionClosure != nil {
                completionClosure!(success: success, errorMessage: errorMessage)
            }
        }
    }
    
    func updateProfile(email: String, phone: String, name: String, completionClosure: ((success: Bool, errorMessage: String?) -> ())?) {
        
        var mainDict: [String: AnyObject]?
        var infoDict: [String: AnyObject]?
        var locationDict: [String: AnyObject]?
        
        if self.email != email {
            mainDict = ["email": email]
        }
        
        if self.phoneNumber != phone.toDecimal() || self.nameOfBussiness != name {
            infoDict = [String: AnyObject]()
            if phoneNumber != phone.toDecimal() {
                infoDict!["phone"] = phone.toDecimal()
            }
            if nameOfBussiness != name {
                infoDict!["name"] = name
            }
        }
        
        if address != nil {
            locationDict = ["address": address!, "lat": location!.latitude, "lng": location!.longitude]
        }
        
        NetworkManager.sharedInstance.updateUserProfile(mainDict, infoDict: infoDict, locationDict: locationDict, days: getDaysDict()) { (success, errorMessage) in
            if completionClosure != nil {
                completionClosure!(success: success, errorMessage: errorMessage)
            }
        }
    }
}
