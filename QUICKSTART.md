# 🚀 NiuFoods Monitor v1 - Quick Start

## Para Revisores

Sistema de monitoreo de dispositivos para restaurantes desarrollado en Ruby on Rails.

## ⚡ Inicio Rápido

### 1. Prerrequisitos
- Docker
- Docker Compose

### 2. Ejecutar

```bash
# Clonar y entrar al directorio
git clone <repository-url>
cd niufoods_monitor_v1

# Setup completo
make setup
```

### 3. Acceder

- **Dashboard**: http://localhost:5000
- **API**: http://localhost:5000/api/v1
- **Sidekiq**: http://localhost:5000/sidekiq

## 🎮 Probar

```bash
# Iniciar simulador
make simulator

# Ver logs
make logs

# Ejecutar tests
make test

# Verificar que todo funciona
./test_app.sh
```

## 🔧 Comandos Útiles

```bash
make help          # Ver comandos
make status        # Estado de servicios
make restart       # Reiniciar
make clean         # Limpiar todo
```

## 🐛 Si hay problemas

### Error de permisos Docker:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Reset completo:
```bash
make clean
make setup
```

## 📝 Notas

- **Arquitectura**: API REST + Sidekiq + PostgreSQL
- **Procesamiento**: Asíncrono con Sidekiq
- **Simulación**: Script que simula restaurantes reales
- **Testing**: Suite completa de pruebas
- **Docker**: Entorno aislado y reproducible
- **Puertos**: Usa puertos no conflictivos (5433, 6380)

¡Listo para revisar! 🚀 