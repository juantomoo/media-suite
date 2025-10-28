# Media Suite - Lidarr con Conversor APE+CUE Automático

Este stack de Docker Compose incluye Lidarr, qBittorrent, Prowlarr, FlareSolverr y un conversor automático de archivos APE+CUE a FLAC para resolver el problema de que los indexers solo encuentren resultados en formato APE.

## 🎯 Características

- **Lidarr**: Gestión de música con descarga automática
- **qBittorrent**: Cliente de torrents
- **Prowlarr**: Gestor de indexers
- **FlareSolverr**: Resolvedor de CloudFlare para indexers protegidos
- **APE-CUE Splitter**: Conversor automático de APE+CUE a FLAC con etiquetas
- **Navidrome**: Servidor de música para streaming
- **Filebrowser**: Gestor de archivos web para subir música manualmente

## 📁 Estructura de Volúmenes

El stack utiliza los siguientes volúmenes para mantener compatibilidad con instalaciones existentes:

```
/srv/media:/data                    # Música y descargas compartidas
/opt/lidarr/config:/config          # Configuración de Lidarr
/opt/qbittorrent/config:/config     # Configuración de qBittorrent
/opt/prowlarr/config:/config        # Configuración de Prowlarr
```

## 🚀 Instalación desde GitHub (Recomendado)

### Opción 1: Portainer (Sin terminal)

1. **Abrir Portainer** → Stacks → Add Stack
2. **Seleccionar pestaña "Repository"**
3. **Completar campos:**
   - **Repository URL**: `https://github.com/juantomoo/media-suite.git`
   - **Repository reference**: `main`
   - **Compose path**: `docker-compose.yaml`
   - **Marcar "Automatic updates"** (opcional, para auto-sincronizar cambios)
4. **Hacer clic en "Deploy the stack"**

Portainer automáticamente:
- Clona el repositorio
- Construye la imagen `ape-cue-splitter`
- Crea todos los contenedores
- Configura la red y volúmenes compartidos

### Opción 2: Terminal (Si tienes acceso)

```bash
# Clonar el repositorio
git clone https://github.com/juantomoo/media-suite.git
cd media-suite

# Construir y levantar el stack
docker compose up -d --build
```

## 🔧 Configuración del Conversor APE+CUE

El conversor automático tiene las siguientes opciones configurables en el `docker-compose.yaml`:

```yaml
environment:
  - WATCH_DIR=/data/downloads        # Directorio a monitorear
  - OUTPUT_MODE=sidecar             # Modo de salida: sidecar o in_place
  - DELETE_SOURCE=false             # Borrar archivos fuente tras conversión
```

### Modos de Salida

- **`sidecar`** (por defecto): Crea carpeta `_split_flac` junto a los archivos fuente
- **`in_place`**: Reemplaza los archivos fuente con los FLAC convertidos

### Control de Archivos Fuente

- **`DELETE_SOURCE=false`** (por defecto): Mantiene archivos APE+CUE originales
- **`DELETE_SOURCE=true`**: Borra archivos fuente tras conversión exitosa

## 📋 Configuración de Servicios

### Puertos Utilizados

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Lidarr | 8686 | Interfaz web |
| qBittorrent | 8687 | Interfaz web |
| Prowlarr | 8688 | Interfaz web |
| FlareSolverr | 8690 | API interna |
| Navidrome | 8691 | Servidor de música |
| Filebrowser | 8692 | Gestor de archivos web |

### Configuración de Lidarr

1. **Acceder a Lidarr**: `http://tu-servidor:8686`
2. **Configurar Completed Download Handling**:
   - Habilitar "Completed Download Handling"
   - Directorio de música: `/data/Musics`
   - Directorio de descargas: `/data/downloads`
3. **No necesitas Remote Path Mapping** (todos comparten `/srv/media`)

### Configuración de Filebrowser

1. **Acceder a Filebrowser**: `http://tu-servidor:8692`
2. **Primera configuración**:
   - Usuario por defecto: `admin`
   - Contraseña por defecto: `admin`
   - **Cambiar inmediatamente** la contraseña
3. **Funcionalidades**:
   - Subir archivos APE+CUE directamente a `/srv/media/downloads`
   - El conversor automático los procesará
   - Navegar por toda la estructura de música
   - Gestión de archivos desde cualquier navegador

