//
//  Extensions.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

extension UIScreen {
	static let screenWidth = UIScreen.main.bounds.size.width
	static let screenHeight = UIScreen.main.bounds.size.height
}


// https://www.hackingwithswift.com/forums/swiftui/textfield-dismiss-keyboard-clear-button/240
// extension for keyboard to dismiss
extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}


extension View {
	// for light hepatic feedback when bottom bar buttons are tapped
	func generateHepaticFeedback(_ strength: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
		let generator = UIImpactFeedbackGenerator(style: strength)
		generator.impactOccurred()
	}
	
	func endEditing() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}


extension Date {
	func formatDate() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
		return dateFormatter.string(from: self)
	}
}
