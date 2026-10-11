import AVFoundation
import Foundation
import Speech
import os.log

/// Audio setup and recognition lifecycle run off the UI thread, on one queue.
final class SpeechRecognizer {
  enum Event {
    case status(String)
    case transcript(String)
    case finished(String)
    case failure(String)
  }

  private let queue = DispatchQueue(label: "notesongo.speech", qos: .userInitiated)
  private let audioEngine = AVAudioEngine()
  private let recognizer = SFSpeechRecognizer()
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private var callback: ((Event) -> Void)?
  private var sessionID: UUID?
  private var transcript = ""
  private var hasTap = false
  private var finishing = false
  private var finishTimeout: DispatchWorkItem?
  private let log = OSLog(subsystem: "notesongo", category: "speech")

  static func preparePermissions(completion: @escaping (Bool) -> Void) {
    func microphoneAccess() {
      let session = AVAudioSession.sharedInstance()
      switch session.recordPermission {
      case .granted: completion(true)
      case .denied: completion(false)
      default: session.requestRecordPermission(completion)
      }
    }
    switch SFSpeechRecognizer.authorizationStatus() {
    case .authorized: microphoneAccess()
    case .notDetermined:
      SFSpeechRecognizer.requestAuthorization { status in
        if status == .authorized { microphoneAccess() }
        else { completion(false) }
      }
    default: completion(false)
    }
  }

  func record(commandMode: Bool, callback: @escaping (Event) -> Void) {
    queue.async {
      self.reset()
      let id = UUID()
      self.sessionID = id
      self.callback = callback
      self.emit(.status("Preparing microphone…"))
      Self.preparePermissions { [weak self] allowed in
        guard let self = self else { return }
        self.queue.async {
          guard self.sessionID == id else { return }
          guard allowed else {
            self.complete(.failure("Enable microphone and speech access in Settings."))
            return
          }
          self.start(id: id, commandMode: commandMode, preferOnDevice: true)
        }
      }
    }
  }

  private func start(id: UUID, commandMode: Bool, preferOnDevice: Bool) {
    guard let recognizer = recognizer, recognizer.isAvailable else {
      complete(.failure("Speech recognition is unavailable. Please try again."))
      return
    }
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.shouldReportPartialResults = true
    request.taskHint = commandMode ? .search : .dictation
    let onDevice = preferOnDevice && recognizer.supportsOnDeviceRecognition
    request.requiresOnDeviceRecognition = onDevice
    if commandMode {
      request.contextualStrings = ["system status", "utility mailbox", "utility lock", "utility log out"]
    }
    self.request = request
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
      try audioSession.setPreferredIOBufferDuration(0.01)
      try audioSession.setActive(true)
      let input = audioEngine.inputNode
      let format = input.outputFormat(forBus: 0)
      guard format.sampleRate > 0, format.channelCount > 0 else {
        complete(.failure("No microphone input is available."))
        return
      }
      input.installTap(onBus: 0, bufferSize: 512, format: format) { buffer, _ in
        request.append(buffer)
      }
      hasTap = true
      task = recognizer.recognitionTask(with: request) { [weak self] result, error in
        guard let self = self else { return }
        // Extract the result before crossing queues.
        let text = result?.bestTranscription.formattedString
        let final = result?.isFinal ?? false
        let recognitionError = error as NSError?
        self.queue.async {
          guard self.sessionID == id else { return }
          if let text = text, text != self.transcript {
            self.transcript = text
            self.emit(.transcript(text))
          }
          if let error = recognitionError {
            os_log("Recognition error: %{public}@ (%{public}ld)", log: self.log,
                   type: .error, error.domain, error.code)
          }
          // Device support does not guarantee that its speech model can start.
          // Retry only before any words are captured, never after a manual stop.
          if (recognitionError != nil || final), self.transcript.isEmpty,
             !self.finishing, onDevice {
            self.retryUsingNetwork(commandMode: commandMode)
          } else if final && !self.transcript.isEmpty {
            self.complete(.finished(self.transcript))
          } else if self.finishing && (final || recognitionError != nil) {
            self.complete(.finished(self.transcript))
          } else if let error = recognitionError {
            self.complete(.failure("Speech recognition failed: \(error.localizedDescription)"))
          } else if final {
            self.complete(.failure("No speech was detected. Tap the microphone and try again."))
          }
        }
      }
      audioEngine.prepare()
      try audioEngine.start()
      emit(.status(GREETING_MESSAGE))
    } catch {
      complete(.failure("Unable to start the microphone: \(error.localizedDescription)"))
    }
  }

  private func retryUsingNetwork(commandMode: Bool) {
    let callback = self.callback
    // A new ID prevents cancellation callbacks from the old task ending the retry.
    reset()
    let id = UUID()
    sessionID = id
    self.callback = callback
    emit(.status("Starting network speech recognition…"))
    start(id: id, commandMode: commandMode, preferOnDevice: false)
  }

  /// Let recognition drain its final buffers instead of cancelling immediately.
  func finishRecording() {
    queue.async {
      guard let id = self.sessionID, !self.finishing else { return }
      self.finishing = true
      self.stopAudio()
      guard let request = self.request else {
        self.complete(.finished(self.transcript))
        return
      }
      request.endAudio()
      let fallback = DispatchWorkItem { [weak self] in
        guard let self = self, self.sessionID == id, self.finishing else { return }
        self.complete(.finished(self.transcript))
      }
      self.finishTimeout = fallback
      self.queue.asyncAfter(deadline: .now() + 0.75, execute: fallback)
    }
  }

  /// A stable read-only command can use its current transcript immediately.
  func stopRecording() {
    queue.async { self.reset() }
  }

  private func emit(_ event: Event) {
    guard let callback = callback else { return }
    DispatchQueue.main.async { callback(event) }
  }

  private func complete(_ event: Event) {
    emit(event)
    reset()
  }

  private func stopAudio() {
    audioEngine.stop()
    if hasTap {
      audioEngine.inputNode.removeTap(onBus: 0)
      hasTap = false
    }
  }

  private func reset() {
    sessionID = nil
    finishTimeout?.cancel()
    finishTimeout = nil
    stopAudio()
    request?.endAudio()
    task?.cancel()
    task = nil
    request = nil
    callback = nil
    transcript = ""
    finishing = false
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }
}
