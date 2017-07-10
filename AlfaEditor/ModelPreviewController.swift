//
//  ModelPreviewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import SceneKit


class ModelPreviewController: NSViewController {

	@IBOutlet weak var sceneView: SCNView!
	let scene = SCNScene()


	override func viewDidLoad() {
		super.viewDidLoad()
		sceneView.scene = scene
sceneView.backgroundColor = NSColor.black
		sceneView.showsStatistics = true
		sceneView.allowsCameraControl = true

				NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: addNode)
	}

	override var representedObject: Any? {
		didSet {
			sceneView.scene = scene
				NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: addNode)
		}
	}

	override func viewWillDisappear() {
		for childNode in scene.rootNode.childNodes{
			childNode.removeFromParentNode()
		}
		NotificationCenter.default.removeObserver(self)
	}

	func addNode(notification: Notification){
		if let node = (notification.userInfo?["node"] as? SCNNode){
			scene.rootNode.addChildNode(node)
		}
	}



}

