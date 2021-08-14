//
//  BackupSuccessPresenter.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/13/21.
//

import Foundation
import UIKit
import SwiftUI


struct BackupSuccessPresenter: UIViewControllerRepresentable {
	var activityItems: [Any]
	var applicationActivities: [UIActivity]? = nil
	
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<BackupSuccessPresenter>) -> UIActivityViewController {
		let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<BackupSuccessPresenter>) {
	}
}
