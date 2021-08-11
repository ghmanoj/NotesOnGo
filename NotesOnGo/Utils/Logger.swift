//
//  Logger.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/10/21.
//

import Foundation


class Logger {
	static let shared = Logger()
	
	private let logFileUrl: URL
	
	private init() {
		let logFileName = "NotesOnGo.log"
		logFileUrl = Logger.getDocumentsDirectory().appendingPathComponent(logFileName)
		
//		do {
//			let text = try String(contentsOf: logFileUrl, encoding: .utf8)
//			print(text)
//		} catch {
//			print("Error reading log file \(error)")
//		}
	}
	
	func i(_ message: String) {
//		if let outputStream = OutputStream(url: logFileUrl, append: true) {
//			outputStream.open()
//			let text = "some text\n"
//			let bytesWritten = outputStream.write(text, maxLength: 10)
//			if bytesWritten < 0 { print("write failure") }
//			outputStream.close()
//		} else {
//			print("Unable to open file")
//		}
	}
	
	private static func getDocumentsDirectory() -> URL {
		// find all possible documents directories for this user
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		
		// just send back the first one, which ought to be the only one
		return paths[0]
	}
}
