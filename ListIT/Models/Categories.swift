import Foundation
import RealmSwift

class Categories: Object {
	@objc dynamic var name: String?
	@objc dynamic var color: String = "#1D9BF6"
	@objc dynamic var dateCreated: Date?
	let items = List<Item>()
}
