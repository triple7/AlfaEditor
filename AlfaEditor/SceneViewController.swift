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
	//var leap:LeapMotionManager!
	@IBOutlet var sceneView: SCNView!
	var scene = SCNScene()
var started = false
let soundNode = SCNNode()

	let controller = LeapController()
	var rightHandPosition = LeapVector()
	var leftHandPosition = LeapVector()

	//Shared coordinates as Vector3D
	var leapX:CGFloat = 0.0{
		didSet{
self.soundNode.position.x = self.leapX
			self.endPoint.x = self.leapX
		}
	}
	var leapY:CGFloat = 0.0{
		didSet{
self.soundNode.position.y = self.leapY
			self.startPoint = self.soundNode.position
			self.endPoint.y = self.leapY
		}
	}
	var gestureFlag = false
	let paperToLensHeight:Int = 222
	let paperHeight:Int = 297
	let paperWidth:Int = 210
	var frameCount = 0

	//Raw image view for free rotation

	//RawData and conversion
	var imageRepresentative:NSImageRep?
	var lastWidth:Int?
	var lastheight:Int?
	var ID:Int?

	override func viewDidLoad() {
		super.viewDidLoad()
sceneView.scene = scene
		sceneView.showsStatistics = false
		sceneView.backgroundColor = NSColor.white
sceneView.allowsCameraControl = true
soundNode.position.z = 300.0
		//Start the processing of the .SVG file (default one)
		let url = assets.retrieveSVG(name: "mpc.svg")
		assets.parser.parse(fromFileURL: url)
		assets.renderer.calibrateScene()
		scene.rootNode.addChildNode(assets.renderer.sceneNode)
		scene.rootNode.addChildNode(assets.renderer.cameraNode)

		//Load sound assets associated to the SVG file
		assets.loadSounds(name: "mpc")
		scene.rootNode.addChildNode(soundNode)
		run()
		sceneView.autoenablesDefaultLighting = true
		sceneView.loops=true
sceneView.delegate = self
		sceneView.isPlaying = true
		scene.physicsWorld.contactDelegate = self
physicsWorld = scene.physicsWorld

		functions.append(samplerGesture)
		functions.append(mapGesture)
		NotificationCenter.default.addObserver(forName: newSVGNotification, object: nil, queue: nil, using: changeSVG)
	}

	override var representedObject: Any? {
		didSet {
sceneView.loops = true		}
	}

	override func viewDidDisappear() {
		sceneView.loops = false
	}

	func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
	}

	var startPoint = SCNVector3Zero
	var endPoint = SCNVector3(x: 0.0, y: 0.0, z: -200.0)
	var currentNode = ""
	var physicsWorld:SCNPhysicsWorld!
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
				DispatchQueue.global(qos: .userInteractive).async{
		let contact = self.physicsWorld.rayTestWithSegment(from: self.startPoint,	to: self.endPoint, options: nil)
		if contact.count > 0{
			let contacted = contact[0].node
				if self.currentNode != contacted.name!{
					print(self.currentNode)
				self.currentNode = contacted.name!
self.highlightNode(node: contacted)
						assets.speech.startSpeaking(self.currentNode)
					}
		}else{
self.unhighlightNodes()
					}
		}
	}

	func highlightNode(node: SCNNode){
		for nodeB in assets.sceneNodes{
			if node.isEqual(nodeB){
				node.geometry?.materials = [assets.selectedMaterial]
			}else{
				nodeB.geometry?.materials = [assets.unselectedMaterial]
				nodeB.opacity = 0.6
			}
		}
	}

	func unhighlightNodes(){
		for node in assets.sceneNodes{
			node.geometry?.materials = assets.nodeMaterials[assets.sceneNodes.index(of: node)!]
			node.opacity = 1.0
		}
	}

	func changeSVG(notification: Notification){
		for node in scene.rootNode.childNodes{
			node.removeFromParentNode()
		}
let name = notification.object as! String
		assets.resetScenes()
		let url = assets.retrieveSVG(name: name)
		assets.parser.parse(fromFileURL: url)
		assets.renderer.calibrateScene()
		scene.rootNode.addChildNode(assets.renderer.sceneNode)
		assets.renderer.sceneNode.name = "scene"
		scene.rootNode.addChildNode(assets.renderer.cameraNode)
		//Load sound assets associated to the SVG file
		assets.loadSounds(name: name, type: "map")
		soundNode.position.z = 5.0
		scene.rootNode.addChildNode(soundNode)
sceneView.pointOfView = soundNode
		if assets.appType == 1{
			for child in scene.rootNode.childNode(withName: "scene", recursively: true)!.childNodes{
child.addAudioPlayer(SCNAudioPlayer(source: assets.sounds[assets.soundIndices.index(of: "\(child.name!).mp3")!]))
			}
			assets.speech.startSpeaking("\(name) loaded")
			}
	}

	//Mark: function array for the type of SVG being used

	var functions = [()->Void]()

	func samplerGesture(){
		if currentNode != ""{
		self.soundNode.addAudioPlayer(SCNAudioPlayer(source: assets.sounds[assets.soundIndices.index(of: "\(currentNode).wav")! ]))
		}
	}

	func mapGesture(){

	}

}

