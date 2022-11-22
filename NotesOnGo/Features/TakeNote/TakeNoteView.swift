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
      
      
      if viewModel.recordingType != .unknown {
        VStack(alignment: .leading, spacing: 10) {
          
          if viewModel.recordingType == .note && !viewModel.noteContent.isEmpty {
            
            VStack(spacing: 10) {
              Text("Recorded Note")
                .foregroundColor(.secondary)
                .font(.caption)
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
  
          } else if viewModel.recordingType == .command && viewModel.isCmdrResponse {
            VStack(spacing: 10) {
              Text("Response Message")
                .foregroundColor(.secondary)
                .font(.caption)
              Text(viewModel.cmdrResponseText)
                .font(.title3)
                .padding(.top, 20)
              
              Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 30)
          }
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
