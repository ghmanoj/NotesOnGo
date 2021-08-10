//
//  SettingsView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
	private let logger = ObjectUtils.logger

	@ObservedObject private var viewModel = ObjectUtils.settingsViewModel
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			
			Toggle("Cmdr Mode", isOn: $viewModel.isCmdrMode)
				.onChange(of: viewModel.isCmdrMode) { value in
					logger.i("\(value)")
					viewModel.onCmdrModeToggle()
				}
				.font(.title2)
				.padding(.bottom)
						
			if viewModel.isCmdrMode {
				VStack(alignment: .leading, spacing: 5) {
					HStack {
						TextField("Add endpoint. Ex: 192.168.1.1", text: $viewModel.apiEndPointIp)
							.disableAutocorrection(true)
							.autocapitalization(.none)
							.padding(8)
							.border(Color.secondary.opacity(0.1))
						Button(action: {
							viewModel.onSetApiEndPoint()
						}) {
							Text("Add")
						}
						.padding(.horizontal, 14)
						.padding(.vertical, 8)
						.foregroundColor(.white)
						.background(Color.red)
						.cornerRadius(8)
					}
					
					Text(viewModel.infoMessage)
						.font(.caption2)
						.foregroundColor(.red.opacity(0.8))
						.frame(maxWidth: .infinity, alignment: .leading)
						.frame(height: 20)
						.padding(.bottom, 10)
											
					Divider()
					
					Text("Api endpoints")
						.font(.caption2)
						.foregroundColor(.secondary)
					
					List {
						ForEach(viewModel.apiEndPoints, id: \.uid) { item in
							Text("\(item.ip)")
						}
						.onDelete { indexSet in
							handleSwipe(indexSet)
						}
					}
					.frame(maxWidth: .infinity, maxHeight: 250, alignment: .leading)
				}
			}
			
			Spacer(minLength: 0)
		}
		.onAppear {
			viewModel.fetchAppSettings()
			viewModel.fetchApiEndPointData()
		}
		.padding()
		.frame(maxHeight: .infinity)
	}
	
	private func handleSwipe(_ indexSet: IndexSet) {
		for idx in indexSet {
			viewModel.onApiEndPointItemSwipe(idx)
		}
	}
	
}



struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