## 🔄 Migración desde Instalación Existente

### Si ya tienes Lidarr funcionando:

1. **Detener el stack anterior** (si existe)
2. **Verificar que los volúmenes existan**:
   ```bash
   # En el servidor (si tienes acceso)
   ls -la /srv/media/
   ls -la /opt/lidarr/config/
   ls -la /opt/qbittorrent/config/
   ls -la /opt/prowlarr/config/
   ```
3. **Desplegar el nuevo stack** usando Portainer
4. **Verificar que Lidarr mantenga**:
   - Usuarios y configuraciones
   - Indexers configurados
   - Biblioteca de música existente

### Si es una instalación limpia:

El servicio `init-media` creará automáticamente:
- `/srv/media/Musics`
- `/srv/media/downloads/torrents`
- `/srv/media/downloads/usenet`
- Permisos correctos (1000:1000)

## 🔍 Cómo Funciona el Conversor

1. **Monitoreo**: Observa `/data/downloads` en busca de archivos `.cue`
2. **Detección**: Cuando encuentra `.cue` + `.ape`:
   - Usa `shnsplit` para dividir el APE según el CUE
   - Genera archivos FLAC individuales
   - Aplica etiquetas usando `cuetag`
3. **Marcado**: Crea archivo `.converted` para evitar reprocesamiento
4. **Salida**: Por defecto en carpeta `_split_flac` junto al archivo fuente

### Ejemplo de Conversión

```
Descarga original:
/data/downloads/Album - Artista/
├── Album - Artista.ape
├── Album - Artista.cue
└── Album - Artista.cue.converted

Después de conversión:
/data/downloads/Album - Artista/
├── Album - Artista.ape
├── Album - Artista.cue
├── Album - Artista.cue.converted
└── _split_flac/
    ├── 01 - Track 1.flac
    ├── 02 - Track 2.flac
    └── ...
```

## 🛠️ Mantenimiento y Troubleshooting

### Verificar Estado del Conversor

```bash
# Ver logs del conversor
docker logs ape-cue-splitter

# Verificar que esté corriendo
docker ps | grep ape-cue-splitter
```

### Problemas Comunes

1. **No convierte archivos**:
   - Verificar que `.cue` y `.ape` estén en la misma carpeta
   - Revisar logs: `docker logs ape-cue-splitter`
   - Verificar permisos en `/srv/media`

2. **Lidarr no importa FLAC**:
   - Verificar configuración de "Completed Download Handling"
   - Asegurar que el directorio de música sea `/data/Musics`

3. **Archivos duplicados**:
   - El conversor evita reprocesar archivos con marcador `.converted`
   - Para reprocesar, borrar el marcador: `rm archivo.cue.converted`

### Actualizar el Stack

Si tienes "Automatic updates" habilitado en Portainer:
- Los cambios en GitHub se sincronizan automáticamente

Si no:
1. **Stacks** → Seleccionar tu stack
2. **Editor** → **Pull and redeploy**

## 📝 Personalización Avanzada

### Cambiar Directorio de Monitoreo

Editar en `docker-compose.yaml`:
```yaml
environment:
  - WATCH_DIR=/data/downloads/torrents  # Cambiar directorio
```

### Modificar Comportamiento del Conversor

Editar variables en `docker-compose.yaml`:
```yaml
environment:
  - OUTPUT_MODE=in_place      # Reemplazar archivos fuente
  - DELETE_SOURCE=true        # Borrar APE+CUE tras conversión
```

## 🔒 Seguridad

- Todos los servicios corren con usuario no-root (PUID=1000, PGID=1000)
- Red interna `media` para comunicación entre servicios
- Volúmenes montados con permisos restrictivos

## 📞 Soporte

- **Issues**: [GitHub Issues](https://github.com/juantomoo/media-suite/issues)
- **Documentación**: Este README
- **Logs**: Usar `docker logs <nombre-contenedor>` para debugging

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo LICENSE para más detalles.

---

**Nota**: Este stack está optimizado para resolver específicamente el problema de archivos APE+CUE que no pueden ser importados directamente por Lidarr, convirtiéndolos automáticamente a FLAC con etiquetas apropiadas.
