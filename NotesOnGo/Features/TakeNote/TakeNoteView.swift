//
//  TakeNoteView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI
import Speech
import AVFoundation

struct TakeNoteView: View {
	
	@ObservedObject var viewModel = ObjectUtils.takeNoteViewModel
	
	var body: some View {
		VStack(spacing: 15) {
			
			VStack(alignment: .leading, spacing: 3) {
				HStack {
					Image(systemName: "megaphone")
						.rotationEffect(.degrees(-45))
					Text("Title [title of the note]")
				}
				HStack {
					Image(systemName: "megaphone")
						.rotationEffect(.degrees(-45))
					Text("Content [content of the note]")
				}
			}
			.font(.caption2)
			.foregroundColor(.secondary)
			
			VStack(spacing: 40) {
				Text(viewModel.errorMessage)
					.frame(height: 50)
				
				Image(systemName: "mic.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.foregroundColor(viewModel.isRecording ? .green : .red)
					.frame(height: 80)
					.onTapGesture {
						viewModel.onMicButtonPress()
					}
				
				Text(viewModel.liveRecordingUpdates)
					.font(.title3)
				
				HStack(alignment: .center) {
					if !viewModel.noteTitle.isEmpty
							&& !viewModel.noteContent.isEmpty {
						VStack(alignment: .trailing) {
							Text("Title")
							Text("Content")
						}
						.font(.callout)
						.foregroundColor(.secondary)
					}
					
					VStack(alignment: .leading) {
						Text(viewModel.noteTitle)
						Text(viewModel.noteContent)
					}
					.font(.title3)
					
					Spacer(minLength: 0)
					
					Group {
						if !viewModel.noteTitle.isEmpty && !viewModel.noteContent.isEmpty {
							Button(action: {
								viewModel.onSaveNote()
							}) {
								Text("Save")
							}
						}
					}
					.frame(width: 50, height: 50)
				}
			}
		}
		.padding()
	}	
}


struct TakeNoteView_Previews: PreviewProvider {
	static var previews: some View {
		TakeNoteView()
	}
}
