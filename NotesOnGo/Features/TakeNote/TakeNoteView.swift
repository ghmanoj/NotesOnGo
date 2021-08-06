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
				
				VStack(alignment: .leading) {
					Text(viewModel.noteTitle)
					Text(viewModel.noteContent)
				}
				.font(.title3)
			}
		}
	}	
}


struct TakeNoteView_Previews: PreviewProvider {
	static var previews: some View {
		TakeNoteView()
	}
}
