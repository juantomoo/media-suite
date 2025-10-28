# 🚀 Instrucciones Rápidas para Portainer

## Despliegue en 3 Pasos

### 1. Abrir Portainer
- Ir a **Stacks** → **Add Stack**

### 2. Configurar Repository
- **Pestaña**: "Repository"
- **Repository URL**: `https://github.com/juantomoo/media-suite.git`
- **Repository reference**: `main`
- **Compose path**: `docker-compose.yaml`
- **Marcar**: "Automatic updates" ✅

### 3. Desplegar
- **Clic**: "Deploy the stack"
- **Esperar**: Construcción automática (2-3 minutos)

## ✅ Verificación

### Servicios Disponibles
- **Lidarr**: `http://tu-servidor:8686`
- **qBittorrent**: `http://tu-servidor:8687`
- **Prowlarr**: `http://tu-servidor:8688`
- **FlareSolverr**: `http://tu-servidor:8690` (API interna)
- **Navidrome**: `http://tu-servidor:8691` (Servidor de música)
- **Filebrowser**: `http://tu-servidor:8692` (Gestor de archivos)

### Conversor APE+CUE
- **Contenedor**: `ape-cue-splitter`
- **Función**: Convierte automáticamente APE+CUE → FLAC
- **Monitoreo**: `/data/downloads` (compartido con qBittorrent)

## 🔧 Configuración Inicial

### Lidarr
1. Acceder a `http://tu-servidor:8686`
2. **Settings** → **Media Management**:
   - **Root Folders**: `/data/Musics`
3. **Settings** → **Download Clients**:
   - **Completed Download Handling**: ✅ Habilitado
   - **Remove**: ✅ Habilitado

### qBittorrent
1. Acceder a `http://tu-servidor:8687`
2. **Options** → **Downloads**:
   - **Default Save Path**: `/data/downloads/torrents`

## 📁 Estructura de Volúmenes (Compatibilidad)

```
/srv/media:/data                    # Música y descargas
/opt/lidarr/config:/config          # Config Lidarr
/opt/qbittorrent/config:/config     # Config qBittorrent
/opt/prowlarr/config:/config        # Config Prowlarr
```

**✅ Mantiene**: Usuarios, indexers, configuraciones existentes

## 🆘 Troubleshooting

### Ver Logs
```bash
docker logs ape-cue-splitter
docker logs lidarr
```

### Reiniciar Servicio
- **Portainer** → **Containers** → Seleccionar → **Restart**

### Problema Común
- **No convierte**: Verificar que `.cue` y `.ape` estén en la misma carpeta
- **No importa**: Verificar configuración de "Completed Download Handling" en Lidarr

---

**💡 Tip**: El conversor crea archivos `.converted` para evitar reprocesar. Si necesitas reconvertir, borra ese archivo.
