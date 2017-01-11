
import UIKit

class SideMenuCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView?
    @IBOutlet weak var itemNameLabel: UILabel?
    @IBOutlet weak var upperDivider: UIView?
    @IBOutlet weak var offersCountLabel: UILabel?
    @IBOutlet weak var offersCountBackgroundImageView: UIImageView?
    
    @IBOutlet weak var imageLeftConstraint: NSLayoutConstraint?
    
    var imageLeftOffset: CGFloat {
        if UIScreen.mainScreen().bounds.height == 568 {
            return 20.0
        } else {
            return 45.0
        }
    }
    
    var menuItem: SideMenuItem? {
        didSet {
            itemImageView?.image = UIImage(named: menuItem?.imageName ?? "")
            itemNameLabel?.text = menuItem?.name
        }
    }
    
    var observerForOffers: Bool = false {
        didSet {
            if observerForOffers {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideMenuCell.offersDidLoaded(_:)), name: offersDidLoadedNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().removeObserver(self)
            }
        }
    }
    
    var offersCount: Int = 0 {
        didSet {
            offersCountLabel?.hidden = (offersCount == 0 || !observerForOffers)
            offersCountBackgroundImageView?.hidden = (offersCount == 0 || !observerForOffers)
            offersCountLabel?.text = String(offersCount)
        }
    }
    
    var showUpperDivider: Bool = false {
        didSet {
            upperDivider?.hidden = !showUpperDivider
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: frame)
        selectedView.backgroundColor = .sideMenuSelectedColor()
        
        selectedBackgroundView = selectedView
        
        imageLeftConstraint?.constant = imageLeftOffset
        offersCountLabel?.layer.cornerRadius = (offersCountLabel?.frame.width ?? 0) / 2
        offersCountLabel?.hidden = true
        offersCountBackgroundImageView?.hidden = true
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            itemNameLabel?.font = UIFont(name: "Lato-Bold", size: 18)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        offersCountLabel?.hidden = true
        offersCountBackgroundImageView?.hidden = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func offersDidLoaded(notification: NSNotification) {
        let offersCount = notification.userInfo![offersCountKey] as! Int
        self.offersCount = offersCount
    }
}
