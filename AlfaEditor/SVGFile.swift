//
//  SVGFile.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 8/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class SVGFile:NSObject{
	let name:String!
	let date:String
	var url:URL?

	init(name: String, date: String, url: URL?){
		self.name = name
		self.date = date
		if url != nil{
			self.url = url!
		}
	}

}
