//
//  AudioLayerEngine.swift
//  AlfaEditor
//
//  Created by Yuma Antoine Decaux on 3/10/16.
//  Copyright © 2016 antoxicon. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class AudioLayerEngine:AVAudioEngine{
	let dataPath = "\(NSHomeDirectory())/Music/regulus/interface/"
	var engine:AVAudioEngine!
	var environment:AVAudioEnvironmentNode!
	var voicePlayer:AVAudioPlayerNode!
	var outputBuffer:AVAudioPCMBuffer!
	var interfaceFX: AVAudioPlayerNode!
	var interfaceBuffer: AVAudioPCMBuffer!
	var interfaceSpeak: AVAudioPlayerNode!
	var radioChatterBuffer: AVAudioPCMBuffer!
	var radioChatter: AVAudioPlayerNode!
	var interfaceSpeakBuffer: AVAudioPCMBuffer!
	//audio effects
	let FXdelay = AVAudioUnitDelay()
	let FXdistortion = AVAudioUnitDistortion()
	let FXreverb = AVAudioUnitReverb()
	let FXtimePitch = AVAudioUnitTimePitch()

	let speakDelay = AVAudioUnitDelay()
	let speakDistortion = AVAudioUnitDistortion()
	let speakReverb = AVAudioUnitReverb()
	let speakTimePitch = AVAudioUnitTimePitch()

	let delay = AVAudioUnitDelay()
	let distortion = AVAudioUnitDistortion()
	let reverb = AVAudioUnitReverb()
	let timePitch = AVAudioUnitTimePitch()

	//Radio chatter
	let radioDelay = AVAudioUnitDelay()
	let radioDistortion = AVAudioUnitDistortion()
	let radioReverb = AVAudioUnitReverb()
	let radioTimePitch = AVAudioUnitTimePitch()

	//general audio format
 let audioFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 44100.0, channels: 2, interleaved: false)
	//States
	var chatting = false

	override init(){
		super.init()
		engine = AVAudioEngine()
		environment = AVAudioEnvironmentNode()
		environment.renderingAlgorithm = AVAudio3DMixingRenderingAlgorithm.stereoPassThrough
		engine.attach(self.environment)
		voicePlayer = AVAudioPlayerNode()
		voicePlayer.volume = 1.3
		interfaceFX = AVAudioPlayerNode()
		interfaceFX.volume = 1.0
		interfaceSpeak = AVAudioPlayerNode()
		interfaceSpeak.volume = 1.2
		radioChatter = AVAudioPlayerNode()
		radioChatter.volume = 0.5
		engine.attach(voicePlayer)
		engine.attach(interfaceFX)
		engine.attach(interfaceSpeak)
		engine.attach(radioChatter)
		outputBuffer = loadVoice()
		interfaceBuffer = loadInterfaceFX("focused")
		interfaceSpeakBuffer = loadInterfaceSpeak("loaded")
		//radioChatterBuffer = loadInterfaceFX("radio_chatter")
		wireEngine()
		startEngine()
		//loadRadioChatter("radio_chatter")
		print("overlay engine started")
	}

	func startEngine(){
		do{
			try engine.start()
		}catch{
			print("error loading engine")
		}
	}

	func loadVoice()->AVAudioPCMBuffer{
		loadDistortionPreset(AVAudioUnitDistortionPreset.speechRadioTower)
		distortion.wetDryMix = 80.0
		delay.delayTime = 0.01
		delay.wetDryMix = 10.0
		delay.feedback = -20.0
		timePitch.pitch = 0
		let URL = Foundation.URL(fileURLWithPath: Bundle.main.path(forResource: "art.scnassets/sounds/interface/sensor", ofType: "aiff")!)
		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
			outputBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: outputBuffer)
			}catch{
				print("somethign went wrong with loading the buffer into the sound fiel")
			}
			print("returning buffer")
			return outputBuffer
		}catch{
		}
		return outputBuffer
	}

	func loadSpeak(_ URL: Foundation.URL){
		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
			outputBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: outputBuffer)
			}catch{
				print("somethign went wrong with loading the buffer into the sound fiel")
			}
			voicePlayer.scheduleBuffer(self.outputBuffer, completionHandler: {()->Void in
				self.toggleRadioChatter()
			})
			voicePlayer.play()		}catch{
		}
	}

	func loadInterfaceFX(_ name: String)->AVAudioPCMBuffer{
		print("trying to load \(name)")
		let URL = Foundation.URL(fileURLWithPath: Bundle.main.path(forResource: "art.scnassets/sounds/interface/overlays/\(name)", ofType: "aiff")!)

		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
			interfaceBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: self.interfaceBuffer)
			}catch{
			}
		}catch{

		}
		return self.interfaceBuffer
	}

	func loadInterfaceSpeak(_ name: String)->AVAudioPCMBuffer{
		let URL = Foundation.URL(fileURLWithPath: "\(dataPath)items/\(name)/\(name).aiff")
		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
			interfaceSpeakBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: self.interfaceSpeakBuffer)
			}catch{
				print("somethign went wrong with loading the buffer into the sound fiel")
			}
		}catch{
		}
		return interfaceSpeakBuffer
	}

	func playInterfaceFX(_ name: String){
		//		print("loading \(name)")
		let URL = Foundation.URL(fileURLWithPath: Bundle.main.path(forResource: "art.scnassets/sounds/interface/overlays/\(name)", ofType: "aiff")!)
		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)

			interfaceBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: self.interfaceBuffer)
			}catch{
			}
		}catch{

		}
		interfaceFX.scheduleBuffer(self.interfaceBuffer, at: nil,
		                           options: AVAudioPlayerNodeBufferOptions.interrupts, completionHandler: nil)
		interfaceFX.play()
	}

	func playInterfaceSpeak(_ name: String, position: SCNVector3?){
		var newName = ""
		if name.contains("#"){
			print("name contains #")
			newName = name.components(separatedBy: "#").first!
			if newName.contains("_"){
				newName = newName.components(separatedBy: "_").first!
			}
		}
		if newName == ""{
			newName = name
		}
		let URL = Foundation.URL(fileURLWithPath: "\(dataPath)items/\(newName)/\(newName).aiff")
		print(URL.absoluteString)
		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
			interfaceSpeakBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: self.interfaceSpeakBuffer)
			}catch{
				print("somethign went wrong with loading the buffer into the sound fiel")
			}
		}catch{
		}
		if(position != nil){
			interfaceSpeak.position = AVAudio3DPoint(x: Float(position!.x), y: Float(position!.y), z: Float(position!.z))
		}
		interfaceSpeak.rate = 0.95
		interfaceSpeak.scheduleBuffer(self.interfaceSpeakBuffer, at: nil, options: AVAudioPlayerNodeBufferOptions.interrupts, completionHandler: nil)
		interfaceSpeak.play()
		//		AVAudioPlayerNodeBufferOptions.interrupts
	}

	func loadRadioChatter(_ name: String){
		let URL = Foundation.URL(fileURLWithPath: Bundle.main.path(forResource: "art.scnassets/sounds/interface/overlays/\(name)", ofType: "aiff")!)
		do{
			let soundFile = try AVAudioFile(forReading: URL, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: false)
			radioChatterBuffer = AVAudioPCMBuffer(pcmFormat: soundFile.processingFormat, frameCapacity: AVAudioFrameCount(soundFile.length))
			do{
				try soundFile.read(into: self.radioChatterBuffer)
			}catch{
				print("somethign went wrong with loading the buffer into the sound fiel")
			}
		}catch{
		}
		radioChatter.scheduleBuffer(self.radioChatterBuffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
	}

	func toggleRadioChatter(){
		if chatting{
			radioChatter.stop()
			chatting = false
		}else{
			radioChatter.play()
			chatting = true
		}
	}

	func wireEngine(){
		//Attach all the filters
		engine.attach(speakDistortion)
		engine.attach(speakDelay)
		engine.attach(distortion)
		engine.attach(delay)
		engine.attach(timePitch)
		speakDistortion.loadFactoryPreset(.multiCellphoneConcert)
		speakDistortion.wetDryMix = 20.0
		speakDelay.feedback = 0.1
		speakDelay.delayTime = 0.01

		engine.attach(radioDistortion)
		radioDistortion.loadFactoryPreset(.speechCosmicInterference)
		radioDistortion.wetDryMix = 5.0
		radioDelay.feedback = 2.0
		radioDelay.delayTime = 0.01
		radioChatter.volume = 0.3
		radioTimePitch.pitch = 0
		engine.attach(radioDelay)
		engine.attach(radioTimePitch)
		//For the interface FX
		engine.connect(interfaceFX, to: environment, format: self.interfaceBuffer.format)
		engine.connect(environment, to: engine.outputNode, format: constructOutputFormatForEnvironment())
		//For the voice
		engine.connect(voicePlayer, to: timePitch, format: self.outputBuffer.format)
		engine.connect(timePitch, to: distortion, format: self.outputBuffer.format)
		engine.connect(distortion, to: delay, format: self.outputBuffer.format)
		engine.connect(delay, to: environment, format: self.outputBuffer.format)
		engine.connect(environment, to: engine.outputNode, format: constructOutputFormatForEnvironment())

		//For the speaking interface
		engine.connect(interfaceSpeak, to: speakDistortion, format: self.interfaceSpeakBuffer.format)
		engine.connect(speakDistortion, to: speakDelay, format: self.interfaceSpeakBuffer.format)
		engine.connect(speakDelay, to: environment, format: self.interfaceSpeakBuffer.format)
		engine.connect(environment, to: engine.outputNode, format: constructOutputFormatForEnvironment())

		engine.connect(interfaceFX, to: environment, format: self.interfaceBuffer.format)
		engine.connect(environment, to: engine.outputNode, format: constructOutputFormatForEnvironment())
	}

	func constructOutputFormatForEnvironment()->AVAudioFormat{
		let outputChannelCount = self.engine.outputNode.outputFormat(forBus: 1).channelCount
		let hardwareSampleRate = self.engine.outputNode.outputFormat(forBus: 1).sampleRate
		let environmentOutputConnectionFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareSampleRate, channels: outputChannelCount)
		return environmentOutputConnectionFormat
	}

	func loadDistortionPreset(_ preset: AVAudioUnitDistortionPreset){
		distortion.loadFactoryPreset(preset)
		FXdistortion.loadFactoryPreset(preset)
		speakDistortion.loadFactoryPreset(preset)
	}

	func createPlayer(_ node: SCNNode){
		let player = AVAudioPlayerNode()
		distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.speechCosmicInterference)
		engine.attach(player)
		engine.attach(distortion)
		engine.connect(player, to: distortion, format: outputBuffer.format)
		engine.connect(distortion, to: environment, format: constructOutputFormatForEnvironment())
		player.reverbBlend = 0.3
		//		player.renderingAlgorithm = AVAudio3DMixingRenderingAlgorithm.stereoPassThrough
	}

	/*
	dispatch_async(globalUserInitiatedQueue){
	dispatch_async(self.globalMainQueue){
	}
	}
	*/
	
}
let layerEngine = AudioLayerEngine()
