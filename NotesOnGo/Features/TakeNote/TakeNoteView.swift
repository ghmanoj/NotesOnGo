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
	@Environment(\.appAccentColor) var appAccentColor
	
	@ObservedObject var viewModel = ObjectUtils.takeNoteViewModel
	
	private var foreverAnimation: Animation {
		Animation.linear(duration: 1)
			.repeatForever(autoreverses: true)
	}
	
	var body: some View {
		VStack(spacing: 15) {
			VStack(alignment: .leading) {
				HStack {
					Image(systemName: "megaphone")
						.rotationEffect(.degrees(-45))
					Text("Record [say content of the note here]")
				}
			}
			.padding(.vertical)
			.frame(maxWidth: .infinity)
			.font(.caption2)
			.foregroundColor(.secondary)
			
			VStack(alignment:.center, spacing: 10) {
				
				Text(viewModel.isRecording ? viewModel.liveRecordingUpdates : viewModel.infoMessage)
					.foregroundColor(viewModel.isRecording ? .primary : .secondary)
					.font(.callout)
					.frame(maxWidth: .infinity, alignment: .top)
					.frame(height: 110)
				
				Image(systemName: "mic.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.foregroundColor(viewModel.isRecording ? .green : appAccentColor)
					.frame(width: 80, height: 80)
					.scaleEffect(viewModel.isRecording ? 1.2 : 1)
					.animation(viewModel.isRecording ? foreverAnimation : .default)
					.onTapGesture {
						viewModel.onMicButtonPress()
					}
			}
			.frame(maxWidth: .infinity)
			
			Spacer(minLength: 0)
			
			if !viewModel.noteContent.isEmpty {
				VStack(alignment: .leading, spacing: 10) {
					
					VStack(spacing: 10) {
						Text("Note Recording")
							.foregroundColor(.secondary)
							.font(.caption2)
						Text(viewModel.noteContent)
							.font(.title3)
					}
					.frame(maxWidth: .infinity, alignment: .center)
					
					HStack(spacing: 40) {
						Button(action: {
							viewModel.onSaveNote()
							generateHepaticFeedback()
						}) {
							Text("Save")
						}
						
						Button(action: {
							viewModel.onDiscardNote()
							generateHepaticFeedback()
						}) {
							Text("Discard")
						}
					}
					.padding()
					.frame(maxWidth: .infinity)
				}
				.padding(.bottom)
			}
		}
		.onAppear {
			viewModel.fetchAppSettings()
		}
		.padding()
	}	
}


struct TakeNoteView_Previews: PreviewProvider {
	static var previews: some View {
		TakeNoteView()
	}
}
