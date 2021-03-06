//
//  BottomNavBar.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI

// MARK: - Bottom Bar Button
struct NavButton: View {
  @Environment(\.appAccentColor) var appAccentColor
  @State var animate: Bool = false
  
  let image: String
  let label: String
  let type: LayoutType
  
  @Binding var layoutType: LayoutType
  
  var body: some View {
    
    Button(action: {
      layoutType = type
    }) {
      VStack {
        Image(systemName: image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
          .font(.title)
          .foregroundColor((layoutType == type) ? .primary : .secondary)
        
        Text(label)
          .font(.callout)
          .foregroundColor((layoutType == type) ? .primary : .secondary)
      }
    }
  }
}

// MARK: - Bottom Navigation Bar
struct BottomNavBar: View {
  @Binding var layoutType: LayoutType
  
  var body: some View {
    HStack(spacing: 40) {
      
      NavButton(image: "note.text", label: "Take Note", type: .takenote, layoutType: $layoutType)
      
      NavButton(image: "clock.arrow.circlepath", label: "History", type: .history, layoutType: $layoutType)
      
      NavButton(image: "gear", label: "Settings", type: .settings, layoutType: $layoutType)
    }
    .padding([.horizontal, .top])
  }
}
