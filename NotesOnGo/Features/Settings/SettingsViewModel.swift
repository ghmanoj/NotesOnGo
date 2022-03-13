//
//  SettingsViewModel.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import Foundation
import Combine
import SwiftUI


class SettingsViewModel: ObservableObject {
  
  @Published var isCmdrMode = false
  @Published var apiEndPointIp = ""
  
  @Published var isBackupInProgress = false
  @Published var isBackupSuccess = false
  
  private(set) var filesToShare: [Any]? = nil
  
  @Published private(set) var infoMessage = ""
  @Published private(set) var appSettings = AppSettingsData(isCmdrMode: false)
  @Published private(set) var apiEndPoints: [ApiEndPointData] = []
  
  private let backupUtils = BackupUtils()
  
  private var persistenceController = ObjectUtils.persistenceController
  
  private let ipAddressCheck = NSPredicate(format: "SELF MATCHES[c] %@", ipAddressPattern)
  
  func onSetApiEndPoint() {
    showErrorMessage("")
    
    if apiEndPointIp.isEmpty {
      showErrorMessage("Api end point is empty")
    } else {
      let isValid = ipAddressCheck.evaluate(with: apiEndPointIp)
      if isValid {
        // write to data base fetch updated list.. then done
        let data = ApiEndPointData(ip: apiEndPointIp)
        
        persistenceController.saveApiEndPoint(data: data) { result in
          switch result {
          case .success(_):
            RunInUiThread { self.apiEndPointIp = "" }
            
            self.fetchApiEndPointData()
            self.showErrorMessage("Done")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              self.showErrorMessage("")
            }
          case .failure(_):
            self.showErrorMessage("Failed to save")
          }
        }
      } else {
        showErrorMessage("Api end point is not valid")
      }
    }
  }
  
  func fetchApiEndPointData() {
    persistenceController.getApiEndPointData { result in
      switch result {
      case .success(let data):
        RunInUiThread { self.apiEndPoints = data }
      case .failure(_):
        print("Failed to fetch api endpoint data list")
      }
    }
  }
  
  func fetchAppSettings() {
    persistenceController.getAppSettings() { result in
      switch result {
      case .success(let settings):
        RunInUiThread {
          self.appSettings = settings
          self.isCmdrMode = settings.isCmdrMode
        }
      case .failure(_):
        print("Failed to fetch app settings")
      }
    }
  }
  
  func onApiEndPointItemSwipe(_ index: Int) {
    let swipedApiEndPoint = apiEndPoints[index]
    
    persistenceController.deleteApiEndPoint(swipedApiEndPoint) { result in
      switch result {
      case .success(_):
        self.fetchApiEndPointData()
      case .failure(let error):
        print("Error \(error)")
      }
    }
  }
  
  func onCmdrModeToggle() {
    let settings = AppSettingsData(isCmdrMode: isCmdrMode)
    
    persistenceController.saveAppSettings(appSettings: settings) { result in
      switch result {
      case .success(_):
        self.fetchAppSettings()
      case .failure(_):
        print("Failed to fetch app settings")
      }
    }
  }
  
  
  func onPerformBackup() {
    isBackupInProgress.toggle()
    
    persistenceController.getNoteData(0) { result in
      
      switch result {
      case .success(let data):
        self.backupUtils.performBackup(data, completion: self.handleBackupComplete)
      case .failure(_):
        print("Error")
        RunInUiThread {
          self.isBackupInProgress.toggle()
          self.isBackupSuccess = false
        }
      }
    }
  }
  
  private func handleBackupComplete(isSuccess: Bool, filesToShare: [Any]?) {
    self.filesToShare = filesToShare!
    RunInUiThread {
      self.isBackupSuccess = isSuccess
      self.isBackupInProgress.toggle()
    }
  }
  
  
  private func showErrorMessage(_ message: String) {
    RunInUiThread {
      self.infoMessage = message
      DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
        self.infoMessage = ""
      }
    }
  }
}
