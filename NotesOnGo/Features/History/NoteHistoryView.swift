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
    GridItem(.adaptive(minimum: 165))
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
            .padding(5)
        }
      }
    }
    .onAppear {
      viewModel.onGetNotesHistory(0)
    }
  }
  
  private func updateDelegate(_ item: NoteData) {
    viewModel.onUpdateItem(item)
  }
  
  private func performDelete(_ idxSet: IndexSet) {
    for noteIndex in idxSet {
      viewModel.onNoteItemSwipe(noteIndex)
    }
  }
  
  private func deleteDelegate(_ item: NoteData) {
    viewModel.onDeleteItem(item)
    generateHepaticFeedback()
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
        .frame(width: 165, height: 155)
        .foregroundColor(.secondary.opacity(0.15))
        .cornerRadius(20)
      
      VStack(alignment: .center) {
        HStack {
          Text(noteItem.content)
            .font(.title3)
            .fontWeight(.medium)
          Spacer(minLength: 0)
        }
        
        Spacer(minLength: 0)
        
        Text("\(noteItem.timestamp.formatDate())")
          .foregroundColor(.secondary)
          .font(.caption)
      }
      .padding(12)
      .frame(width: 165, height: 155)
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
        onUpdate: { content in
          let updatedNoteItem = NoteData(
            uid: noteItem.uid,
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
  @State private var contentText = ""
  
  let noteItem: NoteData
  let onCancel: () -> Void
  let onDelete: () -> Void
  let onUpdate: ( _ content: String) -> Void
  
  var body: some View {
    VStack {
      
      HStack(spacing: 15) {
        if isEditMode {
          Button(action: {
            generateHepaticFeedback()
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
          generateHepaticFeedback()
          
          if isEditMode {
            // Update delegate
            withAnimation {
              isEditMode.toggle()
            }
            onUpdate(contentText)
          } else {
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
          generateHepaticFeedback()
          onDelete()
        }) {
          Text("Delete")
        }
        .padding(3)
        .background(Color.red)
        .cornerRadius(5)
      }
      .foregroundColor(.white)
      .font(.title3)
      .padding()
      
      if isEditMode {
        VStack(alignment: .leading, spacing: 20) {
          
          Text("Date: \(noteItem.timestamp.formatDate())")
            .font(.body)
            .padding(.bottom)
          
          VStack(alignment: .leading, spacing: 1) {
            Text("Note Record")
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
          Text(noteItem.content)
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
  }
}
