//
//  SettingsViewModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


class SettingsViewModel: ObservableObject {
	
	@Published var apiEndPoint = ""
	@Published private(set) var notice = ""
	@Published private(set) var currentApiEndPoint = ""
	
	private let ipAddressCheck = NSPredicate(format: "SELF MATCHES[c] %@", ipAddressPattern)

	func onSetApiEndPoint() {
		notice = ""
		if apiEndPoint.isEmpty {
			notice = "Api end point is empty"
		} else {
			let isValid = ipAddressCheck.evaluate(with: apiEndPoint)
			if isValid {
				UtilityApiService.setApiEndPoint(apiEndPoint)
				apiEndPoint = ""
				notice = "Done"

				fetchLatest()
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self.notice = ""
				}
			} else {
				notice = "Api end point is not valid"
			}
		}
	}
	
	func fetchLatest() {
		currentApiEndPoint = UtilityApiService.getCurrentApiEndPoint()
	}
}
