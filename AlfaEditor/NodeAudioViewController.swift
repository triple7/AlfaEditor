//
//  NodeAudioViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import SceneKit

class NodeAudioViewController: NSViewController {
	var audioSourceLabel:NSTextField!
	var audioSourceChoose:NSPopUpButton!
	var triggerType:NSTextField!
	var triggerChoose:NSPopUpButton!
	var audioSources = ["none", "choose file...", "choose folder..."]
	var triggerTypes = ["loop", "on hover", "on tap"]

	override func viewDidLoad() {
		super.viewDidLoad()
		audioSources = audioSources + assets.sampleNames
audioSourceLabel = NSTextField(labelWithString: "Audio source: ")
		audioSourceLabel.frame.origin.x = view.frame.origin.x+5.0
		audioSourceLabel.frame.origin.y = view.frame.origin.y+5.0

		audioSourceChoose = NSPopUpButton()
audioSourceChoose.pullsDown = true
		audioSourceChoose.action = #selector(chooseSource(sender:))
		audioSourceChoose.frame.origin.x = audioSourceLabel.frame.origin.x+5.0+audioSourceLabel.frame.width
		audioSourceChoose.addItems(withTitles: audioSources)
		triggerType = NSTextField(labelWithString: "Trigger type: ")
		triggerType.frame.origin.x = audioSourceLabel.frame.origin.x
		triggerType.frame.origin.y = audioSourceLabel.frame.origin.y + audioSourceLabel.frame.height + 5.0
		triggerChoose = NSPopUpButton()
		triggerChoose.frame.size = triggerType.frame.size
		triggerChoose.pullsDown = true
		triggerChoose.autoenablesItems = true
		triggerChoose.action = #selector(chooseTrigger(sender:))
		triggerChoose.addItems(withTitles: triggerTypes)
		triggerChoose.frame.origin.x = audioSourceChoose.frame.origin.x
		triggerChoose.frame.origin.y = audioSourceChoose.frame.origin.y + audioSourceChoose.frame.height + 5.0
		view.addSubview(audioSourceLabel)
		view.addSubview(audioSourceChoose)
		view.addSubview(triggerType)
		view.addSubview(triggerChoose)
				NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: updateParameters)
	}

	override var representedObject: Any? {
		didSet {
			NotificationCenter.default.addObserver(forName: nodeModificationNotification, object: nil, queue: nil, using: updateParameters)		}
	}

	func updateParameters(notification: Notification){

	}

	func chooseSource(sender: NSPopUpButton){
		switch sender.titleOfSelectedItem!{
		case "choose file...":
openBrowser(type: "file")
			case "choose folder...":
			openBrowser(type: "folder")
		default:
			if sender.indexOfSelectedItem == 0{
				return
			}else{

			}
			}
		}

	func chooseTrigger(sender: NSPopUpButton){
	}

func openBrowser(type: String){
	let dialog = NSOpenPanel()
	dialog.allowsMultipleSelection = false
	dialog.allowedFileTypes = ["aiff"]
	switch type{
	case "folder":
		dialog.title = "choose sound folder"
		dialog.canChooseFiles = false
		dialog.canChooseDirectories = true
		dialog.canCreateDirectories = false
		if (dialog.runModal() == NSModalResponseOK){
			let result = dialog.url!
			assets.addCategoryFromFile(url: result)
		}
	case "file":
		dialog.title = "Choose audio source"
		dialog.canChooseFiles = true
		dialog.canChooseDirectories = false
		if (dialog.runModal() == NSModalResponseOK){
			let result = dialog.url!
			assets.addFileToCategory(file: result)
		}
	default: break
	}
}

	override func viewDidDisappear() {
		NotificationCenter.default.removeObserver(self)
	}

}

