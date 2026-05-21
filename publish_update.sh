#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# Script de Publicación de Actualizaciones — Sparkle + GitHub Pages
# ═══════════════════════════════════════════════════════════════
#
# Uso:
#   ./publish_update.sh /ruta/al/App.app "1.1.0" "Descripción de cambios"
#
# Requisitos:
#   - Haber hecho build del proyecto en Xcode (para tener sign_update)
#   - Tener las claves EdDSA en el Keychain (generate_keys ya ejecutado)
#
# ═══════════════════════════════════════════════════════════════

APP_PATH="${1:?❌ Uso: ./publish_update.sh /ruta/App.app VERSION \"NOTAS\"}"
VERSION="${2:?❌ Falta la versión (ej: 1.1.0)}"
NOTES="${3:-Mejoras y correcciones}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCS_DIR="$SCRIPT_DIR/docs"
APP_NAME=$(basename "$APP_PATH" .app)
ZIP_NAME="${APP_NAME// /_}-${VERSION}.zip"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  📦 Publicación de Actualización v${VERSION}"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "  App:  $APP_PATH"
echo "  ZIP:  $ZIP_NAME"
echo "  Docs: $DOCS_DIR"
echo ""

# Verificar que la app existe
if [ ! -d "$APP_PATH" ]; then
    echo "❌ No se encontró la app en: $APP_PATH"
    exit 1
fi

# Crear directorio docs si no existe
mkdir -p "$DOCS_DIR"

# ─── 1. Crear el ZIP de la app ────────────────────────────────
echo "🗜️  Paso 1/4 — Creando archivo ZIP..."
cd "$(dirname "$APP_PATH")"
ditto -c -k --keepParent "$(basename "$APP_PATH")" "$DOCS_DIR/$ZIP_NAME"
echo "   ✅ ZIP creado: $DOCS_DIR/$ZIP_NAME"
echo ""

# ─── 2. Firmar el ZIP con EdDSA ──────────────────────────────
echo "🔐 Paso 2/4 — Firmando con EdDSA..."

# Buscar sign_update en DerivedData (se instala con Sparkle SPM)
SPARKLE_SIGN=$(find ~/Library/Developer/Xcode/DerivedData -name "sign_update" -type f 2>/dev/null | head -1)

if [ -z "$SPARKLE_SIGN" ]; then
    echo "❌ No se encontró sign_update."
    echo "   Asegúrate de haber hecho build del proyecto en Xcode con Sparkle."
    exit 1
fi

SIGNATURE_INFO=$("$SPARKLE_SIGN" "$DOCS_DIR/$ZIP_NAME")
echo "   Firma obtenida:"
echo "   $SIGNATURE_INFO"
echo ""

# Extraer los atributos de la firma
EDDSA_SIGNATURE=$(echo "$SIGNATURE_INFO" | grep -o 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)
FILE_LENGTH=$(echo "$SIGNATURE_INFO" | grep -o 'length="[^"]*"' | cut -d'"' -f2)

if [ -z "$EDDSA_SIGNATURE" ] || [ -z "$FILE_LENGTH" ]; then
    echo "❌ No se pudo extraer la firma o el tamaño del archivo."
    echo "   Salida de sign_update: $SIGNATURE_INFO"
    exit 1
fi

# ─── 3. Obtener info de la app ────────────────────────────────
echo "📋 Paso 3/4 — Obteniendo metadatos de la app..."

# Obtener el build number de la app
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$APP_PATH/Contents/Info.plist")
echo "   Build: $BUILD_NUMBER"
echo "   Versión: $VERSION"

# Generar la fecha en formato RFC 2822
PUB_DATE=$(date -R)
echo "   Fecha: $PUB_DATE"
echo ""

# ─── 4. Actualizar appcast.xml ────────────────────────────────
echo "📝 Paso 4/4 — Actualizando appcast.xml..."

APPCAST="$DOCS_DIR/appcast.xml"

if [ ! -f "$APPCAST" ]; then
    echo "❌ No existe $APPCAST"
    echo "   Ejecuta primero la configuración inicial."
    exit 1
fi

# Crear la entrada XML del item
ITEM=$(cat <<EOF
    <item>
      <title>Versión ${VERSION}</title>
      <description><![CDATA[<p>${NOTES}</p>]]></description>
      <pubDate>${PUB_DATE}</pubDate>
      <sparkle:version>${BUILD_NUMBER}</sparkle:version>
      <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.6</sparkle:minimumSystemVersion>
      <enclosure
        url="https://druchill.github.io/screen-studio-oem/${ZIP_NAME}"
        length="${FILE_LENGTH}"
        type="application/octet-stream"
        sparkle:edSignature="${EDDSA_SIGNATURE}"
      />
    </item>
EOF
)

# Insertar el item antes de </channel> usando perl (más robusto que sed con multiline)
perl -i -0pe "s|</channel>|${ITEM}\n  </channel>|" "$APPCAST"

echo "   ✅ appcast.xml actualizado"
echo ""

# ─── Resumen final ────────────────────────────────────────────
echo "╔══════════════════════════════════════════════════╗"
echo "║  ✅ ¡Publicación v${VERSION} lista!              "
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "  Archivos en docs/:"
ls -lh "$DOCS_DIR/"
echo ""
echo "  📌 Siguiente paso — commit y push a GitHub:"
echo ""
echo "    git add docs/"
echo "    git commit -m \"Release v${VERSION}\""
echo "    git push origin main"
echo ""
echo "  🌐 Una vez hecho push, la actualización estará disponible en:"
echo "    https://druchill.github.io/screen-studio-oem/appcast.xml"
echo ""
