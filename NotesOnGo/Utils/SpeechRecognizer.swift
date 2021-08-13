/*
From: https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio#//apple_ref/doc/uid/TP40017110
See LICENSE folder for this sample’s licensing information.
*/

import AVFoundation
import Foundation
import Speech
import SwiftUI


/// A helper for transcribing speech to text using AVAudioEngine.
struct SpeechRecognizer {
	let greeting: String
	
	private class SpeechAssist {
		var audioEngine: AVAudioEngine?
		var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
		var recognitionTask: SFSpeechRecognitionTask?
		let speechRecognizer = SFSpeechRecognizer()
		
		deinit {
			reset()
		}
		
		func reset() {
			recognitionTask?.cancel()
			audioEngine?.stop()
			audioEngine = nil
			recognitionRequest = nil
			recognitionTask = nil
		}
	}
	
	private let assistant = SpeechAssist()
	
	
	func record(callback: @escaping (String) -> Void) {
		relay(message: "Requesting access", to: callback)
		canAccess { authorized in
			guard authorized else {
				relay(message: "Access denied", to: callback)
				return
			}
			
			relay(message: "Access granted", to: callback)
			
			assistant.audioEngine = AVAudioEngine()
			guard let audioEngine = assistant.audioEngine else {
				fatalError("Unable to create audio engine")
			}
			assistant.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			guard let recognitionRequest = assistant.recognitionRequest else {
				fatalError("Unable to create request")
			}
			recognitionRequest.shouldReportPartialResults = true
			
			do {
				// relay(speech, message: "Booting audio subsystem")
				
				let audioSession = AVAudioSession.sharedInstance()
				try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
				try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
				let inputNode = audioEngine.inputNode
				// relay(speech, message: "Found input node")
				
				let recordingFormat = inputNode.outputFormat(forBus: 0)
				inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
					recognitionRequest.append(buffer)
				}
				relay(message: greeting, to: callback)
				audioEngine.prepare()
				try audioEngine.start()
				assistant.recognitionTask = assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
					var isFinal = false
					if let result = result {
						relay(message: result.bestTranscription.formattedString, to: callback)
						isFinal = result.isFinal
					}
					
					if error != nil || isFinal {
						audioEngine.stop()
						inputNode.removeTap(onBus: 0)
						self.assistant.recognitionRequest = nil
					}
				}
			} catch {
				print("Error transcibing audio: " + error.localizedDescription)
				assistant.reset()
			}
		}
	}
	
	/// Stop transcribing audio.
	func stopRecording() {
		assistant.reset()
	}
	
	private func canAccess(withHandler handler: @escaping (Bool) -> Void) {
		SFSpeechRecognizer.requestAuthorization { status in
			if status == .authorized {
				AVAudioSession.sharedInstance().requestRecordPermission { authorized in
					handler(authorized)
				}
			} else {
				handler(false)
			}
		}
	}
	
	private func relay(message: String, to callback: (String) -> Void) {
		// relay message to the callback
		callback(message)
	}
}
