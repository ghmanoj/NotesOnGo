//
//  TakeNoteView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI
import Speech
import AVFoundation

struct TakeNoteView: View {
	@State var recording = ""
	@State var errorMessage = ""
	
	@State var isRecording = false
	
	@State var noteTitle = ""
	@State var noteContent = ""
	
	@State private var orientation = UIDeviceOrientation.unknown
	
	private let utilityApiService = UtilityApiService()
	
	let speechRecognizer = SpeechRecognizer(greetingMessage: "Please start recording...")
	
	var body: some View {
		VStack {
			
			VStack(alignment: .leading, spacing: 3) {
				HStack {
					Image(systemName: "megaphone")
						.rotationEffect(.degrees(-45))
					Text("Title [title of the note]")
				}
				HStack {
					Image(systemName: "megaphone")
						.rotationEffect(.degrees(-45))
					Text("Content [content of the note]")
				}
			}
			.font(.caption2)
			.foregroundColor(.secondary)
						
			if orientation == .portrait
					|| orientation == .portraitUpsideDown
					|| orientation == .unknown
					|| orientation == .faceDown
					|| orientation == .faceUp {
				
				VStack(spacing: 40) {
					Text(errorMessage)
						.frame(height: 20)
					
					Image(systemName: "mic.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(isRecording ? .green : .red)
						.frame(height: 80)
						.onTapGesture {
							errorMessage = ""
							noteTitle = ""
							noteContent = ""
							
							if isRecording {
								speechRecognizer.stopRecording()
								isRecording = false
								
								parseRecording()
								
							} else {
								recording = ""
								isRecording = true
								speechRecognizer.record(to: $recording)
							}
						}
					
					Text(recording)
						.font(.title3)
						.frame(height: 20)
					
					VStack(alignment: .leading) {
						Text(noteTitle)
						Text(noteContent)
					}
					.font(.title3)
				}
			} else {
				HStack(spacing: 40) {
					Text(errorMessage)
						.frame(height: 20)
					
					Image(systemName: "mic.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(isRecording ? .green : .red)
						.frame(height: 80)
						.onTapGesture {
							errorMessage = ""
							noteTitle = ""
							noteContent = ""
							
							if isRecording {
								speechRecognizer.stopRecording()
								isRecording = false
								
								parseRecording()
								
							} else {
								recording = ""
								isRecording = true
								speechRecognizer.record(to: $recording)
							}
						}
					
					Text(recording)
						.font(.title3)
						.frame(height: 20)
					
					VStack(alignment: .leading) {
						Text(noteTitle)
						Text(noteContent)
					}
					.font(.body)					
				}
			}
		}
		.onRotate { newOrientation in
			orientation = newOrientation
		}
	}
	
	
	private func parseRecording() {
		let tokens = recording.split(separator: " ")
		
		let tmpTokens = tokens.map { $0.lowercased() }
		
		if tmpTokens.contains("title") && tmpTokens.contains("content") {
			let titleIndex = tmpTokens.firstIndex(of: "title")!
			let contentIndex = tmpTokens.firstIndex(of: "content")!
			
			let title = tokens[titleIndex+1..<contentIndex].joined(separator: " ")
			let content = tokens[contentIndex+1..<tokens.count].joined(separator: " ")
			
			noteTitle = title.capitalized
			noteContent = content.capitalized
			
			recording = ""
		} else if tmpTokens.contains("utility") && tmpTokens.contains("logout") {
			utilityApiService.performAction(actionType: .logout) { result in
				switch result {
					case .success(let data):
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						do {
							let message = try decoder.decode(ResponseMessage.self, from: data)
							
							DispatchQueue.main.async { self.noteContent = message.message }
							
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
							 
							 DispatchQueue.main.async { self.noteContent = message.message }
							 
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
							
							DispatchQueue.main.async { self.noteContent = message.message }
							
						} catch {
							print("\(error)")
						}
					case .failure(let error):
						print("failure \(error)")
				}
			}
		} else {
			errorMessage = "Please specify note title and content"
			recording = ""
		}
	}
	
}


struct TakeNoteView_Previews: PreviewProvider {
	static var previews: some View {
		TakeNoteView()
	}
}
