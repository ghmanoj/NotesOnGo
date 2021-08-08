//
//  NoteHistoryView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

// MARK: - Note history view with grid layout containing cards
struct NoteHistoryView: View {
	@ObservedObject var viewModel = ObjectUtils.noteHistoryViewModel
	
	let columns = [
		GridItem(.adaptive(minimum: 150))
	]
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns) {
				ForEach(viewModel.noteDataList, id: \.uid) { item in
					NoteHistoryCard(
						noteItem: item,
						deleteDelegate: deleteDelegate,
						updateDelegate: updateDelegate
					)
				}
			}
			.padding(.horizontal)
		}
		.padding()
		.onAppear {
			viewModel.onGetNotesHistory(0)
		}
	}
	
	private func updateDelegate(_ item: NoteData) {
		print("Updating \(item)")
		viewModel.onUpdateItem(item)
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

// MARK: - Note history card
struct NoteHistoryCard: View {
	@Environment(\.colorScheme) var scheme
	
	let noteItem: NoteData
	let deleteDelegate: (NoteData) -> Void
	let updateDelegate: (NoteData) -> Void
	
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
			NoteHistoryDetail(
				noteItem: noteItem,
				onCancel: {
					showSheet.toggle()
				},
				onDelete: {
					showSheet.toggle()
					deleteDelegate(noteItem)
				},
				onUpdate: { title, content in
					let updatedNoteItem = NoteData(
						uid: noteItem.uid,
						title: title,
						content: content,
						timestamp: noteItem.timestamp
					)
					updateDelegate(updatedNoteItem)
				}
			)
		}
		.onTapGesture {
			showSheet.toggle()
		}
	}
}

// MARK: - Notes details sheet presented on notecard tap
struct NoteHistoryDetail: View {
	//	@AppStorage("isDarkMode") var isDarkMode: Bool = true
	
	@State private var isEditMode = false
	@State private var titleText = ""
	@State private var contentText = ""
	
	let noteItem: NoteData
	let onCancel: () -> Void
	let onDelete: () -> Void
	let onUpdate: (_ title: String, _ content: String) -> Void
	
	var body: some View {
		VStack {
			
			HStack(spacing: 15) {
				if isEditMode {
					Button(action: {
						onCancel()
					}) {
						Text("Cancel")
					}
					.padding(3)
					.background(Color.black)
					.cornerRadius(5)
				}
				
				Spacer(minLength: 0)
				Button(action: {
					if isEditMode {
						// Update delegate
						withAnimation {
							isEditMode.toggle()
						}
						onUpdate(titleText, contentText)
					} else {
						titleText = noteItem.title
						contentText = noteItem.content
						
						withAnimation {
							isEditMode.toggle()
						}
					}
				}) {
					Text(isEditMode ? "Update" : "Edit")
				}
				.padding(3)
				.background(isEditMode ? Color.green : Color.blue)
				.cornerRadius(5)
				
				Button(action: {
					onDelete()
				}) {
					Text("Delete")
				}
				.padding(3)
				.background(Color.red)
				.cornerRadius(5)
			}
			.foregroundColor(.white)
			.font(.title2)
			.padding()
			
			if isEditMode {
				VStack(alignment: .leading, spacing: 20) {
					
					Text("Date: \(noteItem.timestamp.formatDate())")
						.font(.body)
						.padding(.bottom)
					
					VStack(alignment: .leading, spacing: 1) {
						Text("Title")
							.font(.body)
						Divider()
						TextEditor(text: $titleText)
							.font(.title2)
							.disableAutocorrection(true)
							.cornerRadius(20)
							.frame(maxHeight: 120)
					}
					
					VStack(alignment: .leading, spacing: 1) {
						Text("Content")
							.font(.body)
						Divider()
						TextEditor(text: $contentText)
							.font(.title2)
							.disableAutocorrection(true)
							.cornerRadius(20)
							.frame(maxHeight: 120)
					}
				}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
			} else {
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
			}
			
			Spacer(minLength: 0)
		}
		.padding(30)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		//		.background(isDarkMode ? Color.black : .white)
		//		.foregroundColor(isDarkMode ? .white : .black)
	}
}
