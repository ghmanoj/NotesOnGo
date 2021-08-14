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
	@Environment(\.appAccentColor) var appAccentColor: Color
	
	@ObservedObject private var viewModel = ObjectUtils.settingsViewModel
	
	@State var apiInputActive = false
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			
			Toggle("Cmdr Mode", isOn: $viewModel.isCmdrMode)
				.onChange(of: viewModel.isCmdrMode) { value in
					logger.i("\(value)")
					viewModel.onCmdrModeToggle()
				}
				.font(.title2)
				.padding(.bottom)
			
			HStack {
				Button(action: {
					if !viewModel.isBackupInProgress {
						viewModel.onPerformBackup()
					} else {
						print("Backup already in progress. Ignoring this request..")
					}
				}) {
					Text("Backup")
						.frame(maxWidth: .infinity)
				}
				.padding(.vertical)
				.foregroundColor(.white)
				.background(viewModel.isBackupInProgress ? appAccentColor.opacity(0.5) : appAccentColor)
				
				.cornerRadius(10)
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.vertical)
			
			Spacer(minLength: 0)
			
			if viewModel.isBackupInProgress {
				BackupAnimationView(isInProgress: $viewModel.isBackupInProgress)
			} else if viewModel.isCmdrMode {
				VStack(alignment: .leading, spacing: 5) {
					HStack {
						HStack {
							TextField(
								"Add endpoint. Eg: 192.168.1.1",
								text: $viewModel.apiEndPointIp,
								onEditingChanged: { focused in
									if focused {
										withAnimation {
											apiInputActive = true
										}
									}
								})
								.disableAutocorrection(true)
								.autocapitalization(.none)
							
							if apiInputActive {
								Button(action: {
									withAnimation {
										apiInputActive = false
									}
									
									UIApplication.shared.endEditing() // Call to dismiss keyboard
								}) {
									Image(systemName: "multiply.circle.fill")
										.foregroundColor(.secondary)
								}
							}
						}
						.padding(10)
						.border(Color.secondary.opacity(0.1))
						
						Button(action: {
							viewModel.onSetApiEndPoint()
						}) {
							Text("Add")
						}
						.padding(.horizontal, 14)
						.padding(.vertical, 10)
						.foregroundColor(.white)
						.background(appAccentColor)
						.cornerRadius(8)
					}
					
					Text(viewModel.infoMessage)
						.font(.caption2)
						.foregroundColor(appAccentColor.opacity(0.8))
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
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			
			Spacer(minLength: 0)
		}
		.sheet(isPresented: $viewModel.isBackupSuccess) {
			BackupSuccessPresenter(activityItems: viewModel.filesToShare!)
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




// MARK: - Backup Animation View when backup button is pressed
struct BackupAnimationView: View {
	@Binding var isInProgress: Bool
	@State var viewShowing: Bool = false
	
	private var animatingGear: Animation {
		Animation.linear(duration: 1)
			.repeatForever(autoreverses: false)
	}
	
	var body: some View {
		VStack {
			Text("Backup in progress...")
				.font(.title2)
				.padding(.bottom)
			
			Image(systemName: "gear")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 80, height: 80)
				.rotationEffect(.degrees( (isInProgress && viewShowing) ? 360 : 0 ))
				.animation((isInProgress && viewShowing) ? animatingGear : .default)
				.onAppear {
					self.viewShowing = true
				}
				.onDisappear {
					self.viewShowing = false
				}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}
}
