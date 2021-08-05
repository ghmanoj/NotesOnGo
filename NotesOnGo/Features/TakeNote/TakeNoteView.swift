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
	
	private let utilityApiService = UtilityApiService()
	
	let speechRecognizer = SpeechRecognizer(greetingMessage: "Please start recording...")
	
	var body: some View {
		VStack {
			Spacer(minLength: 0)
			
			ZStack {
				Text(errorMessage)
					.offset(y: -200)
				
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
					.offset(y: 100)
				
				VStack(alignment: .leading) {
					Text(noteTitle)
					Text(noteContent)
				}
				.font(.title3)
				.offset(y:200)
				
			}
			.offset(y: -100)
			
			Spacer(minLength: 0)
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
		} else if tmpTokens.contains("uptime") {
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
		}
	}
	
}


struct TakeNoteView_Previews: PreviewProvider {
	static var previews: some View {
		TakeNoteView()
	}
}
