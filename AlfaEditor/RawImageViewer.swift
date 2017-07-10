//
//  RawImageViewer.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 5/11/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import Cocoa



class RawImageViewer:NSImageView{
let leap = LeapMotionManager.sharedInstance
	//RawData and conversion
	var imageRepresentative:NSImageRep?
	var lastWidth:Int?
	var lastheight:Int?
	var ID:Int?

override init(frame frameRect: NSRect) {
super.init(frame: frameRect)
leap.controller?.addListener(self)
	}

	func onFrame(_ notification: Notification){
self.setNeedsDisplay()
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
let frame = leap.controller?.frame(0)
		if frame!.images.count > 0{
let leapImage = frame?.images
		}
	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
