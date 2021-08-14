//
//  NotesOnGoApp.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

@main
struct NotesOnGoApp: App {
	let appAccentColor: Color = Color("AccentColor")
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.appAccentColor, appAccentColor)
		}
	}
}

private struct AppAccentColorKey: EnvironmentKey {
	static let defaultValue = Color.red
}

extension EnvironmentValues {
	var appAccentColor: Color {
		get { self[AppAccentColorKey.self] }
		set { self[AppAccentColorKey.self] = newValue }
	}
}
