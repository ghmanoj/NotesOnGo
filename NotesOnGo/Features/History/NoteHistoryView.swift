//
//  NoteHistoryView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

struct NoteHistoryView: View {
	@ObservedObject var viewModel = ObjectUtils.noteHistoryViewModel
	
	var body: some View {
		VStack {
			List {
				ForEach(viewModel.noteDataList, id: \.uid) { item in
					HStack(alignment: .center) {
						VStack(alignment: .leading) {
							Text(item.title)
								.font(.title3)
								.fontWeight(.medium)
							Text(item.content)
								.font(.body)
								.foregroundColor(.secondary)

						}
						Spacer(minLength: 0)
						Text("\(item.timestamp.formatDate())")
							.foregroundColor(.secondary)
							.font(.body)
					}
				}
			}
		}
		.padding()
		.onAppear {
			viewModel.onGetNotesHistory(0)
		}
	}
}

struct NoteHistoryView_Previews: PreviewProvider {
	static var previews: some View {
		NoteHistoryView()
	}
}
