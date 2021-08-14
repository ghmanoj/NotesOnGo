//
//  BackupUtils.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/10/21.
//

import Foundation

class BackupUtils {
	
	func performBackup(_ data: [NoteData], completion: @escaping (Bool, [Any]?) -> Void) {
		let backupFileName = "NotesOnGo_\(Date().formatDateForFileName()).json"

		let dir = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(backupFileName)
		
		DispatchQueue.global(qos: .userInitiated).async {
			sleep(2)
			
			do {
				let encoder = JSONEncoder()
				let encodedData = try encoder.encode(data)
				try encodedData.write(to: dir!, options: .atomic)
				
				var filesToShare = [Any]()
				filesToShare.append(dir!)
				
				completion(true, filesToShare)
			} catch {
				print(error.localizedDescription)
				completion(false, nil)
			}
		}
	}
}
