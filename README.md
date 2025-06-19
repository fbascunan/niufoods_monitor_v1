# NiuFoods Monitor v1

## 📋 Descripción del Proyecto

Sistema de monitoreo centralizado para dispositivos de hardware en restaurantes de la franquicia NiuFoods. La aplicación permite a los restaurantes reportar el estado de sus dispositivos (POS, impresoras, sistemas de red) a través de una API REST, procesando los datos en segundo plano con Sidekiq y almacenándolos en PostgreSQL.

## 🚀 Inicio Rápido con Docker (Recomendado)

La forma más fácil de ejecutar este proyecto es usando Docker. Solo necesitas tener Docker y Docker Compose instalados.

### Prerrequisitos
- Docker
- Docker Compose

### Instalación y Ejecución

```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd niufoods_monitor_v1

# 2. Ejecutar setup completo (recomendado)
make setup

# O alternativamente:
./docker-setup.sh
```

### Comandos Útiles

```bash
# Ver todos los comandos disponibles
make help

# Gestión de servicios
make start          # Iniciar servicios
make stop           # Detener servicios
make restart        # Reiniciar servicios
make logs           # Ver logs
make status         # Estado de servicios

# Desarrollo
make test           # Ejecutar pruebas
make simulator      # Iniciar simulador
make console        # Abrir consola de Rails

# Mantenimiento
make clean          # Limpiar contenedores y volúmenes
make reset          # Reset completo y setup
```

### Acceso a la Aplicación

Una vez iniciado, puedes acceder a:
- **Dashboard**: http://localhost:5000
- **API**: http://localhost:5000/api/v1
- **Sidekiq Dashboard**: http://localhost:5000/sidekiq

## 🏗️ Arquitectura del Sistema

```
[Simulador de Restaurantes] → HTTP → [API Rails] → Queue → [Sidekiq] → [Use Cases] → [PostgreSQL] → [Dashboard Web]
```

### Componentes Principales

- **API REST**: Endpoints para recibir actualizaciones de estado de dispositivos
- **Sidekiq**: Procesamiento asíncrono de actualizaciones de estado
- **PostgreSQL**: Base de datos principal
- **Dashboard Web**: Interfaz para visualizar el estado de restaurantes y dispositivos
- **Simulador**: Script que simula el comportamiento de restaurantes reales

## 🛠️ Tecnologías Utilizadas

- **Ruby**: 3.2.2
- **Rails**: 7.1.5
- **PostgreSQL**: Base de datos
- **Sidekiq**: Procesamiento en segundo plano
- **Redis**: Para Sidekiq
- **Puma**: Servidor web
- **Hotwire/Turbo**: Actualizaciones en tiempo real
- **Docker**: Containerización

## 📦 Instalación Manual (Sin Docker)

### Prerrequisitos

- Ruby 3.2.2 o superior
- PostgreSQL
- Redis
- Node.js (para assets)

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd niufoods_monitor_v1
```

### 2. Instalar dependencias

```bash
bundle install
```

### 3. Configurar variables de entorno

Crear archivo `.env` en la raíz del proyecto:

```bash
# Database
DB_USERNAME=tu_usuario_postgres
DB_PASSWORD=tu_password_postgres

# Redis (para Sidekiq)
REDIS_URL=redis://localhost:6379/0
```

### 4. Configurar base de datos

```bash
# Crear base de datos
rails db:create

# Ejecutar migraciones
rails db:migrate

# Cargar datos de ejemplo
rails db:seed
```

### 5. Iniciar servicios

```bash
# Opción 1: Usar Foreman (recomendado)
foreman start

# Opción 2: Iniciar servicios por separado
# Terminal 1: Servidor web
rails server -p 5000

# Terminal 2: Sidekiq
bundle exec sidekiq -C config/sidekiq.yml

# Terminal 3: Redis (si no está corriendo)
redis-server
```

## 🚀 Uso del Sistema

### Dashboard Web

Acceder al dashboard principal:
```
http://localhost:5000
```

### API Endpoints

#### Actualizar estado de dispositivo
```bash
POST /api/v1/devices/status
Content-Type: application/json

