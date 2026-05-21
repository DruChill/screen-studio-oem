//
//  Screen_Studio_ActivatorApp.swift
//  Screen Studio Activator
//
//  Created by Yuna on 5/02/26.
//

import SwiftUI
import Sparkle
import Combine

// MARK: - Sparkle Update ViewModel

/// Gestiona el controlador de actualizaciones de Sparkle
final class UpdaterViewModel: ObservableObject {
    let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    
    init() {
        // startingUpdater: true = comienza a buscar actualizaciones automáticamente
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        // Observar cambios en canCheckForUpdates
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

// MARK: - App Entry Point

@main
struct Screen_Studio_ActivatorApp: App {
    @StateObject private var updaterViewModel = UpdaterViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(updaterViewModel: updaterViewModel)
        }
        // Oculta la barra de título para un look más limpio de "utility app"
        .windowStyle(.hiddenTitleBar)
        // Tamaño fijo, no redimensionable
        .windowResizability(.contentSize)
        .commands {
            // Agregar "Buscar Actualizaciones..." en el menú de la app
            CommandGroup(after: .appInfo) {
                Button("Buscar Actualizaciones...") {
                    updaterViewModel.checkForUpdates()
                }
                .disabled(!updaterViewModel.canCheckForUpdates)
            }
        }
    }
}
