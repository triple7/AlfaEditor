//
//  AssetManager.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import SceneKit
import Cocoa
import AppKit

enum AppType:String{
	case Sampler = "sampler"
	case Map = "map"
	var code:Int{
		switch self{
		case .Sampler: return 0
		case .Map: return 1
		}
	}
}

class Assetmanager:NSObject, NSSpeechSynthesizerDelegate{
	let renderer:SceneKitRenderer
	let parser:SVGParser
	let  speech  = NSSpeechSynthesizer(voice: "com.acapelagroup.AGix.voice.Lisa22k_HQ")!

	//Speech synthesis voice list
	var speechVoices = [String: String]()
	//File system variables
	let dataPath = "\(NSHomeDirectory())/Dropbox/regulus/"
	var categories = [Category]()
	var currentFile = ""
var currentCategory = 0
	var nodes = [(name: String, position: SCNVector3)]()
var sceneNodes = [SCNNode]()
var nodeMaterials = [[SCNMaterial]]()
	var nodesFeatures = [NodeFeatures]()
	//Design assets
let image:NSImage!
	let art = "art.scnassets/"

	//Application type
var appType = 0

	//Audio Assets
	var samples = [SCNAudioSource]()
var sampleNames = [String]()

	//Date formatter
	let dateFormatter = DateFormatter()
	var isSpeaking = false

	//Sounds associated to a given file
	var sounds = [SCNAudioSource]()
var soundIndices = [String]()

	//Materials for selected and unselected objects
	let selectedMaterial = SCNMaterial()
	let unselectedMaterial = SCNMaterial()

	override init(){
		renderer = SceneKitRenderer()
		parser = SVGParser(delegate: renderer)
		speech.usesFeedbackWindow = false
		speech.rate = 280
		speech.volume = 0.8
let speeches = NSSpeechSynthesizer.availableVoices()
		for voice in speeches{
let name = voice.components(separatedBy:".").last!
speechVoices[name] = voice
		}

		//Start the art asset loading
		let path = Bundle.main.path(forResource: "briefcase_work", ofType: "png", inDirectory: art)!
		image = NSImage(contentsOfFile: path)!

		let date = Date()
		dateFormatter.dateStyle = DateFormatter.Style.short
		dateFormatter.timeStyle = DateFormatter.Style.none
		let convertedDate = dateFormatter.string(from: date)

		//Start by extracting all directories which will be the categories
		var directories = [String]()
		var allFiles = [(String, [(name: String, date: String)])]()
		do{
			let dirs = try FileManager.default.contentsOfDirectory(atPath: "\(dataPath)SVG/")
			for dir in dirs{
				if !dir.contains("."){
					directories.append(dir)
				}
			}
		}catch{
			print("error loading directories")
		}
		for directory in directories{
			var SVGs = [(String, String)]()

		do{
			let files = try FileManager.default.contentsOfDirectory(atPath: "\(dataPath)SVG/\(directory)")
			for file in files{
					SVGs.append((file, convertedDate))
			}
		}catch{
			print("wrong directory ")
		}
			allFiles.append((directory, SVGs))
		}
categories = Category.filesList(list: allFiles)

//Load default sounds
		let appDirectory = "art.scnassets/sounds/interface/overlays"
			let files = Bundle.main.paths(forResourcesOfType: ".aiff", inDirectory: appDirectory)
			for file in files{
				let url = URL(fileURLWithPath: file)
				let source = SCNAudioSource(url: url)!
				source.loops = false
				samples.append(source)
				sampleNames.append(file.components(separatedBy: "/").last!)
			}

		selectedMaterial.diffuse.contents = NSColor.orange
		unselectedMaterial.diffuse.contents = NSColor.red

		super.init()

	}

	func retrieveSVG(name: String)->URL{
		currentFile = name
		let path = "\(dataPath)\(name)"
		let url = URL(fileURLWithPath: path)
		return url
	}

	func loadSounds(name: String, type: String = "sampler"){
		do{
			let soundDirectory = try FileManager.default.contentsOfDirectory(atPath: "\(dataPath)sounds/\(name.components(separatedBy: ".").first!)")
			for clipName in soundDirectory{
				let path = "\(dataPath)sounds/\(name.components(separatedBy: ".").first!)/\(clipName)"
				let url = URL(fileURLWithPath: path)
				let source = SCNAudioSource(url: url)!
				if type == "sampler"{
				source.loops = false
				}else{
					source.loops = true
				}
				source.volume = 5.0
				source.isPositional = true
				source.load()
sounds.append(source)
				soundIndices.append(clipName)
			}
		}catch{
			print("error loading sound directory")
		}
appType = AppType(rawValue: type)!.code
	}

	//Mark: System tab asset management functions

	func addCategory(category: String){
		let newCategory = Category(name: category)
categories.append(newCategory)
		NotificationCenter.default.post(newCategoryNotification)
	}

	func addCategoryFromFile(url: URL){
		let date = Date()
		let convertedDate = dateFormatter.string(from: date)
let category = url.absoluteString.components(separatedBy: "/").last!
		let newCategory = Category(name: category)
		do{
			let files = try FileManager.default.contentsOfDirectory(atPath: url.absoluteString)
			for file in files{
				let newSVG = SVGFile(name: file, date: convertedDate, url: nil)
				newCategory.addFile(file: newSVG)
			}
			categories.append(newCategory)
			NotificationCenter.default.post(newCategoryNotification)
		}catch{
			print("wrong directory ")
		}
	}

	func createNewDirectory(name: String){
		do{
try FileManager.default.createDirectory(atPath: "\(dataPath)SVG/\(name)", withIntermediateDirectories: false, attributes: nil)
		addCategory(category: name)
		}catch{
			print("Couldn't create directory")
		}
	}

	func createNewFile(name: String){
FileManager.default.createFile(atPath: "\(dataPath)SVG/\(categories[currentCategory].name)", contents: nil, attributes: nil)
	}

	func addFileToCategory(file: URL){
		let date = Date()
		let convertedDate = dateFormatter.string(from: date)
		let fileName = file.absoluteString.components(separatedBy: "/").last!
		let newSVG = SVGFile(name: fileName, date: convertedDate, url: file)
categories[currentCategory].addFile(file: newSVG)
		NotificationCenter.default.post(newCategoryNotification)
	}

	func resetScenes(){
		renderer.resetScene()
 currentFile = ""
nodes.removeAll()
		sceneNodes.removeAll()
		nodeMaterials.removeAll()
		nodesFeatures.removeAll()
		sounds.removeAll()
		soundIndices.removeAll()
	}

	func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
		isSpeaking = false
	}

}

let assets = Assetmanager()
