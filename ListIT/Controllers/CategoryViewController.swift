import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
	
	let realm = try! Realm()
	var categoryArray: Results<Categories>?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadFullCategoryItems()
		showSearchBar()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
	
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setStatusBar(backgroundColor: UIColor(hexString: "444576")!)
		navigationController?.navigationBar.setNeedsLayout()
	}
	
	// MARK: - Tableview Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categoryArray?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "Nothing added"
		
		if let color = categoryArray?[indexPath.row].color {
			cell.backgroundColor = UIColor(hexString: color)
			
			guard let categoryColor = UIColor(hexString: color) else {fatalError()}
			
			cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
			
			cell.textLabel?.font = UIFont(name: "Noteworthy Light", size: 18)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "showCatgory", sender: self)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! TodoListViewController
		if let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCategory = categoryArray?[indexPath.row]
		}
		navigationItem.backButtonTitle = "Categories"
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		
		guard let editAndDelete = super.tableView(tableView, editActionsForRowAt: indexPath, for: orientation) else {fatalError()}
		
		let deleteCellAction = editAndDelete[0]
		let editCellNameAction = editAndDelete[1]
		
		let randomColorAction = SwipeAction(style: .default, title: "Color") { action, indexPath in
			// handle action by updating model with deletion
			self.updateModel(for: indexPath, at: "Color")
		}
		
		randomColorAction.image = UIImage(named: "color-icon")
		randomColorAction.backgroundColor = UIColor(hexString: "FBC7F7")
		
		return [deleteCellAction, editCellNameAction, randomColorAction]
		
	}
	
	//MARK: - Add New Category
	@IBAction func addPressed(_ sender: UIBarButtonItem) {
		
		var textField = UITextField()
		let alertPopup = UIAlertController(title: "Category", message: "Create a new category of items", preferredStyle: .alert)
		let actionButton = UIAlertAction(title: "Add", style: .default) { action in
			if textField.text != "" {
				let categories = Categories()
				categories.name = textField.text!
				categories.color = UIColor.randomFlat().hexValue()
				categories.dateCreated = Date()
				self.saveCategoryItems(with: categories)
			} else {
				super.emptyCellError()
			}
		}
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alertPopup.addTextField { alertTextField in
			alertTextField.placeholder = "Add a category"
			textField = alertTextField
		}
		
		alertPopup.addAction(actionButton)
		alertPopup.addAction(cancelButton)
		present(alertPopup, animated: true) {
			super.dismissOnTapOutside(alertPopup)
		}
	}
	
	//MARK: - Save
	
	func saveCategoryItems(with category: Categories) {
		do {
			try realm.write({
				realm.add(category)
			})
		} catch {
			print("Error saving context --> \(error)")
		}
		tableView.reloadData()
	}
	
	//MARK: - Load UI
	
	func loadFullCategoryItems() {
		categoryArray = realm.objects(Categories.self).sorted(byKeyPath: "dateCreated", ascending: false)
		tableView.reloadData()
	}
	
	func loadFilteredCategoryItems(with text: String) {
		categoryArray = categoryArray?.filter("name CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: false)
		tableView.reloadData()
	}
	
	
	//MARK: - Edit Category
	
	override func updateModel(for indexPath: IndexPath, at swipeButton: String) {
		if let cell = self.categoryArray?[indexPath.row] {
			
			do {
				try self.realm.write {
					switch swipeButton {
					case "Delete":
						self.realm.delete(cell)
					case "Edit":
						//Update category name alert
						var textField = UITextField()
						let alertPopup = UIAlertController(title: "Update Category Name", message: nil, preferredStyle: .alert)
						
						let actionButton = UIAlertAction(title: "Update", style: .default) { action in
							
							if textField.text != "" {
								try! self.realm.write {
									cell.name = textField.text
									self.tableView.reloadData()
								}
							} else {
								super.emptyCellError()
							}
							
						}
						let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
						
						alertPopup.addTextField { UITextField in
							UITextField.placeholder = "Update Category"
							textField = UITextField
						}
						alertPopup.addAction(actionButton)
						alertPopup.addAction(cancelButton)
						
						present(alertPopup, animated: true) {
							super.dismissOnTapOutside(alertPopup)
						}
						
					case "Color":
						cell.color = UIColor.randomFlat().hexValue()
						tableView.reloadData()
					default:
						return
					}
				}
			} catch {
				print(error)
			}
		}
	}
}

//MARK: - UISearchBarDelegate
extension CategoryViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let text = searchBar.text {
			loadFilteredCategoryItems(with: text)
		}
		dismissSearch(searchBar)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		loadFullCategoryItems()
		dismissSearch(searchBar)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text?.count == 0 {
			loadFullCategoryItems()
		}
	}
	
	func dismissSearch(_ searchBar: UISearchBar) {
		DispatchQueue.main.async {
			searchBar.resignFirstResponder()
		}
	}
	
}

//MARK: - UISearchResultsUpdating

extension CategoryViewController: UISearchResultsUpdating {
	
	func showSearchBar() {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchBar.delegate = self
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		navigationItem.searchController = searchController
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		if let text = searchController.searchBar.text {
			if text != "" {
				loadFullCategoryItems()
				loadFilteredCategoryItems(with: text)
			} else {
				loadFullCategoryItems()
			}
		}
	}
	
}
