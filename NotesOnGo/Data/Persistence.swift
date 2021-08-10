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
			entity.uid = noteData.uid.uuidString
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
				notes = entities.map { NoteData(uid: UUID(uuidString: $0.uid!)!, content: $0.content!, timestamp: $0.timestamp!) }
				completion(.success(notes))
			} catch {
				print("Error while fetching note data.\(error)")
				completion(.failure(.unknown))
			}
		}
	}
	
	func deleteNoteData(_ uid: UUID, completion: @escaping (Result<Bool, DbError>) -> Void) {
		
		container.performBackgroundTask { ctx in
			let uidString = uid.uuidString
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
			fetchRequest.predicate = NSPredicate(format: "%K == %@", "uid", uidString)
			let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			
			do {
				try ctx.execute(batchDeleteRequest)
			} catch {
				print("Error deleting note data \(error)")
				completion(.failure(.unknown))
				return
			}
			
			completion(.success(true))
		}
	}
	
	func updateNoteData(_ noteItem: NoteData, completion: @escaping (Result<Bool, DbError>) -> Void) {
		
		container.performBackgroundTask { ctx in
			let uidString = noteItem.uid.uuidString

			let fetchRequest: NSFetchRequest<NoteEntity> = NSFetchRequest(entityName: "NoteEntity")
			fetchRequest.predicate = NSPredicate(format: "%K == %@", "uid", uidString)
			
			do {
				let noteEntity = try ctx.fetch(fetchRequest).first!
				noteEntity.content = noteItem.content
				
				try ctx.save()
			} catch {
				print("Error deleting note data \(error)")
				completion(.failure(.unknown))
				return
			}
			
			completion(.success(true))
		}
		
	}
}
