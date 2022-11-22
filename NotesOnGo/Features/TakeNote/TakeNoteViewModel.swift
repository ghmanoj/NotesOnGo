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
  
  @Published private(set) var cmdrResponseText = ""
  
  @Published private(set) var recordingType: RecordingType = .unknown
  
  @Published var isCmdrResponse = false
  
  
  private var appSettings: AppSettingsData = AppSettingsData(isCmdrMode: false)
  
  private let speechRecognizer = SpeechRecognizer(greeting: GREETING_MESSAGE)
  
  private let persistenceController = ObjectUtils.persistenceController
  
  private let actionCommandHelper = ActionCommandHelper()
  
  
  func fetchAppSettings() {
    persistenceController.getAppSettings { result in
      switch result {
      case .success(let settings):
        print(settings)
        self.appSettings = settings
      case .failure(_):
        print("Failed to fetch latest app settings")
      }
    }
  }
  
  func onMicButtonPress() {
    isRecording.toggle()
    noteContent = ""
    recordingType = .unknown
    cmdrResponseText = ""
    
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
          print("Failed to save note: \(message)")
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
    
    let isCmdrModeActive = appSettings.isCmdrMode
    
    if isCmdrModeActive && (msg.starts(with: "system") || msg.starts(with: "utility")) {
      print("Performing Cmdr Api Calls... Message string is: \(msg)")
      recordingType = .command
      
      handleCmdrApiCall(msg)
    } else {
      recordingType = .note
      
      handleRecordCommand()
    }
  }
  
  private func handleCmdrApiCall(_ message: String) {
    persistenceController.getApiEndPointData { result in
      switch result {
      case .success(let endPoints):
        self.actionCommandHelper.perform(msg: message, on: endPoints, callback: self.cmdrCallBack)
      case .failure(_):
        self.showErrorMessage(CMDR_RESPONSE_ERROR_MESSAGE)
      }
    }
  }
  
  private func handleRecordCommand() {
    let recording = liveRecordingUpdates
    
    if recording.isEmpty || recording == GREETING_MESSAGE {
      showErrorMessage(EMPTY_RECORDING_MESSAGE)
      return
    }

    noteContent = String(recording)
    
    RunInUiThread {
      self.liveRecordingUpdates = ""
      self.infoMessage = ""
    }
  }
  
  private func cmdrCallBack(_ response: CommandResponse) {
    RunInUiThread {
      if (response.status) {
        self.isCmdrResponse = true
        self.cmdrResponseText = response.message
      }
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
