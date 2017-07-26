//
//  RawImageViewer.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 5/11/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//
import Foundation
import Cocoa
import SceneKit

class RawImageViewer:NSImageView{
	var controller:LeapController?
	//RawData and conversion
	var imageRepresentative:NSImageRep?
	var lastWidth:Int?
	var lastheight:Int?
	var ID:Int?

override init(frame frameRect: NSRect) {
super.init(frame: frameRect)
	}

	func setup(controller: LeapController, imageID: Int){
		self.ID = imageID
		controller.addDelegate(self)
	}

	func onFrame(_ notification: Notification){
self.setNeedsDisplay()
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
let frame = controller!.frame(0)
		if frame!.images.count > 0{
let leapImage = frame?.images[ID!] as! LeapImage
			if imageRepresentative == nil || lastWidth != Int(leapImage.width) || lastheight != Int(leapImage.height){
imageRepresentative = NSImageRep()
				imageRepresentative?.pixelsHigh = Int(leapImage.height)
				imageRepresentative?.pixelsWide = Int(leapImage.width)
				imageRepresentative?.bitsPerSample = 8
				imageRepresentative?.hasAlpha = false
				imageRepresentative?.colorSpaceName = NSCalibratedWhiteColorSpace
				lastWidth = Int(leapImage.width)
lastheight = Int(leapImage.height)
				let data = leapImage.data
					self.image?.addRepresentation(self.imageRepresentative!)

			}
		}
	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
