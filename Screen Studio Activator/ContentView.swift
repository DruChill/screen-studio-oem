//
//  ContentView.swift
//  Screen Studio Activator
//
//  Created by kimYuna on 5/02/26.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Estado de la UI
    @State private var activationState: ActivationState = .ready
    @State private var isProcessing = false
    
    enum ActivationState {
        case ready           // Listo para activar
        case processing      // Procesando (mostrando diálogo de contraseña)
        case success         // Activación exitosa
        case alreadyActive   // Ya estaba activado
        case cancelled       // Usuario canceló
        case error(String)   // Error con mensaje
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ═══════════════════════════════════════════════════════════════
            // HEADER - Título e icono principal
            // ═══════════════════════════════════════════════════════════════
            headerSection
            
            Divider()
                .padding(.horizontal)
            
            // ═══════════════════════════════════════════════════════════════
            // CONTENIDO PRINCIPAL - Info y estado
            // ═══════════════════════════════════════════════════════════════
            VStack(alignment: .leading, spacing: 16) {
                // Información de la app
                infoSection
                
                // Estado actual de la operación
                statusSection
            }
            .padding(20)
            
            Divider()
                .padding(.horizontal)
            
            // ═══════════════════════════════════════════════════════════════
            // FOOTER - Botones de acción
            // ═══════════════════════════════════════════════════════════════
            footerSection
        }
        .frame(width: 400)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            // Verificar si ya está activado al abrir
            if AuthorizationService.checkIfAlreadyBlocked() {
                activationState = .alreadyActive
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Logo de la app
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text("Screen Studio Activator")
                .font(.system(size: 18, weight: .bold))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Creador
            InfoRowSF(
                icon: "person.fill",
                iconColor: .blue,
                title: "Creado por",
                value: "kimYuna"
            )
            
            Divider().padding(.vertical, 8)
            
            // Tipo de activador
            InfoRowSF(
                icon: "house.fill",
                iconColor: .purple,
                title: "Tipo",
                value: "Activador Local"
            )
            
            Divider().padding(.vertical, 8)
            
            // Versión compatible
            InfoRowSF(
                icon: "app.badge.checkmark.fill",
                iconColor: .green,
                title: "Versión Compatible",
                value: "Screen Studio 3.5.2-4162"
            )
            
            Divider().padding(.vertical, 8)
            
            // Arquitectura
            InfoRowSF(
                icon: "cpu.fill",
                iconColor: .orange,
                title: "Arquitectura",
                value: "Apple Silicon (M1 - M4)"
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack(spacing: 10) {
            if isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
            }
            
            Text(statusMessage)
                .font(.system(size: 12))
                .foregroundStyle(statusColor)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(statusBackgroundColor)
        )
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 12) {
            // Botón principal de activación - Full width, prominente
            Button(action: performActivation) {
                HStack(spacing: 8) {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: activateButtonIcon)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(activateButtonTitle)
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
            }
            .buttonStyle(.borderedProminent)
            .tint(activateButtonColor)
            .disabled(isProcessing)
            
            // Botones secundarios
            HStack(spacing: 12) {
                // Botón de salir
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 12))
                        Text("Salir")
                            .font(.system(size: 13))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                }
                .buttonStyle(.bordered)
                
                // Botón de ayuda
                Button(action: openHelp) {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 12))
                        Text("Ayuda")
                            .font(.system(size: 13))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Computed Properties para UI
    
    private var stateIcon: String {
        switch activationState {
        case .ready, .processing: return "shield.lefthalf.filled"
        case .success, .alreadyActive: return "checkmark.shield.fill"
        case .cancelled: return "xmark.shield"
        case .error: return "exclamationmark.shield"
        }
    }
    
    private var stateIconColor: Color {
        switch activationState {
        case .ready, .processing: return .blue
        case .success, .alreadyActive: return .green
        case .cancelled: return .orange
        case .error: return .red
        }
    }
    
    private var statusIcon: String {
        switch activationState {
        case .ready: return "info.circle.fill"
        case .processing: return "hourglass"
        case .success: return "checkmark.circle.fill"
        case .alreadyActive: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
    
    private var statusColor: Color {
        switch activationState {
        case .ready, .processing: return .secondary
        case .success, .alreadyActive: return .green
        case .cancelled: return .orange
        case .error: return .red
        }
    }
    
    private var statusBackgroundColor: Color {
        switch activationState {
        case .ready, .processing: return Color.gray.opacity(0.1)
        case .success, .alreadyActive: return Color.green.opacity(0.1)
        case .cancelled: return Color.orange.opacity(0.1)
        case .error: return Color.red.opacity(0.1)
        }
    }
    
    private var statusMessage: String {
        switch activationState {
        case .ready:
            return "Listo. Pulsa 'Activar' para bloquear los dominios de licencia."
        case .processing:
            return "Esperando autenticación..."
        case .success:
            return "Activado correctamente. Dominios bloqueados y caché DNS limpiada."
        case .alreadyActive:
            return "Ya activado. Los dominios ya están bloqueados."
        case .cancelled:
            return "Operación cancelada por el usuario."
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    private var activateButtonTitle: String {
        switch activationState {
        case .processing: return "Procesando..."
        case .success, .alreadyActive: return "Reactivar"
        default: return "Activar Screen Studio"
        }
    }
    
    private var activateButtonIcon: String {
        switch activationState {
        case .success, .alreadyActive: return "arrow.clockwise"
        default: return "bolt.fill"
        }
    }
    
    private var activateButtonColor: Color {
        switch activationState {
        case .success, .alreadyActive: return .green
        default: return .blue
        }
    }
    
    // MARK: - Actions
    
    private func performActivation() {
        isProcessing = true
        activationState = .processing
        
        // Ejecutar en segundo plano para no bloquear la UI
        DispatchQueue.global(qos: .userInitiated).async {
            let result = AuthorizationService.activateHostsBlocking()
            
            // Actualizar UI en el hilo principal
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    withAnimation(.easeInOut(duration: 0.3)) {
                        activationState = .success
                    }
                case .cancelled:
                    withAnimation {
                        activationState = .cancelled
                    }
                case .error(let message):
                    withAnimation {
                        activationState = .error(message)
                    }
                }
            }
        }
    }
    
    private func openHelp() {
        if let url = URL(string: "https://github.com") {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Componente InfoRowSF con SF Symbols

struct InfoRowSF: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono con fondo circular
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            // Título
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            // Valor alineado a la derecha
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Componente WarningItem

struct WarningItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 10))
                .foregroundStyle(.orange.opacity(0.8))
            Text(text)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.leading, 4)
    }
}

#Preview {
    ContentView()
}
