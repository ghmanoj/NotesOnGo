import Foundation

final class TakeNoteViewModel: ObservableObject {
  @Published private(set) var isRecording = false
  @Published private(set) var isFinishing = false
  @Published private(set) var infoMessage = ""
  @Published private(set) var noteContent = ""
  @Published private(set) var liveRecordingUpdates = ""
  @Published private(set) var cmdrResponseText = ""
  @Published private(set) var recordingType: RecordingType = .unknown
  @Published private(set) var isCommandReady = false
  @Published var isCmdrResponse = false

  private var appSettings = AppSettingsData(isCmdrMode: false)
  private let speechRecognizer = SpeechRecognizer()
  private let persistenceController = ObjectUtils.persistenceController
  private let actionCommandHelper = ActionCommandHelper()
  private var recordingID: UUID?
  private var commandID = UUID()
  private var automaticCommand: DispatchWorkItem?
  private var messageTimeout: DispatchWorkItem?
  private var pendingCommand = ""

  func fetchAppSettings() {
    SpeechRecognizer.preparePermissions { _ in }
    persistenceController.getAppSettings { [weak self] result in
      DispatchQueue.main.async {
        if case .success(let settings) = result { self?.appSettings = settings }
      }
    }
  }

  func onMicButtonPress() {
    guard !isFinishing else { return }
    if isRecording {
      automaticCommand?.cancel()
      automaticCommand = nil
      isRecording = false
      isFinishing = true
      infoMessage = "Finishing recording…"
      speechRecognizer.finishRecording()
      return
    }
    messageTimeout?.cancel()
    automaticCommand?.cancel()
    commandID = UUID() // Ignore responses from an older recording.
    noteContent = ""
    liveRecordingUpdates = ""
    recordingType = .unknown
    cmdrResponseText = ""
    isCmdrResponse = false
    isCommandReady = false
    pendingCommand = ""
    infoMessage = ""
    isRecording = true
    let id = UUID()
    recordingID = id
    speechRecognizer.record(commandMode: appSettings.isCmdrMode) { [weak self] event in
      guard let self = self, self.recordingID == id else { return }
      switch event {
      case .status(let message):
        // Permission and microphone status are never treated as dictated text.
        if self.liveRecordingUpdates.isEmpty { self.infoMessage = message }
      case .transcript(let text):
        self.liveRecordingUpdates = text
        self.scheduleAutomaticCommand(text, recordingID: id)
      case .finished(let text):
        let manuallyStopped = self.isFinishing
        self.completeRecording()
        if !manuallyStopped, self.appSettings.isCmdrMode,
           let command = ActionCommandHelper.parse(text),
           command.modifier == "lock" || command.modifier == "logout" {
          self.pendingCommand = text
          self.recordingType = .command
          self.isCommandReady = true
          self.infoMessage = "Command ready to send"
        } else {
          self.parseRecording(text)
        }
      case .failure(let message):
        self.completeRecording()
        self.showErrorMessage(message)
      }
    }
  }

  private func scheduleAutomaticCommand(_ text: String, recordingID: UUID) {
    automaticCommand?.cancel()
    automaticCommand = nil
    guard isRecording, appSettings.isCmdrMode, ActionCommandHelper.canRunAutomatically(text) else { return }
    let work = DispatchWorkItem { [weak self] in
      guard let self = self, self.recordingID == recordingID, self.isRecording,
            self.liveRecordingUpdates == text else { return }
      self.completeRecording()
      self.speechRecognizer.stopRecording()
      self.parseRecording(text)
    }
    automaticCommand = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.65, execute: work)
  }

  private func completeRecording() {
    automaticCommand?.cancel()
    automaticCommand = nil
    recordingID = nil
    isRecording = false
    isFinishing = false
    liveRecordingUpdates = ""
    infoMessage = ""
  }

  func onRunCommand() {
    guard isCommandReady else { return }
    let text = pendingCommand
    pendingCommand = ""
    isCommandReady = false
    parseRecording(text)
  }

  func cancelRecording() {
    messageTimeout?.cancel()
    completeRecording()
    speechRecognizer.stopRecording()
    commandID = UUID()
    isCommandReady = false
    pendingCommand = ""
  }

  func onSaveNote() {
    guard !noteContent.isEmpty else { return }
    let content = noteContent
    persistenceController.saveNoteData(NoteData(uid: UUID(), content: content, timestamp: Date())) { [weak self] result in
      DispatchQueue.main.async {
        if case .success = result, self?.noteContent == content { self?.noteContent = "" }
      }
    }
  }

  func onDiscardNote() { noteContent = "" }

  private func parseRecording(_ text: String) {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else {
      showErrorMessage(EMPTY_RECORDING_MESSAGE)
      return
    }
    let prefix = text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted)
      .first(where: { !$0.isEmpty })
    if appSettings.isCmdrMode && (prefix == "system" || prefix == "utility") {
      recordingType = .command
      guard ActionCommandHelper.parse(text) != nil else {
        showErrorMessage("Command not recognized")
        return
      }
      handleCmdrApiCall(text)
    } else {
      recordingType = .note
      noteContent = text
    }
  }

  private func handleCmdrApiCall(_ text: String) {
    infoMessage = "Sending command…"
    let id = UUID()
    commandID = id
    persistenceController.getApiEndPointData { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self, self.commandID == id else { return }
        switch result {
        case .success(let endPoints):
          self.actionCommandHelper.perform(msg: text, on: endPoints) { [weak self] response in
            DispatchQueue.main.async {
              guard let self = self, self.commandID == id else { return }
              if response.status {
                self.infoMessage = ""
                self.isCmdrResponse = true
                self.cmdrResponseText = response.message
              } else if !self.isCmdrResponse {
                // A failed endpoint must not replace a successful response from another.
                self.showErrorMessage(response.message)
              }
            }
          }
        case .failure:
          self.showErrorMessage(CMDR_RESPONSE_ERROR_MESSAGE)
        }
      }
    }
  }

  private func showErrorMessage(_ message: String) {
    messageTimeout?.cancel()
    infoMessage = message
    let timeout = DispatchWorkItem { [weak self] in self?.infoMessage = "" }
    messageTimeout = timeout
    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: timeout)
  }
}
