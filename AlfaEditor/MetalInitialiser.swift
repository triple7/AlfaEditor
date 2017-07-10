//
//  MetalInitialiser.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 31/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import Metal


class MetalInitialiser:NSObject{
	let device:MTLDevice

	let commandQueue:MTLCommandQueue
	let library:MTLLibrary

override init(){
self.device = MTLCreateSystemDefaultDevice()!
self.commandQueue = device.makeCommandQueue()
self.library = device.newDefaultLibrary()!
	}

}
