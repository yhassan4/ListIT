//
//  NavigationController.swift
//  ListIT
//
//  Created by Yaasir Hassan on 9/1/21.
//

import UIKit

class NavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override var childForStatusBarStyle: UIViewController? {
		topViewController
	}
	
}
