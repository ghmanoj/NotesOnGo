//
//  CommandHelper.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/10/21.
//

import Foundation


class ActionCommandHelper {
	private let utilityApiService = ObjectUtils.utilityApiService
	private let logger = ObjectUtils.logger
	
  func perform(msg: String, on endPoints: [ApiEndPointData], callback: @escaping (CommandResponse) -> Void) {
		// sanity check
		if !msg.starts(with: "system") && !msg.starts(with: "utility") {
			print("Action should start with ^System or ^Utility")
			return
		}

		if msg.starts(with: "system") {
      handleSystemCmdAction(msg, endPoints, callback: callback)
		} else if msg.starts(with: "utility") {
      handleUtilityCmdAction(msg, endPoints, callback: callback)
		} else {
			print("Does not match system or utility")
			return
		}
	}
	
  private func handleSystemCmdAction(_ msg: String, _ endPoints: [ApiEndPointData], callback: @escaping (CommandResponse) -> Void) {
		var recording = msg

		guard let cmdEndIdx = recording.firstIndex(of: " ") else {
			return
		}
		
		// this removes system tag
		var startIdx = recording.startIndex
		recording.removeSubrange(startIdx..<cmdEndIdx)
		recording.removeFirst()
		
		// get action tag now
		startIdx = recording.startIndex
	
		var tmp: CommandMessage?
		
		if recording.starts(with: "status") {
			tmp = CommandMessage(command: "system", modifier: "status")
		} else if recording.starts(with: "update") {
			tmp = CommandMessage(command: "system", modifier: "update")
		} else {
			print("Unknown command \(recording)")
			return
		}
		
		let cmdMessage = tmp!
		DispatchQueue.global(qos: .userInitiated).async {
			self.executeCommandOnEndpoints(cmdMessage, endPoints, callback: callback)
		}
	}
	
	private func handleUtilityCmdAction(_ msg: String, _ endPoints: [ApiEndPointData], callback: @escaping (CommandResponse) -> Void) {
		var recording = msg

		guard let cmdEndIdx = recording.firstIndex(of: " ") else {
			return
		}
		
		// this removes system tag
		var startIdx = recording.startIndex
		recording.removeSubrange(startIdx..<cmdEndIdx)
		recording.removeFirst()
		
		// get action tag now
		startIdx = recording.startIndex
	
		var tmp: CommandMessage?
		
		if recording.starts(with: "lock") {
			tmp = CommandMessage(command: "utility", modifier: "lock")
		} else if recording.starts(with: "logout") || recording.starts(with: "log out") {
			tmp = CommandMessage(command: "utility", modifier: "logout")
    } else if recording.starts(with: "mailbox") {
      tmp = CommandMessage(command: "utility", modifier: "mailbox")
		} else {
			print(recording)
			return
		}
		
		let cmdMessage = tmp!
		DispatchQueue.global(qos: .userInitiated).async {
      self.executeCommandOnEndpoints(cmdMessage, endPoints, callback: callback)
		}
	}
	
	private func executeCommandOnEndpoints(_ cmdMessage: CommandMessage, _ endPoints: [ApiEndPointData], callback: @escaping (CommandResponse) -> Void) {
		if endPoints.count == 0 {
			return
		}
		for idx in 0..<endPoints.count {
			let ip = endPoints[idx].ip
			utilityApiService.performAction(ip, cmdMessage: cmdMessage) { result in
				switch result{
					case .success(let data):
						do {
              let resp = try utilCmdResponseParser(data);
              callback(resp);
						} catch {
							print("Error while parsing response")
						}
					case .failure(_):
						print("Failed to perform action")
				}
			}
		}
	}
}
