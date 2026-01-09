//
//  AppEntryView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct AppEntryView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        if authVM.isLoggedIn {
            RootView()
        } else {
            LoginView()
        }
    }
}

