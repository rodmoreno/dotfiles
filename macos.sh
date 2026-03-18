#!/usr/bin/env bash
# macos.sh — Preferencias del sistema macOS
# Aplica configuraciones via defaults write. Re-ejecutable de forma independiente.
# Uso: bash macos.sh

set -e

###############################################
# Colores para output
###############################################
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}→ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }

info "Aplicando configuraciones del sistema macOS..."

###############################################
# General UI/UX
###############################################

# Deshabilita el ícono de Spotlight en el menú bar quitándole permisos de ejecución.
# Raycast toma su lugar como launcher principal (Cmd+Space).
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search 2>/dev/null || true

# En la pantalla de login, al hacer click en el reloj muestra el hostname,
# versión de macOS e IP — útil para identificar la máquina rápidamente.
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Fuerza la búsqueda de actualizaciones de software diariamente.
# Por defecto macOS solo revisa una vez por semana.
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Limpia entradas duplicadas del menú contextual "Abrir con".
# Los duplicados aparecen cuando mueves o reinstalaas apps y macOS
# no limpia el registro de LaunchServices automáticamente.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user 2>/dev/null || true

# Evita que la app Photos se abra automáticamente al conectar
# un iPhone, cámara u otro dispositivo con fotos.
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Expande el panel de "Guardar como" por defecto mostrando todas las opciones
# (ubicación, tags, etc.) en lugar del panel colapsado que solo muestra el nombre.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expande el panel de impresión por defecto mostrando todas las opciones
# (orientación, copias, color, etc.) en lugar del panel simplificado.
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Desactiva el diálogo "¿Estás seguro de que quieres abrir esta app?"
# que aparece en apps descargadas de internet. En una máquina de desarrollo
# donde instalas herramientas constantemente, este warning es innecesario.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Reduce la duración de la animación al redimensionar ventanas a casi cero.
# Hace que el sistema se sienta más rápido y responsivo.
defaults write -g NSWindowResizeTime -float 0.001

###############################################
# Trackpad
###############################################

# Activa "tap to click" — un toque ligero equivale a un click.
# Evita tener que presionar físicamente el trackpad todo el tiempo.
# Se aplica tanto al trackpad integrado como a los externos por Bluetooth.
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Velocidad de seguimiento del cursor al máximo (escala 0–3).
# Tarda un día acostumbrarse pero luego no puedes volver atrás.
defaults write -g com.apple.trackpad.scaling -float 3.0

###############################################
# Teclado
###############################################

# Velocidad de repetición de tecla al mínimo posible (valor 1).
# El slider de System Settings no llega a este valor — solo vía terminal.
# Crítico para editar código: moverse por el texto con flechas es mucho más fluido.
defaults write -g KeyRepeat -int 1

# Delay antes de que empiece la repetición al mantener una tecla presionada (valor 10).
# Un valor bajo significa que la repetición empieza casi de inmediato.
defaults write -g InitialKeyRepeat -int 10

# Desactiva la corrección ortográfica automática.
# En terminal y editores de código cambia palabras técnicas por otras incorrectas.
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# Desactiva la capitalización automática de la primera letra tras un punto.
# Problemática al escribir en terminal o en contextos donde el caso importa.
defaults write -g NSAutomaticCapitalizationEnabled -bool false

# Desactiva la inserción automática de un punto al hacer doble espacio.
# Útil en prosa pero interfiere al escribir código o comandos.
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false

# Desactiva la sustitución de comillas rectas (" ") por tipográficas (" ").
# Las comillas tipográficas rompen código, JSON, YAML y cualquier string literal.
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# Desactiva la sustitución de guiones dobles (--) por em dash (—).
# Igual que las comillas, rompe flags de CLI y expresiones de código.
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

###############################################
# Dock
###############################################

# Posiciona el Dock en el lado izquierdo de la pantalla.
# Recupera espacio vertical, que es más valioso en pantallas widescreen.
defaults write com.apple.dock orientation -string "left"

# Tamaño de los íconos del Dock en 36px — funcional sin ocupar demasiado espacio.
defaults write com.apple.dock tilesize -int 36

# Oculta el Dock automáticamente cuando no está en uso.
# Maximiza el espacio de trabajo disponible.
defaults write com.apple.dock autohide -bool true

# Elimina el delay antes de que el Dock aparezca al acercar el cursor.
# Por defecto hay ~0.5s de espera que resulta frustrante.
defaults write com.apple.dock autohide-delay -float 0

# Reduce la duración de la animación de aparición del Dock a 0.2s.
# Suficientemente rápido para sentirse instantáneo.
defaults write com.apple.dock autohide-time-modifier -float 0.2

# Desactiva la animación de "rebote" al abrir una app desde el Dock.
# Hace que la apertura de apps se sienta más directa.
defaults write com.apple.dock launchanim -bool false

