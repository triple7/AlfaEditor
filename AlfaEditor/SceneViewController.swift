//
//  SceneViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//
import AppKit
import Foundation
import Cocoa
import SceneKit

class SceneViewController: NSViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate{
	var leap:LeapMotionManager!
	@IBOutlet var sceneView: SCNView!
	let scene = SCNScene()
var started = false
let selector = SCNNode(geometry: SCNTorus(ringRadius: 20.0, pipeRadius: 40.0))

	override func viewDidLoad() {
		super.viewDidLoad()
sceneView.scene = scene
		sceneView.showsStatistics = true
		sceneView.backgroundColor = NSColor.black
sceneView.allowsCameraControl = true

		//Add the selection torus
		//scene.rootNode.addChildNode(selector)
		//Start the processing of the .SVG file (default one)
		let url = assets.retrieveSVG(name: "mpc")
		assets.parser.parse(fromFileURL: url)
		assets.renderer.calibrateScene()
		scene.rootNode.addChildNode(assets.renderer.sceneNode)
		print("camera has position \(assets.renderer.cameraNode.worldTransform.description)")
		scene.rootNode.addChildNode(assets.renderer.cameraNode)
		leap = LeapMotionManager.sharedInstance
		leap.run()
		sceneView.autoenablesDefaultLighting = true
		sceneView.loops=true
sceneView.delegate = self
		sceneView.isPlaying = true
		scene.physicsWorld.contactDelegate = self
		for node in assets.renderer.sceneNode.childNodes{
			print(node.position)
		}
	}

	override var representedObject: Any? {
		didSet {
sceneView.loops = true		}
	}

	override func viewDidDisappear() {
		sceneView.loops = false
	}

	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
		/*
		if !started{
			layerEngine.playInterfaceFX("focused")
			started = true
		}
*/
	}

	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
		var startPoint = leap!.point
		selector.position = SCNVector3(x: startPoint.x, y: startPoint.y, z: 150.0)
		var endPoint = startPoint
		startPoint.z = 100.0
		endPoint.z = -100.0
//print("\(startPoint.x), \(startPoint.y)")
		let contact = scene.physicsWorld.rayTestWithSegment(from: startPoint,	to: endPoint, options: nil)
		if contact.count > 0{
			assets.speech.startSpeaking(contact[0].node.name!)
		}
	}


}

