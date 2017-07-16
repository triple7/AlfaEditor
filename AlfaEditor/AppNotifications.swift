//
//  AppNotifications.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 30/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation

//Mark: notification publishers

//Asset manager new category
let newCategoryNotification = Notification(name: Notification.Name(rawValue: "newCategoryNotification"))

//ModifyViewController node select notification
//Used for propagating the selected node to the edit window tabs and preview scene
let nodeChangeNotification = Notification.Name(rawValue: "nodeChangeNotification")
//Edit window de-allocation
let editWindowDeAllocationNotification = Notification.Name(rawValue: "EditWindowDeAllocationNotification")

//SceneViewController node modification notification
let nodeModificationNotification = Notification.Name(rawValue: "nodeModificationNotification")
let didEditNodeNotification = Notification.Name(rawValue: "didEditNodeNotification")

//New file change notification

let newSVGNotification = Notification.Name(rawValue: "newSVG")


