//
//  SystemViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import AppKit
import Foundation
import Cocoa

class SystemViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate{

	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var remove: NSButton!
	@IBOutlet weak var add: NSPopUpButton!
	@IBOutlet weak var currentFile: NSTextField!

	var currentFileText:String!{
		didSet{
currentFile.stringValue = "current file: \(currentFileText!)"
		}
		}

	override func viewDidLoad() {
		super.viewDidLoad()
NotificationCenter.default.addObserver(forName: newCategoryNotification.name, object: nil, queue: nil, using: updateTables)
		currentFileText = assets.currentFile
	}

	override var representedObject: Any? {
		didSet {
NotificationCenter.default.addObserver(forName: newCategoryNotification.name, object: nil, queue: nil, using: updateTables)
		}
	}

	override func viewDidDisappear() {
		NotificationCenter.default.removeObserver(self)
	}

	//Mark: outline table notification routine

	func updateTables(notification: Notification){
		outlineView.reloadData()
	}

	//Mark: outline table protocol functions

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let category = item as? Category{
			return category.files.count
		}
return assets.categories.count
	}

func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
if let category = item as? Category{
	return category.files[index]
	}
	return assets.categories[index]
}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let category = item as? Category {
return (category.files.count > 0)
}
	return false
}

	//Mark: Outline view delegate

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view:NSTableCellView?
if let category = item as? Category{
	if tableColumn?.identifier == "NameColumn" {
view = outlineView.make(withIdentifier: "CategoryCell", owner: self) as? NSTableCellView
	if let textField = view?.textField{
textField.stringValue = category.name
textField.sizeToFit()
	}
}else{
		view = outlineView.make(withIdentifier: "DateCell", owner: self) as? NSTableCellView
		if let textField = view?.textField {
			textField.stringValue = ""
			textField.sizeToFit()
		}
	}
		}else if let file = item as? SVGFile{
if tableColumn?.identifier == "DateColumn"{
	view = outlineView.make(withIdentifier: "DateCell", owner: self) as? NSTableCellView
			if let textField = view?.textField{
		textField.stringValue = file.date
		textField.sizeToFit()
	}
}else{
	view = outlineView.make(withIdentifier: "FileCell", owner: self) as? NSTableCellView
	if let textField = view?.textField{
		textField.stringValue = file.name
		textField.sizeToFit()
	}
	}
	}
		return view
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		if let category = outlineView.item(atRow: outlineView.selectedRow) as? Category{
			assets.currentCategory = assets.categories.index(of: category)!
		}else{
currentFile.stringValue = (outlineView.item(atRow: outlineView.selectedRow) as? SVGFile)!.name
		}
	}

	//Mark: Outline view double click action

	@IBAction func expandCategory(_ sender: NSOutlineView) {
		let item = sender.item(atRow: sender.clickedRow)
		if item is Category{
			if sender.isItemExpanded(item){
				sender.collapseItem(item)
			}else{
				sender.expandItem(item)
			}
		}
	}

	//Mark: add action functions

	@IBAction func addItem(_ sender: NSPopUpButton) {
		switch sender.indexOfSelectedItem{
		case 1:
			let newItem = storyboard?.instantiateController(withIdentifier: "NewItemView") as! NewItemViewController
			newItem.title = "New category"
			newItem.itemLabel.stringValue = "category name: "
			presentViewControllerAsSheet(newItem)
		case 2:
			let newItem = storyboard?.instantiateController(withIdentifier: "NewItemView") as! NewItemViewController
			newItem.title = "New file"
			newItem.itemLabel.stringValue = "file name: "
			presentViewControllerAsSheet(newItem)
		case 3:
			openBrowser(type: "folder")
		case 4:
			openBrowser(type: "file")
		default: break
		}
	}

	@IBAction func removeItem(_ sender: NSButton) {
		let selectedRow = outlineView.selectedRow
		if selectedRow == -1{
			return
		}
		outlineView.beginUpdates()
		if let item = outlineView.item(atRow: selectedRow){
			if let item = item as? Category{
				if let index = assets.categories.index(where: { $0.name == item.name}){
					if confirm(question: item.name){
						assets.categories.remove(at: index)
						outlineView.removeItems(at: IndexSet(integer: selectedRow), inParent: nil, withAnimation: .slideLeft)
					}
				}
			}else if let item = item as? SVGFile{
				for category in assets.categories{
					if let index = category.files.index(where: { $0.name == item.name}){
						if confirm(question: item.name){
							category.files.remove(at: index)
							outlineView.removeItems(at: IndexSet(integer: index), inParent: category, withAnimation: .slideLeft)
						}
					}
				}
			}
		}
		outlineView.endUpdates()
	}

	//Mark: helper functions for popup

	func confirm(question: String)->Bool{
		let alertPopup = NSAlert()
		alertPopup.messageText = "Are you sure you want to remove \(question)?"
		alertPopup.alertStyle = NSAlertStyle.warning
		alertPopup.addButton(withTitle: "OK")
		alertPopup.addButton(withTitle: "cancel")
return alertPopup.runModal() == NSAlertFirstButtonReturn
	}

	func openBrowser(type: String){
		let dialog = NSOpenPanel()
		dialog.allowsMultipleSelection = false
		dialog.allowedFileTypes = ["svg"]
		switch type{
			case "folder":
dialog.title = "Choose folder as category"
dialog.canChooseFiles = false
			dialog.canChooseDirectories = true
			dialog.canCreateDirectories = false
if (dialog.runModal() == NSModalResponseOK){
	let result = dialog.url!
	assets.addCategoryFromFile(url: result)
			}
			case "file":
				dialog.title = "Choose file"
				dialog.canChooseFiles = true
				dialog.canChooseDirectories = false
				if (dialog.runModal() == NSModalResponseOK){
					let result = dialog.url!
					assets.addFileToCategory(file: result)
			}
		default: break
		}
	}

	//Mark: Key events

	override func keyDown(with event: NSEvent) {
		interpretKeyEvents([event])
	}

	override func deleteBackward(_ sender: Any?) {
		let selectedRow = outlineView.selectedRow
		if selectedRow == -1{
			return
		}
		outlineView.beginUpdates()
		if let item = outlineView.item(atRow: selectedRow){
			if let item = item as? Category{
				if let index = assets.categories.index(where: { $0.name == item.name}){
					if confirm(question: item.name){
					assets.categories.remove(at: index)
					outlineView.removeItems(at: IndexSet(integer: selectedRow), inParent: nil, withAnimation: .slideLeft)
					}
				}
			}else if let item = item as? SVGFile{
				for category in assets.categories{
					if let index = category.files.index(where: { $0.name == item.name}){
						if confirm(question: item.name){
						category.files.remove(at: index)
						outlineView.removeItems(at: IndexSet(integer: index), inParent: category, withAnimation: .slideLeft)
						}
					}
				}
			}
		}
		outlineView.endUpdates()
	}

	override func insertNewline(_ sender: Any?) {
		print(currentFile)
NotificationCenter.default.post(name: newSVGNotification, object: currentFile.stringValue)
	}

}
