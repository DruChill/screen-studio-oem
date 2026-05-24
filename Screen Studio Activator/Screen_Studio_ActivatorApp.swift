//
//  Screen_Studio_ActivatorApp.swift
//  Screen Studio Activator
//
//  Created by Yuna on 5/02/26.
//

import SwiftUI
import Sparkle
import Combine
import AppKit

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

// MARK: - AppDelegate for Window Configuration

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureMainWindow()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        configureMainWindow()
    }
    
    private func configureMainWindow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let window = NSApplication.shared.windows.first else { return }
            
            // Always on top
            window.level = .floating
            
            // Remove standard window buttons (close, minimize, zoom)
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // Prevent closing via Cmd+W
            window.styleMask.remove(.closable)
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.resizable)
            
            // Center the window
            window.center()
        }
    }
}

@main
struct Screen_Studio_ActivatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
                Button(L10n.checkForUpdates) {
                    updaterViewModel.checkForUpdates()
                }
                .disabled(!updaterViewModel.canCheckForUpdates)
            }
        }
    }
}
