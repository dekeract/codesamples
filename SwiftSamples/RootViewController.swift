
import UIKit
import SideMenu

class RootViewController: UIViewController, SideMenuTableViewControllerDelegate {
    
    let sideMenuSegueIdentifier = "SideMenuSegue"
    
    @IBOutlet weak var navigationBar: UIView?
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var headerLabel: UILabel?
    @IBOutlet weak var rightHeaderButton: UIButton?
    @IBOutlet weak var menuButton: UIButton?
    
    private var offersCount = 0
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SideMenuManager.menuFadeStatusBar = false
        
        addMenuChildViewController(SideMenuItem("", name: "Offers".localized.uppercaseString, viewController: UIStoryboard.offersStoryboard().instantiateInitialViewController()))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RootViewController.offersDidLoaded(_:)), name: offersDidLoadedNotification, object: nil)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            headerLabel?.font = UIFont(name: "Lato-Bold", size: 18)
            rightHeaderButton?.titleLabel?.font = UIFont(name: "Lato-Bold", size: 15)
            SideMenuManager.menuWidth = 375.0
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func offersDidLoaded(notification: NSNotification) {
        let offersCount = notification.userInfo![offersCountKey] as! Int
        self.offersCount = offersCount
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == sideMenuSegueIdentifier {
            let sideMenuNavigation = segue.destinationViewController as! UISideMenuNavigationController
            let sideMenuTableVC = sideMenuNavigation.viewControllers[0] as! SideMenuTableViewController
            sideMenuTableVC.delegate = self
        }
    }
    
    private func addMenuChildViewController(menuItem: SideMenuItem) {
        let childVCs = childViewControllers
        for (index, _) in childVCs.enumerate() {
            removeChildViewControllerFromView(childViewControllers[index])
        }
        
        addChildViewController(menuItem.viewController!, toView: contentView!)
        
        headerLabel?.text = menuItem.headerName
    }
    
    func sideMenuItemDidSelect(menuItem: SideMenuItem, atIndex index: Int) {
        rightHeaderButton?.hidden = true
        rightHeaderButton?.removeTarget(nil, action: nil, forControlEvents: .AllEvents)

        if menuItem.viewController != nil {
            addMenuChildViewController(menuItem)
            selectedIndex = index
        } else {
            let alertController = AlertViewController.controller()
            alertController.okActionClosure = { (action) in
                NetworkManager.sharedInstance.logout({ (success) in
                    if success {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.updateRootController()
                    }
                })
            }
            alertController.showFromViewController(nil, title: "Log Out".localized, message: "Are you sure you want to Log Out?".localized, mode: .CancelOk)
        }
    }
    
    func currentOffersCount() -> Int {
        return offersCount
    }
    
    func lastSelectedIndex() -> Int {
        return selectedIndex
    }
}
