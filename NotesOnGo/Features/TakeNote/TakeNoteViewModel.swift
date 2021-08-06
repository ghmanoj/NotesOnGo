//
//  TakeNoteViewModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/5/21.
//

import Foundation


class TakeNoteViewModel: ObservableObject {

	@Published private(set) var isRecording = false
	@Published private(set) var errorMessage = ""
	
	@Published private(set) var liveRecordingUpdates = ""
	
	@Published private(set) var noteTitle = ""
	@Published private(set) var noteContent = ""
	
	private let speechRecognizer = SpeechRecognizer(greeting: "Start speaking....")

	private let utilityApiService = ObjectUtils.utilityApiService


	func onMicButtonPress() {
		isRecording.toggle()
		errorMessage = ""
		noteTitle = ""
		noteContent = ""
	
		if isRecording {
			speechRecognizer.record { message in
				self.updateLiveRecording(message)
			}
		} else {
			// recording finished
			speechRecognizer.stopRecording()
			parseRecording()
			liveRecordingUpdates = ""
		}
	}
	
	private func updateLiveRecording(_ message: String) {
		print(message)
		
		DispatchQueue.main.async {
			self.liveRecordingUpdates = message
		}
	}
	
	private func parseRecording() {		
		let tokens = liveRecordingUpdates.split(separator: " ")
		
		let tmpTokens = tokens.map { $0.lowercased() }
		
		if tmpTokens.contains("title") && tmpTokens.contains("content") {
			let titleIndex = tmpTokens.firstIndex(of: "title")!
			let contentIndex = tmpTokens.firstIndex(of: "content")!
			
			let title = tokens[titleIndex+1..<contentIndex].joined(separator: " ")
			let content = tokens[contentIndex+1..<tokens.count].joined(separator: " ")
			
			
			DispatchQueue.main.async {
				self.noteTitle = title.capitalized
				self.noteContent = content.capitalized
			}
			
		} else if tmpTokens.contains("utility") && tmpTokens.contains("logout") {
			utilityApiService.performAction(actionType: .logout) { result in
				switch result {
					case .success(let data):
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						do {
							let message = try decoder.decode(ResponseMessage.self, from: data)
							
							DispatchQueue.main.async {
								self.noteContent = message.message
							}
							
						} catch {
							print("\(error)")
						}
					case .failure(let error):
						print("failure \(error)")
				}
			}
		} else if tmpTokens.contains("utility") && tmpTokens.contains("lock") {
			utilityApiService.performAction(actionType: .lock) { result in
				switch result {
					case .success(let data):
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						do {
							let message = try decoder.decode(ResponseMessage.self, from: data)
							
							DispatchQueue.main.async {
								self.noteContent = message.message
							}
						} catch {
							print("\(error)")
						}
					case .failure(let error):
						print("failure \(error)")
				}
			}
		} else if tmpTokens.contains("system") && tmpTokens.contains("status") {
			utilityApiService.performAction(actionType: .status) { result in
				switch result {
					case .success(let data):
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						do {
							let message = try decoder.decode(ResponseMessage.self, from: data)
							
							DispatchQueue.main.async {
								self.noteContent = message.message
							}
						} catch {
							print("\(error)")
						}
					case .failure(let error):
						print("failure \(error)")
				}
			}
		} else {
			DispatchQueue.main.async {
				self.errorMessage = "Please specify note title and content"
				DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
					self.errorMessage = ""
				}
			}
		}
	}
}
