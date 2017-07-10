//
//  NodeBehaviorViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Cocoa
import Foundation
import SceneKit

class NodeBehaviorViewController: NSViewController {
	var behaviorType:NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()
behaviorType = NSTextField(labelWithString: "Behavior type: ")
view.addSubview(behaviorType)
//		view.addSubview(behaviorChoose)
//		view.addSubview(descriptionField)
		NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: updateParameters)
	}

	override var representedObject: Any? {
		didSet {
			NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: updateParameters)		}
	}

	func updateParameters(notification: Notification){
print("ok motherfuckers, this is working shitPussyDickCunt")
	}

	override func viewDidDisappear() {
		NotificationCenter.default.removeObserver(self)
	}


}
