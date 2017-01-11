
import Foundation

protocol JSONModelProtocol {
    var id: Int {get}
    
    init(dict: Dictionary<String, AnyObject>)
}
