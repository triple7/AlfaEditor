//
//  CNNBuild.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 31/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import Metal

class CNNBuild:NSObject{
	//Mark: Convolution Neural Network notations are used for the properties, where X is the input matrix, L hidden layers, W the kernel and Y the output.
	var X = [[Float]]()
	var L =  [[[Float]]]()
	var W = [[Float]]()
	var Y = [[Float]]()
// n and m represent the rows and columns of the matrix respectively
	var n:[Int]!
	var m:[Int]!
	var layers:Int!
//	var t:Int
//Metal context connection
	let metalContext = MetalInitialiser()
//MTLTextures for each layer
	var inTexture:MTLTexture?
	var knTexture:MTLTexture?
var outTexture:MTLTexture?

	init(inputs: [[Float]], L: [[[Float]]], layers: Int, kernel: [[Float]], Y: [[Float]]?){
		super.init()

let rows = inputs.count
		let columns = inputs.first!.count
		let kernelRows = kernel.count
		let kernelColumns = kernel.first!.count
		for row in inputs{
X.append(pad(x: row, m: columns))
		}
		for row in kernel{
			W.append(pad(x: row, m: kernelColumns))
		}

		//Create a 2d texture for the inputs X
		let inputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: columns, height: rows, mipmapped: false)
inputTextureDescriptor.usage = .shaderRead
 inTexture = metalContext.device.makeTexture(descriptor: inputTextureDescriptor)
let region = MTLRegion(origin: MTLOrigin(), size: MTLSize(width: columns, height: rows, depth: 1))
inTexture!.replace(region: region, mipmapLevel: 0, withBytes: X, bytesPerRow: X.first!.count*MemoryLayout<Float32>.size)

		let kernelTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: kernelColumns, height: kernelRows, mipmapped: false)
		kernelTextureDescriptor.usage = .shaderRead
		 knTexture = metalContext.device.makeTexture(descriptor: kernelTextureDescriptor)
		let kernelRegion = MTLRegion(origin: MTLOrigin(), size: MTLSize(width: kernelColumns, height: kernelRows, depth: 1))
		knTexture!.replace(region: kernelRegion, mipmapLevel: 0, withBytes: W, bytesPerRow: W.first!.count*MemoryLayout<Float32>.size)

		let outputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: columns, height: rows, mipmapped: false)
		outputTextureDescriptor.usage = .shaderWrite
		 outTexture = metalContext.device.makeTexture(descriptor: outputTextureDescriptor)
		let outputRegion = MTLRegion(origin: MTLOrigin(), size: MTLSize(width: columns, height: rows, depth: 1))
		outTexture!.replace(region: outputRegion, mipmapLevel: 0, withBytes: X, bytesPerRow: X.first!.count*MemoryLayout<Float32>.size)
		executeConvolution()
	}

	func pad(x: [Float], m: Int)->[Float]{
		return x + [Float](repeatElement(0, count: m-1))
	}

	//Mark: function for executing the convolution:

	func executeConvolution(){
		guard let outTexture = self.outTexture else{
			return
		}
		let commandBuffer = metalContext.commandQueue.makeCommandBuffer()
		let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder()
//computeCommandEncoder.setComputePipelineState(MTLComputePipelineState.)
	}

}
