//
//  SceneKitRenderer.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import QuartzCore
import SceneKit

let colliderBitmap = 1 << 1

class SceneKitRenderer : NSObject, MapParserDelegate  {

	let factor:CFloat = 1.0
	var renderingOrder = 1

	var cameraNode = SCNNode()
	var sceneNode = SCNNode()

	var token: Int = 0

	func svg(_ width: CFloat, height: CFloat) {
		// create and add a camera to the scene
		cameraNode.camera = SCNCamera()
	}

	// create a 3d box
	func square(_ x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: NSColor?, stroke: NSColor?, ID: String) {
		var newName = ""
		let geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0.0)
		let rectNode = SCNNode(geometry: geometry)
		if ID.contains("#"){
			newName = ID.components(separatedBy: "#").first!
		}else{
			newName = ID
			let rectCollider = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
			rectNode.physicsBody = rectCollider
			rectNode.physicsBody!.categoryBitMask = colliderBitmap
			rectNode.physicsBody!.collisionBitMask = colliderBitmap
		}

		rectNode.name = newName
		let adjustedX:CGFloat = CGFloat(x) + CGFloat(width) * 0.5
		let adjustedY:CGFloat = CGFloat(y) - CGFloat(height) * 0.5
		let adjustedZ:CGFloat = CGFloat(length) * 0.5
		rectNode.position = SCNVector3Make(adjustedX, adjustedY, adjustedZ);
		geometry.firstMaterial = self.materialForColor(fill!)
		self.addNode(rectNode)
		//        if let strokeColor = stroke {
		//            let cgPoints:[CGPoint] = [
		//                CGPointMake(x - width, y - height),
		//                CGPointMake(x - width, y + height),
		//                CGPointMake(x + width, y - height),
		//                CGPointMake(x + width, y + height)
		//            ]
		//            linePolygon(cgPoints, strokeColor: strokeColor)
		//        }
	}

	// Draw a line polygon
	func linePolygon(_ cgPoints: [CGPoint], strokeColor: NSColor) {
		/*
		print("linePolygon")
		var vertices: [SCNVector3] = []
		var indicies: [UInt32] = []

		var index:UInt32 = 0
		for point:CGPoint in cgPoints {
		let ventor3 = SCNVector3Make(CGFloat(point.x), CGFloat(point.y), 0.0)
		vertices.append(ventor3)
		indicies.append(index)
		index = index + 1
		}

		let vertexSoure = SCNGeometrySource(vertices: &vertices, count: vertices.count)

		let data = Data(bytes: UnsafePointer<UInt8>(indicies), count: MemoryLayout<UInt32>.size * indicies.count)
		let element = SCNGeometryElement(data: data, primitiveType: .line, primitiveCount: cgPoints.count - 1, bytesPerIndex: MemoryLayout<UInt32>.size)
		let geometry = SCNGeometry(sources: [vertexSoure], elements: [element])
		geometry.firstMaterial = self.materialForColor(strokeColor)
		let lineNode = SCNNode(geometry: geometry)
		self.addNode(lineNode)
		*/
	}

	// Create a 3d shape
	func polygon(_ path: NSBezierPath, extrusionDepth: CGFloat, fill: NSColor?, stroke: NSColor?, ID: String) {
		print("polygon")
		if let fillColor = fill {
			let geometry = SCNShape(path: path, extrusionDepth: 0.05)
			let rectNode = SCNNode(geometry: geometry)
			let rectCollider = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(geometry: geometry, options: nil))
			rectNode.physicsBody = rectCollider
			rectNode.physicsBody?.contactTestBitMask = 0
			rectNode.name = ID
			geometry.firstMaterial = self.materialForColor(fillColor)
			self.addNode(rectNode)
		}
		if stroke != nil {
		}
	}

	// Create a Circle
	func circle(_ x: Float32, y: Float32, radius: Float32, fill: NSColor, ID: String) {

		print("circle")
		let geometry = SCNCylinder(radius: CGFloat(radius), height: 0.0)
		let circleNode = SCNNode(geometry: geometry)
		circleNode.name = ID
		let adjustedX:CGFloat = CGFloat(x) + CGFloat(radius) * 0.5
		let adjustedY:CGFloat = CGFloat(y) - CGFloat(radius) * 0.5
		circleNode.position = SCNVector3Make(adjustedX, adjustedY, CGFloat(0.0));
		geometry.firstMaterial = self.materialForColor(fill)
		circleNode.eulerAngles = SCNVector3(x: CGFloat(-M_PI/2.0), y: 0.0, z: 0.0)
		self.addNode(circleNode)
		print("Circle added")
	}

	// Draw text
	func text(_ matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: NSColor, ID: String) {

		print("text")
		let geometry = SCNText(string: text, extrusionDepth: 0.0)
		geometry.firstMaterial = self.materialForColor(fill)
		geometry.font = NSFont(name: fontFamily, size: fontSize)
		let textNode = SCNNode(geometry: geometry)
		textNode.name = ID
		textNode.position = SCNVector3Make(CGFloat(matrix.x), CGFloat(matrix.y), 0.0)
		textNode.transform = SCNMatrix4Scale(textNode.transform, 0.01, 0.01, 0.01)
		//		textNode.constraints = [SCNLookAtConstraint(target: self.cameraNode)]
		self.addNode(textNode)
	}

	// Obtain material for color - reused
	func materialForColor(_ color: NSColor) -> SCNMaterial {
		let material = SCNMaterial()
		let materialProperty = material.diffuse
		materialProperty.contents = color
		material.writesToDepthBuffer = false
		return material
	}

	func addNode(_ node: SCNNode) {
		node.castsShadow = true
		node.renderingOrder = renderingOrder
		renderingOrder = renderingOrder + 1
		if node.name != nil{
		sceneNode.addChildNode(node)
		if node.name! != "canvas_background"{
		assets.nodes.append((node.name!, node.position))
		assets.sceneNodes.append(node)
assets.nodeMaterials.append(node.geometry!.materials)
		}
		}
	}

	func calibrateScene(){
		let bound = sceneNode.boundingBox
		let xPos = bound.max.x-bound.min.x
		let yPos = bound.max.y-bound.min.y

		sceneNode.pivot.m41 = xPos/2
		sceneNode.pivot.m42 = -yPos/2
		sceneNode.position.x = xPos/2
		sceneNode.position.y = yPos/2
		let constraint = SCNLookAtConstraint(target: sceneNode)
		cameraNode.position = SCNVector3(x: xPos, y: yPos, z: 500.0)
		cameraNode.constraints = [constraint]
		cameraNode.camera?.automaticallyAdjustsZRange = true

		for n in assets.nodes{
			print("asset node is: \(n.0)")
		}

	}

	func resetScene(){
		for node in sceneNode.childNodes{
			node.removeFromParentNode()
		}
	}
	
}

extension SCNMatrix4 : CustomStringConvertible {
	public var description: String { return "x:\(Int(self.m41)) y:\(Int(self.m42))" }
}

