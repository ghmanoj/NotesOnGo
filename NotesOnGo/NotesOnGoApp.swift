//
//  NotesOnGoApp.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

@main
struct NotesOnGoApp: App {
	let appAccentColor: Color = Color.red
	
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


//// https://developer.apple.com/forums/thread/658818
//// https://stackoverflow.com/questions/64015565/how-to-implement-a-color-scheme-switch-with-the-system-value-option
//public struct DarkModeViewModifier: ViewModifier {
//	@AppStorage("isDarkMode") var isDarkMode: Bool = true
//
//	public func body(content: Content) -> some View {
//
//		return content
//			.environment(\.colorScheme, isDarkMode ? .dark : .light)
//			.preferredColorScheme(isDarkMode ? .dark : .light)
//	}
//}
