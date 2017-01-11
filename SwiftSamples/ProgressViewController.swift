
import UIKit

class ProgressViewController: MainViewController {
	
	@IBOutlet weak var parametersSegmentedControll: UISegmentedControl!
	@IBOutlet weak var progressDisplayView: ProgressDisplayView!
	@IBOutlet weak var progressParamtersDisplayView: ProgressParametersDisplayView!
	@IBOutlet weak var progressPhotosDisplayView: ProgressPhotosDisplayView!
	
	var progress: [ProgressWeek]? {
		didSet {
			progressDisplayView.progress = progress
			let reportBy = ProgressWeekReportBy(rawValue: parametersSegmentedControll.selectedSegmentIndex)!
			progressDisplayView.reloadForReportBy(reportBy)
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProgressViewController.loadData), name: AppNotification.progressUpdated, object: nil)
		progressDisplayView.delegate = self
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		loadData()
	}
	
	func loadData(){
		if progress == nil {
			showIndicatorView()
		}
		NetworkManager.sharedInstance.getProgressInfo { [weak self] (success, progress) in
            self?.checkNetworkStatus()
			self?.progress = progress
			self?.hideIndicatorView()
		}
	}

	@IBAction func parameterChanged(sender: UISegmentedControl) {
		let reportBy = ProgressWeekReportBy(rawValue: sender.selectedSegmentIndex)!
		progressDisplayView.reloadForReportBy(reportBy)
	}
	
    override func headerLabelTitle() -> String {
        return "Progress".localized.uppercaseString
    }
}

// MARK: - UITextFieldDelegate
extension ProgressViewController: ProgressDisplayViewDelegate {
	func dayChanged(day: Int) {
		progressPhotosDisplayView.currentDay = day
		if let p = progress {
			progressParamtersDisplayView.progress = p[day]
			progressPhotosDisplayView.progress = p[day]
		} else {
			progressParamtersDisplayView.progress = nil
			progressPhotosDisplayView.progress = nil
		}
		
	}
}
