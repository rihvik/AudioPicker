//
//  audioApp.swift
//  audio
//
//  Created by user2 on 29/02/24.
//

import SwiftUI
import Firebase

@main
struct audioApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
