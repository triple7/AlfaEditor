//
//  Utilities.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 5/11/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation


func delay(_ delay: Double, closure: @escaping ()->()) {
	DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

