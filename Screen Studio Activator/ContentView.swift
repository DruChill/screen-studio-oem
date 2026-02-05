//
//  ContentView.swift
//  Screen Studio Activator
//
//  Created by Yuna on 5/02/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var statusMessage = "Esperando autenticación..."
    @State private var showIcon = false

    var body: some View {
        VStack(spacing: 20) {
            if isAuthenticated {
                // Contenido protegido de la app
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                    .transition(.scale)
                
                Text("Acceso Permitido")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("La aplicación se ha activado correctamente.")
                    .foregroundStyle(.secondary)
            } else {
                // Estado bloqueado / cargando
                Image(systemName: "lock.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.red)
                
                Text("Acceso Restringido")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(statusMessage)
                    .foregroundStyle(.secondary)
                
                Button("Intentar de nuevo") {
                    attemptAuth()
                }
                .padding(.top)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            // Ejecutamos la autenticación apenas se abre la ventana
            attemptAuth()
        }
    }

    func attemptAuth() {
        // Ejecutamos en un hilo secundario para no congelar la UI antes de que salga el diálogo
        DispatchQueue.global(qos: .userInitiated).async {
            let success = AuthorizationService.requestAdminPrivileges()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isAuthenticated = success
                    self.statusMessage = success ? "Autenticado" : "Contraseña incorrecta o cancelado."
                }
                
                // Si falla, podrías cerrar la app automáticamente si quieres:
                if !success {
                   // NSApplication.shared.terminate(nil) 
                }
            }
        }
    }
}

#Preview {
    ContentView()
}