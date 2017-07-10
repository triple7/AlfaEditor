//
//  NodeFeatures.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 2/11/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation

class NodeFeatures:NSObject{
	var audioSources:[URL]?
	var triggers:[Int]?
	var nodeDescription:String?
	var HTMLPage:URL?

	init(audioSources: [URL]?, triggers: [Int]?, nodeDescription: String?, HTMLPage: URL?){
self.audioSources = audioSources
self.triggers = triggers
		self.nodeDescription = nodeDescription
		self.HTMLPage = HTMLPage
	}

}
