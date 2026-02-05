//
//  ContentView.swift
//  Screen Studio Activator
//
//  Created by Yuna on 5/02/26.
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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Información de la app
                    infoSection
                    
                    // Lista de dominios que se bloquearán
                    domainsSection
                    
                    // Estado actual de la operación
                    statusSection
                }
                .padding(20)
            }
            
            Divider()
                .padding(.horizontal)
            
            // ═══════════════════════════════════════════════════════════════
            // FOOTER - Botones de acción
            // ═══════════════════════════════════════════════════════════════
            footerSection
        }
        .frame(width: 380, height: 480)
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
            
            Text("Bloquea las conexiones de verificación de licencia")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(icon: "🚀", title: "Modos Soportados", items: ["Normal Mode", "Beta Mode"])
            InfoRow(icon: "📊", title: "Versiones", items: ["2.x.x", "3.x.x"])
            InfoRow(icon: "💻", title: "Arquitecturas", items: ["Apple Silicon (ARM64)", "Intel (x86_64)"])
        }
    }
    
    // MARK: - Domains Section
    private var domainsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Dominios a bloquear:", systemImage: "network.slash")
                .font(.system(size: 13, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(AuthorizationService.blockedDomains, id: \.self) { domain in
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        Text("127.0.0.1 → \(domain)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.leading, 24)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.08))
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
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
        HStack(spacing: 12) {
            // Botón principal de activación
            Button(action: performActivation) {
                HStack(spacing: 6) {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 14, height: 14)
                    } else {
                        Image(systemName: "bolt.fill")
                    }
                    Text(activateButtonTitle)
                }
                .frame(width: 100)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(isProcessing)
            
            // Botón de salir
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("Salir")
                    .frame(width: 70)
            }
            .buttonStyle(.bordered)
            
            // Botón de contacto/ayuda
            Button(action: openHelp) {
                HStack(spacing: 4) {
                    Image(systemName: "questionmark.circle")
                    Text("Ayuda")
                }
                .frame(width: 80)
            }
            .buttonStyle(.bordered)
        }
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
            return "Listo. Pulsa 'Activar' para bloquear los dominios."
        case .processing:
            return "Esperando autenticación..."
        case .success:
            return "✓ Activado correctamente. Dominios bloqueados y caché DNS limpiada."
        case .alreadyActive:
            return "✓ Ya activado. Los dominios ya están bloqueados en /etc/hosts."
        case .cancelled:
            return "Operación cancelada por el usuario."
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    private var activateButtonTitle: String {
        switch activationState {
        case .processing: return "..."
        case .success, .alreadyActive: return "Reactivar"
        default: return "Activar"
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

// MARK: - Componente InfoRow reutilizable

struct InfoRow: View {
    let icon: String
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(icon)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            
            ForEach(items, id: \.self) { item in
                HStack(spacing: 6) {
                    Text("→")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                    Text(item)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 22)
            }
        }
    }
}

#Preview {
    ContentView()
}