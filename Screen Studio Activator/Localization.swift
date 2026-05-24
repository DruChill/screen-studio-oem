//
//  Localization.swift
//  Screen Studio Activator
//
//  Created by kimYuna on 5/24/26.
//

import Foundation

// MARK: - Language Detection

enum AppLanguage {
    case english
    case spanish
    
    /// Detects the system language. Defaults to English for all languages except Spanish.
    static var current: AppLanguage {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        if preferredLanguage.hasPrefix("es") {
            return .spanish
        }
        return .english
    }
}

// MARK: - Localized Strings

/// All user-facing strings, localized based on system language.
/// English is the default; Spanish is used only when the Mac is set to Spanish.
enum L10n {
    private static let lang = AppLanguage.current
    
    // MARK: Hero Section
    
    static var appSubtitle: String {
        lang == .spanish ? "Activador de Licencia" : "License Activator"
    }
    
    // MARK: Details Card
    
    static var creator: String {
        lang == .spanish ? "Creador" : "Creator"
    }
    
    static var type: String {
        lang == .spanish ? "Tipo" : "Type"
    }
    
    static var oemLicense: String {
        lang == .spanish ? "Licencia OEM" : "OEM License"
    }
    
    static var compatible: String {
        lang == .spanish ? "Compatible" : "Compatible"
    }
    
    static var architecture: String {
        lang == .spanish ? "Arquitectura" : "Architecture"
    }
    
    // MARK: Status
    
    static var readyToActivate: String {
        lang == .spanish ? "Listo para activar" : "Ready to activate"
    }
    
    static var waitingAuthentication: String {
        lang == .spanish ? "Esperando autenticación…" : "Waiting for authentication…"
    }
    
    static var activatedDomainsBlocked: String {
        lang == .spanish ? "Activado — dominios bloqueados" : "Activated — domains blocked"
    }
    
    static var activeLicenseVerified: String {
        lang == .spanish ? "Activo — licencia verificada" : "Active — license verified"
    }
    
    static var cancelledByUser: String {
        lang == .spanish ? "Cancelado por el usuario" : "Cancelled by user"
    }
    
    // MARK: Buttons
    
    static var activate: String {
        lang == .spanish ? "Activar" : "Activate"
    }
    
    static var authenticating: String {
        lang == .spanish ? "Autenticando…" : "Authenticating…"
    }
    
    static var reactivate: String {
        lang == .spanish ? "Reactivar" : "Reactivate"
    }
    
    static var exit: String {
        "Exit"
    }
    
    static var contact: String {
        lang == .spanish ? "Contacto" : "Contact"
    }
    
    // MARK: Details Card (continued)
    
    static var lastUpdate: String {
        lang == .spanish ? "Última Actualización" : "Last Update"
    }
    
    static var lastUpdateDate: String {
        lang == .spanish ? "Mayo 24, 2026" : "May 24, 2026"
    }
    
    // MARK: Menu
    
    static var checkForUpdates: String {
        lang == .spanish ? "Buscar Actualizaciones…" : "Check for Updates…"
    }
}
