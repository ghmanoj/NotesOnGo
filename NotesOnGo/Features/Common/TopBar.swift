//
//  TopBar.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/4/21.
//

import SwiftUI

struct TopBar: View {
  @Binding var layoutType: LayoutType
  
  var body: some View {
    HStack {
      Text(getTitle())
        .font(.title)
        .fontWeight(.semibold)
      
      Spacer(minLength: 0)
    }
    .padding()
  }
  
  private func getTitle() -> String {
    var title = ""
    
    switch layoutType {
    case .history:
      title = "History"
    case .settings:
      title = "Settings"
    case .takenote:
      title = "Take Note"
    }
    
    return title
  }
}

struct TopBar_Previews: PreviewProvider {
  @State static var layoutType: LayoutType = .takenote
  
  static var previews: some View {
    TopBar(layoutType: $layoutType)
  }
}
