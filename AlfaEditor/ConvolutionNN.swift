//
//  ConvolutionNN.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation


/** Concepts related to Convolution Networks

0-architecture elements:
X = input volume (mxnxd) matrix where d is the dimensionality of the image such as for RGBA
kern = the convolution step which sizes down the number of nueral activation nodes, which can be sorted as a smaller width and height of the input with kxlxd values per neuron, sliding with a step size over the input.
Y = output with dimensionality 1x1xd where d becomes the classification of a given output.
1-Important functions:
computing the spatial size of the output volume as a function of the input volume
w = input volume size
f = receptive field size of the convolution neurons
s = slide value (usually max 2)
p = zero padding to allow more flexible sliding)

Proportions between each variable:
output spatial size = (W-F+2P)/S+1

Usually accepted padding values 
p = (f-1)/2
*/

//Function for outputting optimal ratios from the input volume size, the receptive layer neuron size, the slide and padding

struct synapsis{
	var input:Double
	var weight:Double
	var output:Double{
		return input*weight
	}
}

struct Neuron{
	var inputs:[Double]
	var output:Double{
		let sum = inputs.reduce(0, +)
		return activate(value: sum, functionType: ActivationFunction.Sigmoid)
	}

	func activate(value v: Double, functionType: ActivationFunction)->Double{
		switch functionType{
		case .Sigmoid: return 1.0/1.0+exp(-v)
		case .Tan: return tan(v)
		case .reLU: return max(0.0, v)
		case .leakyReLU: return max(0.01*v, v)
		case .eLU: return (v > 0) ? v : 0.01*(exp(v)-1.0)
		}
	}
}

enum ActivationFunction{
	case Sigmoid
	case Tan
	case reLU
	case leakyReLU
	case eLU
}


