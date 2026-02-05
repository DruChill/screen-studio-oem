//
//  AuthorizationService.swift
//  Screen Studio Activator
//
//  Created by Yuna on 5/02/26.
//

import Foundation
import Security

class AuthorizationService {
    
    // Esta función solicita permisos de administrador y devuelve true si el usuario puso la contraseña correcta
    static func requestAdminPrivileges() -> Bool {
        var authRef: AuthorizationRef?
        var osStatus = AuthorizationCreate(nil, nil, [], &authRef)
        
        guard osStatus == errAuthorizationSuccess else {
            print("Error al crear la referencia de autorización: \(osStatus)")
            return false
        }
        
        // Definimos el derecho que queremos solicitar. 
        // "system.privilege.admin" es el estándar para pedir permisos de root/admin (el candado).
        var authItem = AuthorizationItem(name: kAuthorizationRightExecute, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        
        // Flags:
        // - InteractionAllowed: Permite que el sistema muestre la ventana de diálogo (GUI).
        // - ExtendRights: Solicita los derechos si no los tenemos ya.
        // - PreAuthorize: Pre-autoriza los derechos.
        let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
        
        // Esta es la llamada que bloquea y muestra la ventana hasta que el usuario responde
        osStatus = AuthorizationCopyRights(authRef!, &authRights, nil, flags, nil)
        
        if osStatus == errAuthorizationSuccess {
            print("¡Autenticación exitosa!")
            return true
        } else {
            print("Autenticación fallida o cancelada por el usuario. Código: \(osStatus)")
            return false
        }
    }
}