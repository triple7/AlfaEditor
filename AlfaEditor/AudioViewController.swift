//
//  AudioViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//
import AppKit
import Cocoa
import Foundation

class AudioViewController: NSViewController {
	@IBOutlet weak var voiceLabel: NSTextField!
	@IBOutlet weak var voiceChoose: NSPopUpButton!
var voices = [String]()

	override func viewDidLoad() {
		super.viewDidLoad()
		for key in assets.speechVoices.keys{
			voices.append(key)
		}
//voiceChoose.removeAllItems()
//		voiceChoose.addItems(withTitles: voices)
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

}
