//
//  NoteData.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import Foundation


struct NoteData: Codable {
	let uid: UUID
	let content: String
	let timestamp: Date
}
