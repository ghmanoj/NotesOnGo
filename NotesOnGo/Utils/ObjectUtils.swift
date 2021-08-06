//
//  ObjectUtils.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/5/21.
//

import Foundation


// dependency injection stuffs

class ObjectUtils {
	static let settingsViewModel = SettingsViewModel()
	static let noteHistoryViewModel = NoteHistoryViewModel()
	static let takeNoteViewModel = TakeNoteViewModel()
	
	static let utilityApiService = UtilityApiService()
	
	static let persistenceController = PersistenceController.shared
}
