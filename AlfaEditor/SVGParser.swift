//
//  SVGParser.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import QuartzCore
import SceneKit

extension SCNVector3 : CustomStringConvertible {
	public var description: String { return "\(Int(self.x)), \(Int(self.y))" }
}

/*
func +<T: ForwardIndex>(var index: T, var count: Int) -> T {
for (; count > 0; --count) {
index = index.successor()
}
return index
}
*/

struct transformMatrix {
	var first:CFloat = 0.0
	var second:CFloat = 0.0
	var third:CFloat = 0.0
	var fourth:CFloat = 0.0
	var x:CFloat = 0.0
	var y:CFloat = 0.0
}

extension NSDictionary {

	func stringValue(_ name: String, notFoundValue:String = "") -> String {
		let valueString = (self[name] as? String)
		if (valueString != nil) {
			return valueString!
		}
		else {
			return notFoundValue
		}
	}

	func floatValue(_ name: String) -> CFloat {
		var value: CFloat = 0
		let valueString = (self[name] as? String)
		if (valueString != nil) {
			value = valueString!.floatValue()
		}
		return value
	}

	func colorValue(_ name: String) -> NSColor? {
		var value: NSColor?
		let valueString = (self[name] as? String)
		if (valueString != nil) {
			value = valueString!.colorValue()
		}
		return value
	}

	func pointsValue(_ name: String, factor: CFloat) -> [CGPoint] {
		var value: [CGPoint] = []
		let valueString = (self[name] as? String)
		if (valueString != nil) {
			let points = valueString!.components(separatedBy: " ")
			for twoPoint in points {
				let cleanedTwoPoint = twoPoint.replacingOccurrences(of: " ", with: "")
				if cleanedTwoPoint.isEmpty == false {
					let xy = cleanedTwoPoint.components(separatedBy: ",")
					if xy.count == 2 {
						let x = xy[0].floatValue() * factor
						let y = xy[1].floatValue() * factor * -1
						let point = CGPoint(x: CGFloat(x),y: CGFloat(y))
						value.append(point)
					}
				}
			}
		}
		return value
	}

	func bezierPathValue(_ name: String, factor: CFloat) -> NSBezierPath {
		let points = self.pointsValue(name, factor:factor)

		let path = NSBezierPath()
		var firstItem = true
		for point in points {
			if firstItem == true {
				path.move(to: point)
				firstItem = false
			}
			else {
				path.line(to: point)
			}
		}
		path.close()

		return path
	}

	// http://tutorials.jenkov.com/svg/path-element.html
	// M2679.5,816.2v-17.5l32.5-32.5h113.5l32.5,32.5v17.5l-32.5,32.5   H2712L2679.5,816.2z
	func pathValue(_ name: String, factor: CFloat) -> NSBezierPath {
		let path = NSBezierPath()
		//        let valueString = (self[name] as? String)
		//        if let pathString = valueString {
		//            let characterSet = NSCharacterSet(charactersInString: "mlhvcsqtaz")
		//            let aScanner = NSScanner(string: pathString.lowercaseString)
		//            var testString:NSString?
		//            aScanner.scanUpToCharactersFromSet(characterSet, intoString: &testString)
		//            if let direction = testString {
		//                let firstCharacter = direction.characterAtIndex(0)
		//                switch firstCharacter {
		//                case "m":
		//                    // Move
		//                    let numbers = testString.componentsSeparatedByString(",")
		////                case "l":
		//                    // Move
		//                }
		//            }
		//        }
		//        path.closePath()

		return path
	}

	func matrixValue(_ name: String, factor:CFloat) -> transformMatrix {
		let valueString = (self[name] as? String)
		if let valueUnwrapped: String = valueString {
			let start:String.Index = valueUnwrapped.index(valueUnwrapped.startIndex, offsetBy: 6) // matrix(
			let end:String.Index = valueUnwrapped.endIndex
			let numberString = valueUnwrapped.substring(with: (start ..< end))
			let numbers = numberString.components(separatedBy: " ")

			let matrix:transformMatrix = transformMatrix(
				first: numbers[0].cfloatValue(),
				second: numbers[1].cfloatValue(),
				third: numbers[2].cfloatValue(),
				fourth: numbers[3].cfloatValue(),
				x: numbers[4].cfloatValue() * factor,
				y: numbers[5].cfloatValue() * factor * -1)

			return matrix
		}

		return transformMatrix(first: 0, second: 0, third: 0, fourth: 0, x: 0, y: 0)
	}
}

