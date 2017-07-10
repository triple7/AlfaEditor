//
//  NodeGeometryViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import SceneKit


class NodeGeometryViewController: NSViewController {

	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var typeLabel: NSTextField!

	@IBOutlet weak var nameField: NSTextField!
	@IBOutlet weak var typeChoose: NSPopUpButton!
	@IBOutlet weak var geometryTitle: NSTextField!

	var geometryString:String!{
		didSet{
geometryTitle.stringValue = "Geometry: \(geometryString!)"
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(nameLabel)
		view.addSubview(nameField)
		view.addSubview(typeLabel)
		view.addSubview(typeChoose)
		view.addSubview(geometryTitle)
				NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: updateParameters)
	}

	override var representedObject: Any? {
		didSet {
				NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: updateParameters)		}
	}

	override func viewDidDisappear() {
NotificationCenter.default.removeObserver(self)
	}

	func updateParameters(notification: Notification){
		if notification.userInfo?["new"] as! Bool{
			nameField.stringValue = ""
			geometryString = "none"
			typeChoose.selectItem(at: 5)
		}
		if let node = notification.userInfo?["node"] as? SCNNode{
nameField.stringValue = node.name!
			switch node.geometry!{
			case is SCNBox: geometryString = "box"
			typeChoose.selectItem(at: 0)
			case is SCNCylinder: geometryString = "cylinder"
			typeChoose.selectItem(at: 1)
			default: geometryString = "custom"
			typeChoose.selectItem(at: 5)
			}
		}
	}

}




//end of file
