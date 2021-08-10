//
//  TakeNoteViewModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/5/21.
//

import Foundation


class TakeNoteViewModel: ObservableObject {
	
	@Published private(set) var isRecording = false
	@Published private(set) var infoMessage = ""
	
	@Published private(set) var noteContent = ""
	
	@Published private(set) var liveRecordingUpdates = ""

	private let speechRecognizer = SpeechRecognizer(greeting: "Start speaking....")
	
	private let persistenceController = ObjectUtils.persistenceController
	
	private let actionCommandHelper = ActionCommandHelper()
	
	func onMicButtonPress() {
		isRecording.toggle()
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
	
	func onSaveNote() {
		if !noteContent.isEmpty {
			let noteData = NoteData(uid: UUID(), content: noteContent, timestamp: Date())
			
			persistenceController.saveNoteData(noteData) { result in
				switch result {
					case .success(_):
						RunInUiThread {
							self.noteContent = ""
						}
					case .failure(let message):
						print(message)
				}
			}
		}
	}
	
	func onDiscardNote() {
		noteContent = ""
	}
	
	private func updateLiveRecording(_ message: String) {
		RunInUiThread {
			self.liveRecordingUpdates = message
		}
	}
	
	private func parseRecording() {
		let msg = liveRecordingUpdates.lowercased()
		// starts with record so is note recording
		if msg.starts(with: "record") {
			handleRecordCommand()
		} else if msg.starts(with: "system") || msg.starts(with: "utility") {
			persistenceController.getApiEndPointData { result in
				switch result {
					case .success(let endPoints):
						self.actionCommandHelper.perform(msg: msg, on: endPoints)
					case .failure(_):
						print("Failed to fetch api endpoints")
				}
			}
		} else {
			showErrorMessage("Please specify note")
		}
	}
	
	private func handleRecordCommand() {
		var recording = liveRecordingUpdates
		guard let separatorIdx = recording.firstIndex(of: " ") else {
			showErrorMessage("Speech should start with ^Record and have some content")
			return
		}
		let startIdx = recording.startIndex
		recording.removeSubrange(startIdx..<separatorIdx)
		recording.removeFirst()

		if recording.count < 2 {
			showErrorMessage("Not enough content in the recording")
			return
		}
		var	data = String(recording.removeFirst().uppercased())
		data.append(recording)
		noteContent = data
		
		RunInUiThread {
			self.liveRecordingUpdates = ""
			self.infoMessage = ""
		}
	}
	
	private func showErrorMessage(_ message: String) {
		RunInUiThread {
			self.infoMessage = message
			DispatchQueue.main.asyncAfter(deadline: .now()+2) {
				self.infoMessage = ""
			}
		}
	}
}
