
import UIKit

class DialogueBaseViewController: UIViewController {
	
	let cornerRadius = CGFloat(8.0)
	
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var actionView: UIView!
	
	class func animationDuration () -> NSTimeInterval {
		return 0.45
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willChangeStatusBarFrame(_:)), name: UIApplicationWillChangeStatusBarFrameNotification, object: nil)
    }
	
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func willChangeStatusBarFrame(notification: NSNotification) {
        if let userInfo = notification.userInfo
        {
            if let value = userInfo[UIApplicationStatusBarFrameUserInfoKey] as? NSValue
            {
                let statusBarFrame = value.CGRectValue()
                let transitionView = UIApplication.sharedApplication().delegate!.window!!.subviews.last! as UIView
                var frame = transitionView.frame
                frame.origin.y = statusBarFrame.height-20
                frame.size.height = UIScreen.mainScreen().bounds.height-frame.origin.y
                UIView.animateWithDuration(0.35) {
                    transitionView.frame = frame
                }
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            self.view.frame = self.presentingViewController!.view.frame
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
