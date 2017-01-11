
import Foundation

class CacheManager {
    static let sharedInstance = CacheManager()
    fileprivate init () {}
    
    fileprivate let cachedFile = "categories.plist"
    fileprivate let cachedFolder = "CachedCategories"
    
    fileprivate let openingTimesKey = "openingTimes"
    var openingTimes: [OpeningDay]? {
        set {
            if newValue != nil {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue!)
                UserDefaults.standard.set(data, forKey: openingTimesKey)
            }
        }
        
        get {
            if let data = UserDefaults.standard.object(forKey: openingTimesKey) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [OpeningDay]
            }
            
            return nil
        }
    }
    
    func getCategoriesCacheFolder() -> String? {
        let fileManager = FileManager.default
        let documentDirs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard documentDirs.count > 0 else {
            return nil
        }
        
        let cacheDir = documentDirs.first!.appendingPathComponent(cachedFolder)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: cacheDir.path, isDirectory: &isDir) else {
            do {
                try fileManager.createDirectory(atPath: cacheDir.path, withIntermediateDirectories: false, attributes: nil)
                
                print("File created")
            } catch {
                
            }
            
            return cacheDir.path
            
        }
        
        return cacheDir.path
    }
    
    func getCategoriesCacheFilePath() -> String? {
        if let folder = self.getCategoriesCacheFolder() {
            return folder + "/" + self.cachedFile
        }
        return nil
    }
    
    func cacheCategories(_ categories: [Category]) {
        if let folder = self.getCategoriesCacheFilePath() {
            let archived = NSKeyedArchiver.archiveRootObject(categories, toFile: folder)
            print(archived)
        }
    }
    
    func getCachedCategories() -> [Category]? {
        let fileManager = FileManager.default
        if let folder = getCategoriesCacheFilePath() {
            if fileManager.fileExists(atPath: folder) {
                if let categories = NSKeyedUnarchiver.unarchiveObject(withFile: folder) as? [Category] {
                    return categories
                }
            }
        }
        
        return nil
    }
    
    func cacheImageData(_ data: Data, forKey key: String) {
        if let folder = getCategoriesCacheFolder() {
            let imagePath = folder + "/" + key.components(separatedBy: "/").last!
            
            do {
                try data.write(to: URL(fileURLWithPath: imagePath), options: .atomic)
            } catch {
                print("Cannot save image to file")
            }
        }
    }
    
    func getImageDataForKey(_ key: String) -> Data? {
        if let folder = getCategoriesCacheFolder() {
            let imagePath = folder + "/" + key.components(separatedBy: "/").last!
            
            if FileManager.default.fileExists(atPath: imagePath) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: imagePath), options: .alwaysMapped)
                    
                    return data
                } catch {
                    print("Cannot read data from file")
                }
            }
        }
        
        return nil
    }
}
