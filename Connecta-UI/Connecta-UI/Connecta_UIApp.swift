//
//  Connecta_UIApp.swift
//  Connecta-UI
//
//  Created by Nikhil on 08/01/26.
//

import SwiftUI


@main
struct Connecta_UIApp: App {
    @StateObject private var authVM = AuthViewModel() // 🔥
    var body: some Scene {
        WindowGroup {
            AppEntryView()
                .environmentObject(authVM) // inject environment object
            
        }
    }
}
