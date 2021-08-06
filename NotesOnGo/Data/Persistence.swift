//
//  Persistence.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/5/21.
//

import Foundation
import CoreData


class PersistenceController {
	static let shared = PersistenceController()
	
	private let container: NSPersistentContainer
	
	private init() {
		container = NSPersistentContainer(name: "AppDbStorage")
		container.loadPersistentStores { description, error in
			if let error = error {
				fatalError("Failed to load app db storage \(error)")
			}
		}
	}
	
	
	func saveSettings(isDevCmdOn: Bool, completion: @escaping (Result<Bool, DbError>) -> Void) {
		
	}
	
	func saveNoteData(_ noteData: NoteData, completion: @escaping (Result<Bool, DbError>) -> Void) {
		container.performBackgroundTask { ctx in
			let entity = NoteEntity(context: ctx)
			entity.uid = noteData.uid
			entity.title = noteData.title
			entity.content = noteData.content
			entity.timestamp = noteData.timestamp
			
			do {
				try ctx.save()
				completion(.success(true))
			} catch {
				print("Error while saving note entity \(error)")
				completion(.failure(.saveFailed))
			}
		}
	}
	
	
	func getNoteData(_ offset: Int, completion: @escaping (Result<[NoteData], DbError>) -> Void) {
		
		container.performBackgroundTask { ctx in
			let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
			fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.timestamp, ascending: false)]
			fetchRequest.fetchLimit = 20
			fetchRequest.fetchOffset = offset
			
			var notes = [NoteData]()
			
			do {
				let entities = try ctx.fetch(fetchRequest)
				notes = entities.map { NoteData(title: $0.title!, content: $0.content!, timestamp: $0.timestamp!) }
				completion(.success(notes))
			} catch {
				print("Error while fetching note data.\(error)")
				completion(.failure(.unknown))
			}
		}
	}
	
}
