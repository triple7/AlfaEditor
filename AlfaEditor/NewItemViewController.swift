//
//  NewItemViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 29/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import AppKit
import Foundation
import Cocoa

class NewItemViewController:NSViewController{
	@IBOutlet weak var itemLabel: NSTextField!
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var create: NSButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(itemLabel)
		view.addSubview(nameField)
		view.addSubview(create)
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	@IBAction func createItem(_ sender: Any) {
		if itemLabel.stringValue.contains("category"){
			assets.createNewDirectory(name: nameField.stringValue)
		}else{
			assets.createNewFile(name: nameField.stringValue)
		}
		self.dismiss(nil)
	}

}
