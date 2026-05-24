//
//  ContentView.swift
//  Screen Studio Activator
//
//  Created by kimYuna on 5/02/26.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Sparkle Updater
    @ObservedObject var updaterViewModel: UpdaterViewModel
    
    // MARK: - State
    @State private var activationState: ActivationState = .ready
    @State private var isProcessing = false
    @State private var iconBounce = false
    @State private var showContent = false
    
    enum ActivationState {
        case ready
        case processing
        case success
        case alreadyActive
        case cancelled
        case error(String)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra de título drag area
            Color.clear
                .frame(height: 8)
            
            VStack(spacing: 24) {
                heroSection
                detailsCard
                statusIndicator
                actionsSection
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .frame(width: 420)
        .fixedSize(horizontal: false, vertical: true)
        .background(.background)
        .onAppear {
            if AuthorizationService.checkIfAlreadyBlocked() {
                activationState = .alreadyActive
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 14) {
            // Icono principal con efecto de estado
            ZStack {
                // Glow sutil detrás del icono
                Circle()
                    .fill(stateAccentColor.opacity(0.08))
                    .frame(width: 80, height: 80)
                    .blur(radius: 12)
                
                Image(systemName: heroIcon)
                    .font(.system(size: 42, weight: .light))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(stateAccentColor)
                    .symbolEffect(.bounce, value: iconBounce)
            }
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                Text("Screen Studio")
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                
                Text("Activador de Licencia")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 8)
    }
    
    // MARK: - Details Card
    
    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Creador", value: "kimYuna", icon: "person.fill")
            
            Divider().padding(.leading, 40)
            
            DetailRow(label: "Tipo", value: "Licencia OEM", icon: "house.fill")
            
            Divider().padding(.leading, 40)
            
            DetailRow(label: "Compatible", value: "Screen Studio 3.6.0", icon: "app.badge.checkmark.fill")
            
            Divider().padding(.leading, 40)
            
            DetailRow(label: "Arquitectura", value: "Apple Silicon (M1 -M5)", icon: "cpu.fill")
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 12)
    }
    
    // MARK: - Status Indicator
    
    private var statusIndicator: some View {
        HStack(spacing: 8) {
            if isProcessing {
                ProgressView()
                    .controlSize(.small)
            } else {
                Circle()
                    .fill(statusDotColor)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .fill(statusDotColor.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isActiveState ? 1.8 : 1.0)
                            .opacity(isActiveState ? 0 : 1)
                            .animation(
                                isActiveState
                                    ? .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
                                    : .default,
                                value: isActiveState
                            )
                    )
            }
            
            Text(statusText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .opacity(showContent ? 1 : 0)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        HStack(spacing: 12) {
            // Botón Activate - estilo filled azul
            Button(action: performActivation) {
                HStack(spacing: 6) {
                    if isProcessing {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(primaryButtonTitle)
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 30)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .disabled(isProcessing)
            .controlSize(.large)
            
            // Botón Exit - estilo outlined
            Button(action: exitApp) {
                Text("Salir")
                    .font(.system(size: 13, weight: .regular))
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            // Botón Contact - estilo outlined
            Button(action: openHelp) {
                Text("Contacto")
                    .font(.system(size: 13, weight: .regular))
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 8)
    }
    
    // MARK: - Computed Properties
    
    private var heroIcon: String {
        switch activationState {
        case .ready, .processing:
            return "shield.lefthalf.filled"
        case .success, .alreadyActive:
            return "checkmark.shield.fill"
        case .cancelled:
            return "xmark.shield.fill"
        case .error:
            return "exclamationmark.shield.fill"
        }
    }
    
    private var stateAccentColor: Color {
        switch activationState {
        case .ready, .processing: return .accentColor
        case .success, .alreadyActive: return .green
        case .cancelled: return .orange
        case .error: return .red
        }
    }
    
    private var statusDotColor: Color {
        switch activationState {
        case .ready: return .secondary
        case .processing: return .accentColor
        case .success, .alreadyActive: return .green
        case .cancelled: return .orange
        case .error: return .red
        }
    }
    
    private var isActiveState: Bool {
        switch activationState {
        case .success, .alreadyActive: return true
        default: return false
        }
    }
    
    private var statusText: String {
        switch activationState {
        case .ready:
            return "Listo para activar"
        case .processing:
            return "Esperando autenticación…"
        case .success:
            return "Activado — dominios bloqueados"
        case .alreadyActive:
            return "Activo — licencia verificada"
        case .cancelled:
            return "Cancelado por el usuario"
        case .error(let msg):
            return msg
        }
    }
    
    private var primaryButtonTitle: String {
        switch activationState {
        case .processing: return "Autenticando…"
        case .success, .alreadyActive: return "Reactivar"
        default: return "Activate"
        }
    }
    

    
    // MARK: - Actions
    
    private func performActivation() {
        isProcessing = true
        activationState = .processing
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = AuthorizationService.activateHostsBlocking()
            
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    withAnimation(.easeInOut(duration: 0.4)) {
                        activationState = .success
                    }
                    iconBounce.toggle()
                case .cancelled:
                    withAnimation(.easeInOut(duration: 0.3)) {
                        activationState = .cancelled
                    }
                case .error(let message):
                    withAnimation(.easeInOut(duration: 0.3)) {
                        activationState = .error(message)
                    }
                }
            }
        }
    }
    
    private func openHelp() {
        if let url = URL(string: "https://www.drudev.me/contacto") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func exitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Detail Row Component

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .center)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView(updaterViewModel: UpdaterViewModel())
}
