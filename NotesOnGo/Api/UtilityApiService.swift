//
//  UtilityApiService.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


class UtilityApiService {
	
	func performAction(_ endpointIP: String, cmdMessage: CommandMessage, completion: @escaping(Result<Data, NetworkError>) -> Void) {
		let apiUrl = "http://\(endpointIP):8081/utilities_local"
		print("Performing tasks in \(apiUrl)")
		
		guard let url = URL(string: apiUrl) else {
			completion(.failure(.badURL))
			return
		}
		
		var jsonData: Data?
		
		do {
			let message = cmdMessage
			jsonData = try JSONSerialization.data(withJSONObject: message.getDict(), options: .prettyPrinted)
		} catch {
			print("Error \(error)")
			completion(.failure(.messageError))
			return
		}
		
		var request = URLRequest(url: url)
	
		//HTTP Headers
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.httpMethod = "POST"
		request.httpBody = jsonData

		URLSession.shared.dataTask(with: request) { data, response, error in
			if let data = data {
				completion(.success(data))
			} else if error != nil {
				completion(.failure(.requestFailed))
			} else {
				completion(.failure(.unknown))
			}
		}.resume()
	}
}
