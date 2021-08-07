//
//  NoteHistoryView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

struct NoteHistoryView: View {
	@ObservedObject var viewModel = ObjectUtils.noteHistoryViewModel
	
	let columns = [
		GridItem(.adaptive(minimum: 150))
	]
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
				ForEach(viewModel.noteDataList, id: \.uid) { item in
					NoteHistoryCard(noteItem: item) { deleteItem in
						deleteDelegate(deleteItem)
					}
				}
			}
			.padding(.horizontal)
		}
		.padding()
		.onAppear {
			viewModel.onGetNotesHistory(0)
		}
	}
	
	private func performDelete(_ idxSet: IndexSet) {
		for noteIndex in idxSet {
			viewModel.onNoteItemSwipe(noteIndex)
		}
	}
	
	private func deleteDelegate(_ item: NoteData) {
		print("\(item) will be deleted")
		viewModel.onDeleteItem(item)
	}
}


struct NoteHistoryCard: View {
	@Environment(\.colorScheme) var scheme
	
	let noteItem: NoteData
	let deleteDelegate: (NoteData) -> Void
	
	@State var showSheet = false
	
	var body: some View {
		ZStack {
			Rectangle()
				.frame(width: 150, height: 150)
				.foregroundColor(.secondary.opacity(0.15))
				.cornerRadius(20)
			
			VStack(alignment: .center) {
				Text(noteItem.title)
					.font(.title3)
					.fontWeight(.medium)
				
				Text("\(noteItem.timestamp.formatDate())")
					.foregroundColor(.secondary)
					.font(.caption)
			}
			.padding(12)
			.frame(width: 150, height: 150)
		}
		.sheet(isPresented: $showSheet) {
			NoteHistoryDetail(noteItem: noteItem) {
				showSheet.toggle()
				deleteDelegate(noteItem)
			}
		}
		.onTapGesture {
			showSheet.toggle()
		}
	}
}

struct NoteHistoryDetail: View {
	@AppStorage("isDarkMode") var isDarkMode: Bool = true
	
	let noteItem: NoteData
	let deleteDelegate: () -> Void
	
	var body: some View {
		VStack {
			
			HStack(spacing: 5) {
				Spacer(minLength: 0)
				Button(action: {
					// edit delegate
				}) {
					Text("Edit")
				}
				.padding(3)
				.cornerRadius(5)
				
				Button(action: {
					deleteDelegate()
				}) {
					Text("Delete")
				}
				.padding(3)
				.background(Color.red)
				.cornerRadius(5)
			}
			.padding()
			
			VStack(alignment: .leading, spacing: 20) {
				Text("Title: \(noteItem.title)")
					.font(.title)
				Text("Content: \(noteItem.content)")
					.font(.title2)
				Text("Date: \(noteItem.timestamp.formatDate())")
					.font(.body)
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			
			Spacer(minLength: 0)
		}
		.padding(30)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(isDarkMode ? Color.black.opacity(0.5) : Color.white)
		.foregroundColor(isDarkMode ? .white : .black)
	}
}
