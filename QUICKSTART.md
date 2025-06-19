# 🚀 NiuFoods Monitor v1 - Quick Start Guide

## Para Revisores

Este es un sistema de monitoreo de dispositivos para restaurantes desarrollado en Ruby on Rails. La forma más fácil de ejecutarlo es usando Docker.

## ⚡ Inicio Rápido (2 minutos)

### 1. Prerrequisitos
- Docker
- Docker Compose

### 2. Ejecutar el Proyecto

```bash
# Clonar y entrar al directorio
git clone <repository-url>
cd niufoods_monitor_v1

# Setup completo (esto puede tomar unos minutos la primera vez)
make setup
```

### 3. Acceder a la Aplicación

Una vez completado el setup, puedes acceder a:

- **Dashboard Principal**: http://localhost:5000
- **API Documentation**: http://localhost:5000/api/v1
- **Sidekiq Dashboard**: http://localhost:5000/sidekiq

## 🎮 Probar el Sistema

### Iniciar el Simulador
```bash
make simulator
```

El simulador enviará actualizaciones de estado de dispositivos cada 5 segundos. Puedes ver los cambios en tiempo real en el dashboard.

### Ver Logs
```bash
make logs
```

### Ejecutar Pruebas
```bash
make test
```

## 📊 Qué Ver

1. **Dashboard Principal**: Lista de restaurantes con su estado general
2. **Detalles de Restaurante**: Dispositivos específicos y su estado
3. **Logs de Mantenimiento**: Historial de cambios de estado
4. **Sidekiq Dashboard**: Procesamiento en segundo plano

## 🔧 Comandos Útiles

```bash
make help          # Ver todos los comandos
make status        # Estado de servicios
make restart       # Reiniciar servicios
make clean         # Limpiar todo
make reset         # Reset completo
```

## 🐛 Solución de Problemas

### Si el setup falla:
```bash
make clean
make reset
```

### Si los servicios no responden:
```bash
make restart
```

### Para ver logs específicos:
```bash
make logs
```

## 📝 Notas para la Revisión

- **Arquitectura**: API REST + Sidekiq + PostgreSQL
- **Procesamiento**: Asíncrono con Sidekiq
- **Simulación**: Script que simula restaurantes reales
- **Testing**: Suite completa de pruebas
- **Docker**: Entorno aislado y reproducible

## 🎯 Funcionalidades Clave

1. ✅ API para recibir actualizaciones de dispositivos
2. ✅ Procesamiento asíncrono con Sidekiq
3. ✅ Dashboard en tiempo real
4. ✅ Simulador de dispositivos
5. ✅ Logs de mantenimiento
6. ✅ Tests automatizados
7. ✅ Docker setup completo

¡El proyecto está listo para revisar! 🚀 