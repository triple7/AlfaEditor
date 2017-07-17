//
//  SceneLeapMotion.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 16/07/17.
//  Copyright © 2017 antoxicon. All rights reserved.
//

import Foundation
import SceneKit

extension SceneViewController: LeapDelegate{

	func run() {
		controller!.addDelegate(self)
	}

	//Mark: Gestures and coordinates

	func performGesture(){
		if gestureFlag{
			delay(0.15){
				self.gestureFlag = false
			}
			//assets.speech.startSpeaking(point.description)
			//layerEngine.playInterfaceFX("selected")
			if assets.appType == "sampler"{
			if currentNode != ""{
			soundNode.addAudioPlayer(SCNAudioPlayer(source: assets.sounds[(Int(currentNode.components(separatedBy: "d").last!)!)-1]))
			}
		}else{
		}
		}
	}

	// MARK: - LeapDelegate Methods

	func onInit(_ controller: LeapController!) {
	}

	func onConnect(_ controller: LeapController!) {
		print("connected")
		//        controller.enable(LEAP_GESTURE_TYPE_CIRCLE, enable: true)
		controller.enable(LEAP_GESTURE_TYPE_KEY_TAP, enable: true)
		//        controller.enable(LEAP_GESTURE_TYPE_SCREEN_TAP, enable: true)
		//        controller.enable(LEAP_GESTURE_TYPE_SWIPE, enable: true)
		controller.config.setFloat("Gesture.KeyTap.MinDownVelocity", value: Float(2.5))
		controller.config.setFloat("Gesture.KeyTap.HistorySeconds", value: Float(7.0))
		controller.config.setFloat("Gesture.KeyTap.MinDistance", value: Float(4.5))
		controller.config.setBool("robust_mode_enabled", value: true)
		controller.config.save()
		//controller.addListener(self)
		layerEngine.playInterfaceFX("focused")
		//Allow leap to get raw data from sensors
		//controller.setPolicy(LEAP_POLICY_IMAGES)
	}

	func onDisconnect(_ controller: LeapController!) {
		layerEngine.playInterfaceFX("unselected")
	}

	func onServiceConnect(_ controller: LeapController!) {
	}

	func onDeviceChange(_ controller: LeapController!) {
	}

	func onExit(_ controller: LeapController!) {
	}

	func onFrame(_ controller: LeapController!) {
		DispatchQueue.global(qos: .userInteractive).async{
			self.frameCount += 1
			if self.frameCount <= 20{
				return
			}
			if self.frameCount > 60{
				self.frameCount = 20
			}
		}
		DispatchQueue.global(qos: .userInteractive).async{
			let currentFrame = self.controller!.frame(0)!
			if !self.gestureFlag{
				let gestures = currentFrame.gestures(self.controller!.frame(10)!) as! [LeapGesture]
				for gesture in gestures{
					if gesture.isValid {
						self.gestureFlag = true
						self.performGesture()
					}
				}
			}
			let hands = currentFrame.hands as! [LeapHand]
			if !hands.isEmpty{
				let endPoint = (hands[0].fingers as! [LeapFinger])[1].stabilizedTipPosition
				let xProjection = (endPoint!.x * Float(self.paperToLensHeight)) / endPoint!.y
				let zProjection = (endPoint!.z * Float(self.paperToLensHeight)) / endPoint!.y
				let Y = zProjection + Float(self.paperWidth)/2
				let X = -xProjection + Float(self.paperHeight)/2
				if Int(X) > 0 && Int(X) < self.paperWidth {
					if Int(Y) > 0 && Int(Y) < self.paperHeight {
						self.point.x = CGFloat( self.paperWidth - Int(X))
						self.point.y = CGFloat( self.paperHeight - Int(Y))
					}
				}
			}
		}
		/*
		for hand in hands {
		if hand.isLeft {
		leftHandPosition = hand.palmPosition
		print("left hand position: \(leftHandPosition)")
		} else if hand.isRight {
		rightHandPosition = hand.palmPosition
		print("right hand position: \(rightHandPosition)")
		}
		}
		*/
	}

	func onFocusGained(_ controller: LeapController!) {
		print("focus gained")
		layerEngine.playInterfaceFX("focused")
	}

	func onFocusLost(_ controller: LeapController!) {
		print("focus lost")
		layerEngine.playInterfaceFX("unfocused")
	}

}
