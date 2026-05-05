//
//  NubiApp.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 04/05/26.
//

import SwiftUI

@main
struct NubiAppApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.light) // La app está diseñada para modo claro
        }
    }
}
