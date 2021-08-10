//
//  SettingsView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
	
	@ObservedObject private var viewModel = ObjectUtils.settingsViewModel
	//
	//	@State private var isDevCommand: Bool = false
	//
	//	@State private var seperator = "\n"
	//
	//	private let availableDevCommands = [
	//		"Command: utility, Modifier: logout",
	//		"Command: utility, Modifier: lock",
	//		"Command: system, Modifier: status",
	//	]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			
			Toggle("Cmdr Mode", isOn: $viewModel.isCmdrMode)
				.onChange(of: viewModel.isCmdrMode) { value in
					viewModel.onCmdrModeToggle()
				}
				.font(.title2)
			
			Spacer(minLength: 0)
			
			if viewModel.isCmdrMode {
				VStack(alignment: .leading, spacing: 5) {
					HStack {
						TextField("Ex: 192.168.1.1", text: $viewModel.apiEndPointIp)
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
						.foregroundColor(.red)
						.frame(maxWidth: .infinity, alignment: .leading)
						.frame(height: 20)
						.padding(.bottom, 10)
											
					Divider()
					
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
