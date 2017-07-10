//
//  AddFileViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 7/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import AppKit
import Foundation
import Cocoa


class AddNodeViewController:NSViewController{
	@IBOutlet weak var type: NSTextField!
	@IBOutlet weak var chooseType: NSPopUpButton!
	@IBOutlet weak var name: NSTextField!
	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var create: NSButton!


	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(type)
		view.addSubview(chooseType)
		view.addSubview(name)
		view.addSubview(nameField)
		view.addSubview(create)
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	
}
