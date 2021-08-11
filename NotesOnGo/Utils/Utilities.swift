//
//  Utilities.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


let phonePattern = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#


let ipAddressPattern = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"

private let jsonDecoder = JSONDecoder()


func RunInUiThread(_ closure: @escaping () -> Void) {
	DispatchQueue.main.async { closure() }
}

func utilCmdResponseParser(_ data: Data) throws -> CommandResponse {
	let data = try jsonDecoder.decode(CommandResponse.self, from: data)
	return data
}
