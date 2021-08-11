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
	
	
	func getAppSettings(completion: @escaping (Result<AppSettingsData, DbError>) -> Void) {
		container.performBackgroundTask { ctx in
			let fetchRequest: NSFetchRequest<AppSettingsEntity> = NSFetchRequest(entityName: "AppSettingsEntity")
			
			do {
				if let entity = try ctx.fetch(fetchRequest).first {
					
					let data = AppSettingsData(uid: entity.uid!, isCmdrMode: entity.isCmdrMode)
					completion(.success(data))
					return
					
				} else {
					let entity = AppSettingsEntity(context: ctx)
					entity.isCmdrMode = false
					entity.uid = UUID().uuidString
					try ctx.save()
					
					let data = AppSettingsData(uid: entity.uid!, isCmdrMode: false)
					
					completion(.success(data))
				}
			} catch {
				print("Error while saving app settings")
				completion(.failure(.saveFailed))
			}
		}
	}
	
	
	func saveAppSettings(appSettings: AppSettingsData, completion: @escaping (Result<Bool, DbError>) -> Void) {
		container.performBackgroundTask { ctx in
			let fetchRequest: NSFetchRequest<AppSettingsEntity> = NSFetchRequest(entityName: "AppSettingsEntity")
			
			do {
				if let entity = try ctx.fetch(fetchRequest).first {
					entity.isCmdrMode = appSettings.isCmdrMode
				} else {
					let entity = AppSettingsEntity(context: ctx)
					entity.isCmdrMode = appSettings.isCmdrMode
					entity.uid = UUID().uuidString
				}
				try ctx.save()
				
				completion(.success(true))
			} catch {
				print("Error while saving app settings")
				completion(.failure(.saveFailed))
			}
		}
	}
	
	func getApiEndPointData(completion: @escaping (Result<[ApiEndPointData], DbError>) -> Void) {
		container.performBackgroundTask { ctx in
			let fetchRequest: NSFetchRequest<ApiEndPointEntity> = NSFetchRequest(entityName: "ApiEndPointEntity")
			
			do {
				let entities = try ctx.fetch(fetchRequest)
				
				let data = entities.map { ApiEndPointData(uid: $0.uid!, ip: $0.ip!) }
				
				var map = [String: ApiEndPointData]()
				for i in 0..<data.count {
					let item = data[i]
					map[item.ip] = item
				}
				let uniqData = map.map { _, v in return v}
				
				completion(.success(uniqData))
			} catch {
				print("Error while fetching api endpoint data")
				completion(.failure(.invalidData))
			}
		}
	}
	
	func saveApiEndPoint(data: ApiEndPointData, completion: @escaping (Result<Bool, DbError>) -> Void) {
		container.performBackgroundTask { ctx in
			do {
				let entity = ApiEndPointEntity(context: ctx)
				entity.ip = data.ip
				entity.uid = UUID().uuidString
				try ctx.save()
				
				completion(.success(true))
			} catch {
				print("Error while saving api endpoint data")
				completion(.failure(.saveFailed))
			}
		}
	}
	
	func deleteApiEndPoint(_ apiEndPointData: ApiEndPointData, completion: @escaping (Result<Bool, DbError>) -> Void) {
		
		container.performBackgroundTask { ctx in
			let ip = apiEndPointData.ip
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ApiEndPointEntity")
			fetchRequest.predicate = NSPredicate(format: "%K == %@", "ip", ip)
			let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			
			do {
				try ctx.execute(batchDeleteRequest)
			} catch {
				print("Error deleting api endpoint data \(error)")
				completion(.failure(.unknown))
				return
			}
			
			completion(.success(true))
		}
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
