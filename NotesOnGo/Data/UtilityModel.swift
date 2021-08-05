//
//  UtilityModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


// https://www.hackingwithswift.com/books/ios-swiftui/understanding-swifts-result-type
enum NetworkError: Error {
	case badURL, requestFailed, unknown, messageError
}


enum UtilityActionType {
	case logout, lock, status
}


struct ResponseMessage: Codable {
	let message: String
	let status: Bool
}


struct CommandMessage: Codable {
	let command: String
	let modifier: String
	
	func getDict() -> [String: Any] {
		let data = [
			"command": self.command,
			"modifier": self.modifier
		]
		
		return data
	}
}
