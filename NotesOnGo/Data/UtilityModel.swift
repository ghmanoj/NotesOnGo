//
//  UtilityModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


// https://www.hackingwithswift.com/books/ios-swiftui/understanding-swifts-result-type
enum NetworkError: Error {
	case badURL, requestFailed, unknown
}


enum UtilityActionType {
	case logout, screenlock, status
}


struct ResponseMessage: Codable {
	let message: String
	let status: Bool
}
