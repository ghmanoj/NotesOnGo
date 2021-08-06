//
//  SettingsView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
	@AppStorage("isDarkMode") var isDarkMode: Bool = true
	
	@ObservedObject private var viewModel = ObjectUtils.settingsViewModel
	
	@State private var isDevCommand: Bool = false
	
	@State private var seperator = "\n"
	
	private let availableDevCommands = [
		"Command: utility, Modifier: logout",
		"Command: utility, Modifier: lock",
		"Command: system, Modifier: status",
	]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			
			Toggle("Dark Mode", isOn: $isDarkMode)
				.font(.title2)
			
			Toggle("Dev. Cmds", isOn: $isDevCommand)
				.font(.title2)

			Text(isDevCommand ? availableDevCommands.joined(separator: seperator) : "")
				.frame(minHeight: 20)
				.foregroundColor(.red.opacity(0.9))
				.font(.footnote)
			
			Spacer(minLength: 0)

			VStack(alignment: .leading, spacing: 10) {
				HStack(spacing: 10) {
					Text("Api End Point")
						.font(.caption)
						.foregroundColor(.secondary)
					
					TextField(viewModel.currentApiEndPoint, text: $viewModel.apiEndPoint)
						.padding(7)
						.background(Color.secondary.opacity(0.15))
						.cornerRadius(7)
					
					Button(action: {
						viewModel.onSetApiEndPoint()
					}) {
						Text("Set")
					}
				}
				Text(viewModel.notice)
					.foregroundColor(.red.opacity(0.5))
					.font(.footnote)
					.frame(height: 25)
			}
			.onAppear {
				viewModel.fetchLatest()
			}
		}
		.padding()
		.frame(maxHeight: .infinity)
	}
	
}



struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
