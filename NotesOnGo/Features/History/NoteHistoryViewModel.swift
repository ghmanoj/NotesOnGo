//
//  NoteHistoryViewModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/5/21.
//

import Foundation


class NoteHistoryViewModel: ObservableObject {
	@Published var noteDataList = [NoteData]()
	
	private var persistenceController = ObjectUtils.persistenceController
	
	
	func onGetNotesHistory(_ offset: Int) {
		persistenceController.getNoteData(offset) { result in
			switch result {
				case .success(let notes):
					RunInUiThread { self.noteDataList = notes }
				case .failure(let error):
					print("Error \(error)")
			}
		}
	}
	
}
