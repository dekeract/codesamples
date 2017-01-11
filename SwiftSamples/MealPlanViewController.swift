
import UIKit

class MealPlanViewController: MainViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "ProductTableViewCell";
    
    @IBOutlet weak var mealTitleLabel: UILabel?
    @IBOutlet weak var mealsTableView: UITableView?
    
    private var meals = [Meal]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(MealPlanViewController.updateMealPlan), forControlEvents: .ValueChanged)
        refreshControl.tintColor = .activityIndicatorColor()
        mealsTableView?.addSubview(refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		
		if let user = NetworkManager.sharedInstance.user {
			if let phaseName = user.currentPhaseName {
				mealTitleLabel?.text = phaseName.uppercaseFirst()
			} else {
				mealTitleLabel?.text = "Voedinsschema fase".localized + " " + String(user.currentPhaseNumber)
			}
		}

		if meals.count == 0 {
			showIndicatorView()
		}
        
        updateMealPlan()
    }
    
    override func headerLabelTitle() -> String {
        return "My meal plan".localized.uppercaseString
    }
    
    func updateMealPlan() {
        NetworkManager.sharedInstance.getMealPlanInfo {[weak self] (success, meals) in
            self?.checkNetworkStatus()
            self?.refreshControl.endRefreshing()
            if success {
                self?.hideIndicatorView()
                self?.meals = meals!
                self?.mealsTableView?.reloadData()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return meals.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals[section].products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! ProductTableViewCell
        
        cell.product = meals[indexPath.section].products[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: MealTableViewCell.headerHeight))
        headerView.backgroundColor = .mealPlanHeaderColor()
        
        let headerLabel = UILabel(frame: CGRect(x: 13, y: 5, width: 307, height: 21))
        headerLabel.textColor = .whiteColor()
        headerLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        headerLabel.text = meals[section].name.capitalizedString
        
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let product = meals[indexPath.section].products[indexPath.row]
        
        let sizeLabel = UILabel()
        sizeLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        sizeLabel.numberOfLines = 0
        sizeLabel.text = product.name
        let size = sizeLabel.sizeThatFits(CGSize(width: 65.0, height: DBL_MAX))
        
        var height = size.height
        if height < 35 {
            height = 35
        }
        return height
    }
}
