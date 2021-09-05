import Foundation
import RealmSwift

class Item: Object {
	@objc dynamic var title: String?
	@objc dynamic var done: Bool = false
	@objc dynamic var dateCreated: Date?
	let parentCategory = LinkingObjects(fromType: Categories.self, property: "items")
}