{
  "device": {
    "serial_number": "POS001",
    "device_type": "pos",
    "name": "Terminal Principal",
    "model": "Verifone VX520",
    "status": "active",
    "description": "Dispositivo funcionando correctamente",
    "reported_at": "2024-01-15T10:30:00Z",
    "restaurant_name": "NiuFoods Centro"
  }
}
```

#### Obtener restaurantes
```bash
GET /api/v1/restaurants
```

#### Obtener dispositivos de un restaurante
```bash
GET /api/v1/restaurants/:id/devices
```

### Simulador de Dispositivos

#### Con Docker:
```bash
make simulator
```

#### Sin Docker:
```bash
cd simulator
ruby device_simulator.rb
```

El simulador:
- Carga datos de restaurantes y dispositivos desde la base de datos
- Simula cambios de estado aleatorios cada 5 segundos
- Envía actualizaciones a la API
- Muestra logs en tiempo real

## 📊 Modelos de Datos

### Restaurant
- `name`: Nombre del restaurante
- `location`: Ubicación
- `status`: Estado general (operational, warning, issues)
- `address`, `email`, `phone`, `timezone`: Información de contacto

### Device
- `name`: Nombre del dispositivo
- `device_type`: Tipo (pos, printer, network)
- `status`: Estado (active, warning, critical, inactive)
- `serial_number`: Número de serie único
- `model`: Modelo del dispositivo
- `restaurant_id`: Referencia al restaurante
- `last_check_in_at`: Última verificación

### MaintenanceLog
- `device_id`: Referencia al dispositivo
- `description`: Descripción del mantenimiento
- `status_before`: Estado anterior
- `status_after`: Estado posterior
- `created_at`: Fecha de creación

## 🧪 Testing

### Con Docker:
```bash
make test
```

### Sin Docker:
```bash
# Todas las pruebas
rails test

# Pruebas específicas
rails test test/models/
rails test test/controllers/
rails test test/jobs/
```

## 📁 Estructura del Proyecto

```
niufoods_monitor_v1/
├── app/
│   ├── controllers/api/v1/    # API controllers
│   ├── models/                # Modelos de datos
│   ├── jobs/                  # Jobs de Sidekiq
│   ├── usecases/              # Casos de uso
│   └── views/                 # Vistas del dashboard
├── simulator/                 # Script de simulación
├── config/
│   ├── sidekiq.yml           # Configuración de Sidekiq
│   └── database.yml          # Configuración de BD
├── docker-compose.yml        # Configuración de Docker
├── Dockerfile                # Imagen de Docker
├── Makefile                  # Comandos útiles
└── test/                     # Pruebas
```

## 🔧 Configuración Avanzada

### Docker
- Configuración en `docker-compose.yml`
- Imagen personalizada en `Dockerfile`
- Scripts de setup en `docker-setup.sh` y `Makefile`

### Sidekiq
- Configuración en `config/sidekiq.yml`
- Dashboard disponible en `http://localhost:5000/sidekiq`

### Base de Datos
- Configuración en `config/database.yml`
- Usar variables de entorno para credenciales

### Logs
- Logs de Rails: `log/development.log`
- Logs de Sidekiq: `log/sidekiq.log`
- Logs de Docker: `docker-compose logs -f`

## 🚨 Solución de Problemas

### Docker
```bash
# Verificar estado de servicios
make status

# Ver logs
make logs

# Reiniciar servicios
make restart

# Reset completo
make reset
```

### Error de conexión a PostgreSQL
```bash
# Verificar que PostgreSQL esté corriendo
sudo systemctl status postgresql

# Crear usuario si es necesario
sudo -u postgres createuser -s tu_usuario
```

### Error de conexión a Redis
```bash
# Verificar que Redis esté corriendo
redis-cli ping

# Iniciar Redis si no está corriendo
redis-server
```

### Problemas con Sidekiq
```bash
# Verificar logs
tail -f log/sidekiq.log

# Reiniciar Sidekiq
bundle exec sidekiq -C config/sidekiq.yml
```

## 📝 Notas de Desarrollo

- El sistema utiliza procesamiento asíncrono para manejar actualizaciones de estado
- Los cambios de estado se registran automáticamente en el log de mantenimiento
- El estado del restaurante se calcula automáticamente basado en el estado de sus dispositivos
- El simulador puede ser configurado para diferentes escenarios de prueba
- Docker proporciona un entorno aislado y reproducible

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear un Pull Request

## 📄 Licencia

Este proyecto es parte del desafío técnico de NiuFoods.
