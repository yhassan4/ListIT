import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate{
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.rowHeight = 80.0
		tableView.separatorStyle = .none
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
		cell.delegate = self
		return cell
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard orientation == .right else { return nil }
		
		let deleteCellAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
			// handle action by updating model with deletion
			self.updateModel(for: indexPath, at: "Delete")
		}
		
		let editCellNameAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
			// handle action by updating model with deletion
			self.updateModel(for: indexPath, at: "Edit")
		}
		
		// customize the action appearance
		deleteCellAction.image = UIImage(named: "delete-icon")
		deleteCellAction.backgroundColor = UIColor(hexString: "F8485E")
		
		editCellNameAction.image = UIImage(named: "edit-icon")
		editCellNameAction.backgroundColor = UIColor(hexString: "3EB2D6")
		
		return [deleteCellAction, editCellNameAction]
	}
	
	func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .destructive
		options.transitionStyle = .drag
		return options
	}
	
	func updateModel(for indexPath: IndexPath, at swipeButton: String) {
		
	}
	
//MARK: - Alert Methods
	
	func emptyCellError() {
		let noTextAlert = UIAlertController(title: "Missing Input", message: "Name is required!", preferredStyle: .alert)
		let okayButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
		noTextAlert.addAction(okayButton)
		self.present(noTextAlert, animated: true) {
			self.dismissOnTapOutside(noTextAlert)
		}
	}
	
	func dismissOnTapOutside(_ alert: UIAlertController){
		alert.view.superview?.isUserInteractionEnabled = true
		alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert)))
	}
	
	@objc func dismissAlert(){
		self.dismiss(animated: true, completion: nil)
	}
	
}

//MARK: - Navigation Controller Extension

extension UINavigationController {

	func setStatusBar(backgroundColor: UIColor) {
		let statusBarFrame: CGRect
		if #available(iOS 13.0, *) {
			statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
		} else {
			statusBarFrame = UIApplication.shared.statusBarFrame
		}
		let statusBarView = UIView(frame: statusBarFrame)
		statusBarView.backgroundColor = backgroundColor
		view.addSubview(statusBarView)
	}

}
