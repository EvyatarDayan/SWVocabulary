//
//  SWVocabularyApp.swift
//  SWVocabulary
//
//  Created by EVYATAR DAYAN on 2026-01-23.
//

import SwiftUI

@main
struct SWVocabularyApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var showLogo = true
    
    var body: some Scene {
        WindowGroup {
            if showLogo {
                LogoView {
                    withAnimation {
                        showLogo = false
                    }
                }
                .preferredColorScheme(darkModeEnabled ? .dark : nil)
            } else {
                ContentView()
                    .preferredColorScheme(darkModeEnabled ? .dark : nil)
            }
        }
    }
}
