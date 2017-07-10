//
//  MainNodeModificationViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import SceneKit

class MainNodeModificationViewController: NSViewController {
	var currentEdit:NodeFeatures?
	var newNode:SCNNode?
	var new:Bool?

	override func viewDidLoad() {
		super.viewDidLoad()
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
		if let new = (notification.userInfo?["new"] as? Bool){
			if new{
			self.new = new
currentEdit = NodeFeatures(audioSources: nil, triggers: nil, nodeDescription: nil, HTMLPage: nil)
			newNode = SCNNode()
				self.title = "New node"
			}else{
		if let node = (notification.userInfo?["node"] as! SCNNode).name{
		self.title = "Edit: \(node)"
		}
		}
		}
	}

	override func keyDown(with event: NSEvent) {
		interpretKeyEvents([event])
	}

	override func cancelOperation(_ sender: Any?) {
		dismissViewController(self)
	}


}
