//
//  ContentView.swift
//  NotesOnGo
//
//  Created by Manoj Ghimire on 8/3/21.
//

import SwiftUI
//import Lottie

struct ContentView: View {
  @State var layoutType: LayoutType = .takenote
  @State var title: String = "Take Note"
  @State var splashScreen = false
  
  var body: some View {
    if splashScreen {
      SplashScreen(show: $splashScreen)
    } else {
      VStack {
        TopBar(layoutType: $layoutType)
        
        switch layoutType {
        case .takenote:
          TakeNoteView()
        case .history:
          NoteHistoryView()
        case .settings:
          SettingsView()
        }
        
        Spacer(minLength: 0)
        
        BottomNavBar(layoutType: $layoutType)
      }
      .padding()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct SplashScreen: View {
  @Binding var show: Bool
  
  var body: some View {
    VStack {
      //			AnimatedView(show: $show)
      //				.frame(height: UIScreen.main.bounds.height / 2)
    }
  }
}

//struct AnimatedView: UIViewRepresentable {
//
//	@Binding var show: Bool
//
//	func makeUIView(context: Context) -> AnimationView {
//		let view = AnimationView(name: "splash", bundle: Bundle.main)
//
//		view.play { (status) in
//			if status {
//				withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8)) {
//					show.toggle()
//				}
//			}
//		}
//
//		return view
//	}
//
//	func updateUIView(_ uiView: AnimationView, context: Context) {
//
//	}
//}