# Elimina la sección de "Apps recientes" al final del Dock.
# Mantiene el Dock limpio con solo las apps que tú has fijado.
defaults write com.apple.dock show-recents -bool false

# Evita que macOS reordene los Spaces automáticamente según uso reciente.
# Si tienes Spaces fijos por app (terminal, browser, etc.) esto los mantiene en orden.
defaults write com.apple.dock mru-spaces -bool false

# Cada monitor tiene su propio conjunto de Spaces independiente.
# Sin esto, todos los monitores comparten el mismo Space activo.
defaults write com.apple.spaces spans-displays -bool false

killall Dock

###############################################
# Finder
###############################################

# Muestra archivos y carpetas ocultos (los que empiezan con punto, como .zshrc, .env).
# También accesible con Cmd+Shift+. pero esto lo hace permanente.
defaults write com.apple.finder AppleShowAllFiles -bool true

# Muestra siempre la extensión de los archivos (.js, .ts, .json, etc.).
# Sin esto macOS oculta extensiones conocidas lo que puede causar confusión.
defaults write -g AppleShowAllExtensions -bool true

# Muestra la barra de ruta (path bar) en la parte inferior del Finder.
# Indica la ruta completa del directorio actual y permite navegar haciendo click.
defaults write com.apple.finder ShowPathbar -bool true

# Muestra la barra de estado en la parte inferior del Finder.
# Indica cuántos ítems hay en la carpeta y el espacio disponible en disco.
defaults write com.apple.finder ShowStatusBar -bool true

# Vista por defecto: lista (Nlsv) — la más eficiente para navegar proyectos.
# Alternativas: icnv (íconos), clmv (columnas), glyv (galería).
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Las nuevas ventanas del Finder abren en el directorio home ($HOME)
# en lugar de la ubicación genérica "Recientes".
defaults write com.apple.finder NewWindowTarget -string "PFHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Al buscar en Finder, busca dentro de la carpeta actual por defecto.
# Sin esto busca en todo el Mac, que raramente es lo que quieres.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Elimina el diálogo de confirmación al cambiar la extensión de un archivo.
# El warning es redundante si ya sabes lo que estás haciendo.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Elimina el diálogo de confirmación al vaciar la papelera.
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Evita que macOS cree archivos .DS_Store en volúmenes de red (NAS, SMB, etc.).
# Los .DS_Store en red pueden aparecer en repos git de otros y son molestos.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Activa el snap-to-grid para íconos en el escritorio y vistas de íconos.
# Los íconos se alinean automáticamente a una grilla invisible al moverlos.
/usr/libexec/PlistBuddy -c \
  "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" \
  ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c \
  "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" \
  ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c \
  "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" \
  ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true

killall Finder 2>/dev/null || true

###############################################
# Safari
###############################################

# Desactiva el envío de las búsquedas a Apple para sugerencias.
# Por privacidad: lo que escribes en la barra de direcciones no sale de tu Mac.
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

###############################################
# Screenshots
###############################################

# Guarda los screenshots en una carpeta dedicada en lugar del escritorio.
# Evita que el escritorio se llene de capturas de pantalla.
mkdir -p ~/Pictures/Screenshots
defaults write com.apple.screencapture location -string "~/Pictures/Screenshots"

# Elimina la sombra que macOS añade alrededor de las ventanas en los screenshots.
# Produce imágenes más limpias, especialmente para documentación.
defaults write com.apple.screencapture disable-shadow -bool true

# Formato PNG para los screenshots — mejor calidad que JPG para capturas de UI.
defaults write com.apple.screencapture type -string "png"

###############################################
# Menú bar
###############################################

# Muestra el porcentaje de batería junto al ícono en el menú bar.
# Más informativo que solo el ícono gráfico.
defaults write com.apple.menuextra.battery ShowPercent -bool true

# Formato del reloj: día de semana, día del mes, mes y hora en 24h.
# Ejemplo: "Mar 24 Feb 15:30"
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM HH:mm"

###############################################
# Spotlight
###############################################

# Excluye ~/projects del índice de Spotlight.
# Sin esto, Spotlight indexa node_modules, dist, .git y miles de archivos
# generados que no tienen valor de búsqueda y ralentizan la indexación.
mkdir -p ~/projects
sudo mdutil -i off ~/projects 2>/dev/null || true

# Evita que Spotlight indexe volúmenes externos automáticamente
# (discos duros, USBs, etc.) al conectarlos.
sudo defaults write /Library/Preferences/com.apple.SpotlightServer \
  ExternalVolumesIgnore -bool true

###############################################
# Seguridad
###############################################

# Activa el Firewall de aplicaciones de macOS.
# Bloquea conexiones entrantes no autorizadas a aplicaciones específicas.
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

success "Configuraciones del sistema aplicadas OK"
