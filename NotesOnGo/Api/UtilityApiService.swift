//
//  UtilityApiService.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


class UtilityApiService {
	private static var apiEndPoint = "192.168.1.80"
	
	static func setApiEndPoint(_ ip: String) {
		apiEndPoint = ip
	}
	
	static func getCurrentApiEndPoint() -> String {
		return apiEndPoint
	}
	
	func performAction(actionType: UtilityActionType, completion: @escaping(Result<Data, NetworkError>) -> Void) {
		let apiUrl = "http://\(UtilityApiService.apiEndPoint):8081/" + actionTypeToEndPoint(action: actionType)

		guard let url = URL(string: apiUrl) else {
			completion(.failure(.badURL))
			return
		}

		URLSession.shared.dataTask(with: url) { data, response, error in
			if let data = data {
				completion(.success(data))
			} else if error != nil {
				completion(.failure(.requestFailed))
			} else {
				completion(.failure(.unknown))
			}
		}.resume()
	}
	
	private func actionTypeToEndPoint(action: UtilityActionType) -> String {
		switch action {
			case .logout:
				return "utility"
			case .screenlock:
				return "utility"
			case .status:
				return "uptime"
		}
	}
}
