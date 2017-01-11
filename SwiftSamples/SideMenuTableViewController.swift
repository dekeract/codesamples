
import UIKit

class SideMenuItem {
    var imageName: String = ""
    var name: String = ""
    var headerName: String = ""
    var viewController: UIViewController?
    
    convenience init(_ imageName: String, name: String, headerName: String? = nil, viewController: UIViewController?) {
        self.init()
        
        self.imageName = imageName
        self.name = name
        self.headerName = headerName ?? name
        self.viewController = viewController
    }
}

protocol SideMenuTableViewControllerDelegate: class {
    func sideMenuItemDidSelect(menuItem: SideMenuItem, atIndex index: Int)
    func currentOffersCount() -> Int
    func lastSelectedIndex() -> Int
}

class SideMenuTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let profileViewControllerIdentifier = "ProfileViewController"
    let aboutViewContollerIdentifier = "AboutViewController"
    
    let cellIdentifier = "SideMenuCell"
    
    @IBOutlet weak var sideMenuTableView: UITableView?
    @IBOutlet weak var headerWidthConstraint: NSLayoutConstraint?
    
    weak var delegate: SideMenuTableViewControllerDelegate?
    
    var sideMenuItems = [SideMenuItem]()
    
    var cellHeight: CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 72.0
        } else {
            return 66.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuItems.append(SideMenuItem("offersMenuIcon", name: "Offers".localized.uppercaseString, viewController: UIStoryboard.offersStoryboard().instantiateInitialViewController()))
        sideMenuItems.append(SideMenuItem("profileMenuIcon", name: "My profile".localized.uppercaseString, headerName:"Profile".localized.uppercaseString, viewController: UIStoryboard.profileStoryboard().instantiateViewControllerWithIdentifier(profileViewControllerIdentifier)))
        sideMenuItems.append(SideMenuItem("aboutMenuIcon", name: "About us".localized.uppercaseString, viewController: UIStoryboard.menuStoryboard().instantiateViewControllerWithIdentifier(aboutViewContollerIdentifier)))
        sideMenuItems.append(SideMenuItem("logoutMenuIcon", name: "Log Out".localized.uppercaseString, viewController: nil))
        
        let selectedIndexPath = NSIndexPath(forItem: delegate?.lastSelectedIndex() ?? 0, inSection: 0)
        sideMenuTableView?.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .None)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            headerWidthConstraint?.constant = UIScreen.mainScreen().bounds.width
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! SideMenuCell
        
        cell.menuItem = sideMenuItems[indexPath.row]
        cell.showUpperDivider = (indexPath.row == 0)
        
        cell.observerForOffers = (indexPath.row == 0)
        cell.offersCount = self.delegate?.currentOffersCount() ?? 0
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) { 
            self.delegate?.sideMenuItemDidSelect(self.sideMenuItems[indexPath.row], atIndex: indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
}
