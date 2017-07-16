//
//  ModifyViewController.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//
import AppKit
import Foundation
import Cocoa
import SceneKit


class ModifyViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate{
	@IBOutlet weak var modifyTable: NSTableView!
	@IBOutlet var addNode: NSButton!

	//Modal view for the edit box
	var editWindow:MainNodeModificationViewController?

var previouslySelected = false

	override func viewDidLoad() {
		super.viewDidLoad()
					editWindow = storyboard?.instantiateController(withIdentifier: "NodeModification") as? MainNodeModificationViewController
		view.addSubview(addNode)
//		view.addSubview(removeNode)
	}

	override var representedObject: Any? {
		didSet {
			modifyTable.reloadData()
		}
	}

	//Mark: tableView protocol methods

	func numberOfRows(in tableView: NSTableView) -> Int {
		return assets.nodes.count
	}

	func tableView(_: NSTableView, viewFor: NSTableColumn?, row: Int)->NSView?{
		var text = ""
		var cellIdentifier = ""
		// 1
  let item = assets.nodes[row]
		// 2
		if viewFor == modifyTable.tableColumns[0]{
			text = item.name
			cellIdentifier = "NodeNameID"
		}else if viewFor == modifyTable.tableColumns[1]{
			text = item.position.description
			cellIdentifier = "NodePositionID"
		}
		// 3
		let cell = modifyTable.make(withIdentifier: cellIdentifier, owner:nil) as! NSTableCellView
		cell.imageView?.image = assets.image
		cell.textField!.stringValue = text
		return cell
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		if modifyTable.selectedRow == -1{
			if previouslySelected{
				for node in assets.sceneNodes{
					node.geometry?.materials = assets.nodeMaterials[assets.sceneNodes.index(of: node)!]
					node.opacity = 1.0
				}
				previouslySelected = false
			}else{
				return
			}
		}
let node = assets.sceneNodes[modifyTable.selectedRow]
		for nodeB in assets.sceneNodes{
			if node.isEqual(nodeB){
				node.geometry?.materials = [assets.selectedMaterial]
			}else{
				nodeB.geometry?.materials = [assets.unselectedMaterial]
				nodeB.opacity = 0.6
			}
		}
previouslySelected = true
	}

	//Mark: Key and mouse events

	override func keyDown(with event: NSEvent) {
		interpretKeyEvents([event])
	}

	override func insertNewline(_ sender: Any?) {
		openEditBox(new: false)
	}

	@IBAction func doubleClickAction(_ sender: AnyObject) {
		openEditBox(new: false)
	}

	@IBAction func newNode(_ sender: NSButton) {
		openEditBox(new: true)
	}

	//Mark: helper method for opening the edit box

	func openEditBox(new: Bool){
			let node = assets.sceneNodes[modifyTable.selectedRow]
presentViewControllerAsModalWindow(editWindow!)
			NotificationCenter.default.post(name: nodeModificationNotification, object: nil, userInfo:["node" : node, "new": new])
		}

}