extension String {
	func floatValue() -> Float32 {
		return Float32(self.cfloatValue())
	}

	func cfloatValue() -> CFloat {
		let numberFormatter = NumberFormatter()
		numberFormatter.numberStyle = NumberFormatter.Style.decimal
		numberFormatter.numberStyle = NumberFormatter.Style.decimal
		let characterSet = CharacterSet.decimalDigits.inverted
		let number = numberFormatter.number(from: self.trimmingCharacters(in: characterSet))
		if (number != nil) {
			return number!.floatValue
		}
		return 0
	}

	func colorValue () -> NSColor {
		var cString:String = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
		if (cString.hasPrefix("#")) {
			cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
		}
		if (cString.characters.count != 6) {
			return NSColor.gray
		}
		let indexAt2 = cString.index(cString.startIndex, offsetBy: 2)
		let indexAt4 = cString.index(indexAt2, offsetBy: 2)
		let indexAt6 = cString.index(indexAt4, offsetBy: 2)

		let rString = cString.substring(to: indexAt2)
		let gString = cString.substring(with: indexAt2..<indexAt4)
		let bString = cString.substring(with: indexAt4..<indexAt6)

		var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
		(        Scanner.localizedScanner(with: rString) as! Scanner).scanHexInt32(&r)
		(Scanner.localizedScanner(with: gString) as! Scanner).scanHexInt32(&g)
		(Scanner.localizedScanner(with: bString) as! Scanner).scanHexInt32(&b)

		return NSColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
	}
}

protocol MapParserDelegate {
	func svg(_ width: CFloat, height: CFloat)
	func square(_ x: CFloat, y: CFloat, width: CGFloat, height: CGFloat, length: CGFloat, fill: NSColor?, stroke: NSColor?, ID: String)
	func polygon(_ path: NSBezierPath, extrusionDepth: CGFloat, fill: NSColor?, stroke: NSColor?, ID: String)
	func circle(_ x: Float32, y: Float32, radius: Float32, fill: NSColor, ID: String)
	func text(_ matrix: transformMatrix, text: String, fontFamily: String, fontSize: CGFloat, fill: NSColor, ID: String)
}

class SVGParser : NSObject, XMLParserDelegate {

	let factor:CFloat = 1.0
	var divDict: NSDictionary?
	var divCharacters: NSMutableString?

	var groupIdentifier: String?

	var delegate: MapParserDelegate

	init(delegate:SceneKitRenderer) {
		self.delegate = delegate
		super.init()
	}

