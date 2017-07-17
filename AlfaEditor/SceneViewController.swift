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
let selector = SCNNode(geometry: SCNTorus(ringRadius: 120.0, pipeRadius: 40.0))
let soundNode = SCNNode()

	let controller = LeapController()
	var rightHandPosition = LeapVector()
	var leftHandPosition = LeapVector()

	//Shared coordinates as Vector3D
	var point = SCNVector3Zero
	var gestureFlag = false
	let paperToLensHeight:Int = 222
	let paperHeight:Int = 297
	let paperWidth:Int = 210
	var frameCount = 0

	override func viewDidLoad() {
		super.viewDidLoad()
sceneView.scene = scene
		sceneView.showsStatistics = false
		sceneView.backgroundColor = NSColor.white
sceneView.allowsCameraControl = true

		//Add the selection torus
		//scene.rootNode.addChildNode(selector)
		let material = SCNMaterial()
		material.diffuse.contents = NSColor.orange
		selector.geometry?.materials = [material]
		//Start the processing of the .SVG file (default one)
		let url = assets.retrieveSVG(name: "mpc.svg")
		assets.parser.parse(fromFileURL: url)
		assets.renderer.calibrateScene()
		scene.rootNode.addChildNode(assets.renderer.sceneNode)
		print("camera has position \(assets.renderer.cameraNode.worldTransform.description)")
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

		NotificationCenter.default.addObserver(forName: newSVGNotification, object: nil, queue: nil, using: changeSVG)
		for node in assets.renderer.sceneNode.childNodes{

			print(node.worldTransform)
			print("st")
			print(node.boundingBox)
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

	var currentNode = ""
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
				DispatchQueue.global(qos: .userInteractive).async{
if assets.appType == "map"{
	self.soundNode.position.x = self.point.x
	self.soundNode.position.y = self.point.y
					}
	var startPoint = self.point
		var endPoint = startPoint
		startPoint.z = 100
		endPoint.z = -100.0
		let contact = self.scene.physicsWorld.rayTestWithSegment(from: startPoint,	to: endPoint, options: nil)
		if contact.count > 0{
			let contacted = contact[0].node
				if self.currentNode != contacted.name!{
				self.currentNode = contacted.name!
self.highlightNode(node: contacted)
					if assets.appType == "map"{
			assets.speech.startSpeaking("BLock \(self.currentNode)")
					}else{
						assets.speech.startSpeaking(self.currentNode)
					}
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
		if assets.appType == "map"{
			for child in scene.rootNode.childNode(withName: "scene", recursively: true)!.childNodes{
				print(child.name)
child.addAudioPlayer(SCNAudioPlayer(source: assets.sounds[assets.soundIndices.index(of: "\(child.name!).mp3")!]))
				print(child.audioPlayers.count)
			}
			}
	}

}

