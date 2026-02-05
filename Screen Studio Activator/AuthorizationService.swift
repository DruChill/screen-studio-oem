//
//  AuthorizationService.swift
//  Screen Studio Activator
//
//  Created by Yuna on 5/02/26.
//

import Foundation

/// Resultado de la operación de activación
enum ActivationResult {
    case success
    case cancelled
    case error(String)
}

/// Servicio que maneja la modificación del archivo /etc/hosts con privilegios de administrador
class AuthorizationService {
    
    /// Dominios que serán bloqueados redirigiendo a localhost
    static let blockedDomains = [
        "screen.studio",
        "api.lemonsqueezy.com", 
        "preview.screen.studio"
    ]
    
    /// Ejecuta la activación: modifica /etc/hosts y limpia la caché DNS
    /// Usa NSAppleScript con "administrator privileges" para mostrar el diálogo nativo de contraseña/TouchID
    static func activateHostsBlocking() -> ActivationResult {
        
        // 1. Construir las líneas que agregaremos al archivo hosts
        //    Formato: "127.0.0.1 dominio.com"
        let hostsLines = blockedDomains.map { "127.0.0.1 \($0)" }
        let hostsContent = hostsLines.joined(separator: "\\n")
        
        // 2. Construir el comando de shell que:
        //    a) Agrega las líneas al archivo /etc/hosts usando tee -a (append)
        //    b) Limpia la caché DNS con dscacheutil -flushcache
        //    c) Reinicia el servicio mDNSResponder para aplicar los cambios
        let shellCommand = """
        # Agregar entradas al archivo hosts
        echo '\(hostsContent)' | tee -a /etc/hosts > /dev/null
        
        # Limpiar caché DNS
        dscacheutil -flushcache
        killall -HUP mDNSResponder
        """
        
        // 3. Crear el AppleScript que ejecutará el comando con privilegios de administrador
        //    "with administrator privileges" hace que macOS muestre el diálogo nativo de autenticación
        let appleScriptSource = """
        do shell script "\(shellCommand)" with administrator privileges
        """
        
        // 4. Ejecutar el AppleScript
        var errorDict: NSDictionary?
        guard let appleScript = NSAppleScript(source: appleScriptSource) else {
            return .error("No se pudo crear el AppleScript")
        }
        
        // executeAndReturnError bloquea hasta que el usuario responde al diálogo
        appleScript.executeAndReturnError(&errorDict)
        
        // 5. Verificar resultado
        if let error = errorDict {
            let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Error desconocido"
            let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? 0
            
            // Error -128 significa que el usuario canceló el diálogo
            if errorNumber == -128 {
                return .cancelled
            }
            
            return .error(errorMessage)
        }
        
        return .success
    }
    
    /// Verifica si los dominios ya están bloqueados en /etc/hosts
    static func checkIfAlreadyBlocked() -> Bool {
        guard let hostsContent = try? String(contentsOfFile: "/etc/hosts", encoding: .utf8) else {
            return false
        }
        
        // Verificar si al menos uno de los dominios está presente
        return blockedDomains.contains { domain in
            hostsContent.contains(domain)
        }
    }
}