	// Public method to load a zone
	func parse(fromFileURL fileURL:URL) {
		let parser = XMLParser(contentsOf: fileURL)
		parser!.delegate = self
		parser!.parse()
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
		//		print("\(elementName) started")

		if elementName == "svg" {
			let width: CFloat = (attributeDict as NSDictionary).floatValue("width") * factor
			let height: CFloat = (attributeDict as NSDictionary).floatValue("height") * factor
			self.delegate.svg(width, height: height)
		}
		else if elementName == "g" {
			self.groupIdentifier = attributeDict["id"] as String?
		}
		else if elementName == "rect" {
			let length: CGFloat = 0.1
			let x: CFloat = (attributeDict as NSDictionary).floatValue("x") * factor
			let y: CFloat = (attributeDict as NSDictionary).floatValue("y") * factor * -1
			let fill: NSColor! = (attributeDict as NSDictionary).colorValue("fill")
			let stroke: NSColor? = (attributeDict as NSDictionary).colorValue("stroke")
			let width = CGFloat((attributeDict as NSDictionary).floatValue("width") * factor)
			let height = CGFloat((attributeDict as NSDictionary).floatValue("height") * factor)
			let objectID = (attributeDict as NSDictionary).stringValue("id")
			self.delegate.square(x, y: y, width: width, height: height, length: length, fill: fill, stroke: stroke, ID: objectID)
		}
		else if elementName == "polygon" {
			let fill: NSColor? = (attributeDict as NSDictionary).colorValue("fill")
			let stroke: NSColor? = (attributeDict as NSDictionary).colorValue("stroke")
			let path = (attributeDict as NSDictionary).bezierPathValue("points", factor:factor)
			let objectID = (attributeDict as NSDictionary).stringValue("id")
			self.delegate.polygon(path, extrusionDepth: 0.0, fill: fill, stroke: stroke, ID: objectID)
		}
		else if elementName == "path" {
			let fill:NSColor? = (attributeDict as NSDictionary).colorValue("fill")
			let d = (attributeDict as NSDictionary).pathValue("d", factor: factor)
		}
		else if elementName == "line" {
			let stroke: NSColor? = (attributeDict as NSDictionary).colorValue("stroke")
			let strokeWidth: CGFloat = CGFloat((attributeDict as NSDictionary).floatValue("stroke-width") * factor)
			let x1: CGFloat = CGFloat((attributeDict as NSDictionary).floatValue("x1") * factor)
			let x2: CGFloat = CGFloat((attributeDict as NSDictionary).floatValue("x2") * factor)
			let y1: CGFloat = CGFloat((attributeDict as NSDictionary).floatValue("y1") * factor)
			let y2: CGFloat = CGFloat((attributeDict as NSDictionary).floatValue("y2") * factor)

			let path = NSBezierPath()
			path.lineWidth = strokeWidth
			path.move(to: CGPoint(x: x1, y: y1))
			path.line(to: CGPoint(x: x2, y: y2))
			path.close()
			let objectID = (attributeDict as NSDictionary).stringValue("id")
			self.delegate.polygon(path, extrusionDepth: 0.0, fill: nil, stroke:stroke, ID: objectID)
		}
		else if elementName == "polyline" {
			let stroke: NSColor? = (attributeDict as NSDictionary).colorValue("stroke")
			let strokeWidth: CGFloat = CGFloat((attributeDict as NSDictionary).floatValue("stroke-width") * factor)
			let path = (attributeDict as NSDictionary).bezierPathValue("points", factor:factor)
			path.lineWidth = strokeWidth
			let objectID = (attributeDict as NSDictionary).stringValue("id")
			self.delegate.polygon(path, extrusionDepth: 0.0, fill: nil, stroke:stroke, ID: objectID)
		}
		else if elementName == "circle" {
			let x: Float32 = (attributeDict as NSDictionary).floatValue("cx") * factor
			let y: Float32 = (attributeDict as NSDictionary).floatValue("cy") * factor * -1
			let fill: NSColor? = (attributeDict as NSDictionary).colorValue("fill")
			let r: Float32 = (attributeDict as NSDictionary).floatValue("r") * factor
			let objectID = (attributeDict as NSDictionary).stringValue("id")

			if let fillColor = fill {
				self.delegate.circle(x, y: y, radius: r, fill: fillColor, ID: objectID)
			}
		}
		else if elementName == "text" {
			self.divCharacters = NSMutableString()
			self.divDict = (attributeDict as NSDictionary)
		}
		else if elementName == "tspan" {
		}
		else {
//			print("elementName \(elementName) attributes \(attributeDict)")
		}
	}

	func parser(_ parser: XMLParser, foundCharacters string: String)
	{
		if let divCharacters = self.divCharacters {
			divCharacters.append(string)
		}
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "g" {
			self.groupIdentifier = nil
		}
		else if elementName == "text" {
			if let attributeDict = self.divDict {

				let fontFamily = attributeDict.stringValue("font-family")
				let fontSize:CGFloat = CGFloat(attributeDict.floatValue("font-size")) * CGFloat(factor)
				let matrixValue:transformMatrix = attributeDict.matrixValue("transform", factor: factor)
				let fill: NSColor? = attributeDict.colorValue("fill")

				if let fillColor = fill {
					self.delegate.text(matrixValue, text:self.divCharacters! as String, fontFamily: fontFamily, fontSize: fontSize, fill: fillColor, ID: String(describing: divCharacters))
				}

				self.divCharacters = nil;
				self.divDict = nil;
			}
		}
	}
}
