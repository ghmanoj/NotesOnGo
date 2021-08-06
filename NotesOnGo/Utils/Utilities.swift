//
//  Utilities.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation


let phonePattern = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#


let ipAddressPattern = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"



func RunInUiThread(_ closure: @escaping () -> Void) {
	DispatchQueue.main.async { closure() }
}
