//
//  ContentView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

struct ContentView: View {
	@State var layoutType: LayoutType = .takenote
	@State var title: String = "Take Note"
	
	var body: some View {
		VStack {
			TopBar(layoutType: $layoutType)
			
			switch layoutType {
				case .takenote:
					TakeNoteView()
				case .history:
					NoteHistoryView()
				case .settings:
					SettingsView()
			}
			
			Spacer(minLength: 0)
			
			BottomNavBar(layoutType: $layoutType)
		}
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
