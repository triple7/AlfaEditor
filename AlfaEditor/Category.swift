//
//  Category.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 8/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class Category:NSObject{
	let name:String!
var files = [SVGFile]()

	init(name: String){
		self.name = name
	}

class func filesList(list: [(String, [(name: String, date: String)])])->[Category]{
var categories = [Category]()
		for item in list{
let category = Category(name: item.0)
			for file in item.1{
				let SVG = SVGFile(name: file.name, date: file.date, url: nil)
				category.files.append(SVG)
			}
categories.append(category)
		}
		return categories
	}

	func addFile(file: SVGFile){
		files.append(file)
	}

}
