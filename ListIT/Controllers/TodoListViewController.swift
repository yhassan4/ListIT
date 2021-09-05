import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
	
	@IBOutlet weak var addPressed: UIBarButtonItem!
	
	var itemArray: Results<Item>?
	let noteWorthy = UIFont(name: "Noteworthy Bold", size: 22) ?? UIFont.systemFont(ofSize: 22)
	var statusBarBlack = false
	let realm = try! Realm()
	
	var selectedCategory: Categories? {
		didSet {
			loadFullListItems()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		showSearchBar()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let colorHex = UIColor(hexString: selectedCategory!.color) {
			guard let navBar = navigationController?.navigationBar else {
				fatalError("No nav controller")
			}
			let colorContrast = ContrastColorOf(colorHex, returnFlat: true)
			navBar.barTintColor = colorHex
			navBar.backgroundColor = colorHex
			
			navBar.tintColor = ContrastColorOf(colorHex, returnFlat: true)
			addPressed.tintColor = ContrastColorOf(colorHex, returnFlat: true)
			
			navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorContrast,
										  NSAttributedString.Key.font : noteWorthy]
			navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorContrast,
											   NSAttributedString.Key.font : noteWorthy]
			title = selectedCategory!.name
			
			navigationController?.setStatusBar(backgroundColor: colorHex)
			navigationController?.navigationBar.setNeedsLayout()
			
			if ContrastColorOf(colorHex, returnFlat: true) == FlatBlackDark() {
				statusBarBlack = true
				setNeedsStatusBarAppearanceUpdate()
			}
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarBlack ? .darkContent : .lightContent
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		guard let navBar = navigationController?.navigationBar else {
			fatalError("No nav controller")
		}
		navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "DDF16B")!,
									  NSAttributedString.Key.font : noteWorthy]
		navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "DDF16B")!,
										   NSAttributedString.Key.font : noteWorthy]
		navBar.barTintColor = UIColor(hexString: "444576")
		navBar.backgroundColor = UIColor(hexString: "444576")
		navBar.tintColor = UIColor(hexString: "DDF16B")
	}
	
	//MARK: - TableView Methods
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemArray?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if let item = itemArray?[indexPath.row] {
			cell.textLabel?.text = item.title
			
			if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
				cell.backgroundColor = color
				
				cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
				cell.tintColor = ContrastColorOf(color, returnFlat: true)
				
				cell.textLabel?.font = UIFont(name: "Noteworthy Light", size: 18)
			}
			
			cell.accessoryType = item.done ? .checkmark : .none
			
		} else {
			cell.textLabel?.text = "Nothing added"
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let item = itemArray?[indexPath.row] {
			do {
				try realm.write {
					item.done = !item.done
				}
			} catch {
				print(error)
			}
		}
		
		tableView.reloadData()
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
//MARK: - Add New Item
	
	@IBAction func addPressed(_ sender: UIBarButtonItem) {
		var textField = UITextField()
		let alert = UIAlertController(title: "Add new item to the list", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add", style: .default) { action in
			if textField.text != "" {
				if let currentCategory = self.selectedCategory {
					do {
						try self.realm.write {
							let item = Item()
							item.title = textField.text!
							item.dateCreated = Date()
							currentCategory.items.append(item)
						}
					} catch {
						print("Error saving context: \(error)")
					}
				}
				self.tableView.reloadData()
			} else {
				super.emptyCellError()
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addTextField { alertTextField in
			alertTextField.placeholder = "Create New Item"
			textField = alertTextField
		}
		
		alert.addAction(action)
		alert.addAction(cancel)
		present(alert, animated: true) {
			super.dismissOnTapOutside(alert)
		}
	}
	
//MARK: - Load UI
	
	func loadFullListItems() {
		itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
		tableView.reloadData()
	}
	
	func loadFilteredListItems(with text: String) {
		itemArray = itemArray?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: false)
		tableView.reloadData()
	}
	
//MARK: - Edit List Item
	
	override func updateModel(for indexPath: IndexPath, at swipeButton: String) {
		if let cell = self.itemArray?[indexPath.row] {
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
									cell.title = textField.text
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
extension TodoListViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let text = searchBar.text {
			loadFilteredListItems(with: text)
		}
		dismissSearch(searchBar)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		loadFullListItems()
		dismissSearch(searchBar)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchBar.text?.count == 0 {
			loadFullListItems()
		}
	}
	
	func dismissSearch(_ searchBar: UISearchBar) {
		DispatchQueue.main.async {
			searchBar.resignFirstResponder()
		}
	}
}

//MARK: - UISearchResultsUpdating

extension TodoListViewController: UISearchResultsUpdating {
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
				loadFullListItems()
				loadFilteredListItems(with: text)
			} else {
				loadFullListItems()
			}
		}
	}
}
