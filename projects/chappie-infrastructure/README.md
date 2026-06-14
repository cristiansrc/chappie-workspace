# Chappie Infrastructure

**Proyecto:** chappie-infrastructure  
**Owner:** Cris  
**Estado:** Active  
**Tipo:** Infraestructura base (Docker + Systemd)

---

## Propósito

Este proyecto contiene la configuración de infraestructura base del ecosistema Chappie: los servicios Docker (n8n + RabbitMQ) y su configuración de auto-inicio para que todo arranque automáticamente al prender el PC.

---

## Servicios

| Servicio | Puerto | Descripción |
|---|---|---|
| **chappie-n8n** | `5678` | Orquestador de workflows (n8n) |
| **chappie-rabbitmq** | `5672` (AMQP), `15672` (UI) | Bus de eventos y colas de mensajes |
| **chappie-rabbitmq-init** | — | Inicializador de colas y DLQs |

---

## Estructura del Proyecto

```
chappie-infrastructure/
├── docker-compose.yaml       # Definición de servicios Docker
├── .env.example              # Plantilla de variables de entorno
├── .env                      # Variables de entorno reales (NO versionado)
├── systemd/
│   └── chappie-infra.service # Servicio systemd para auto-inicio
├── scripts/
│   ├── setup.sh              # Script de instalación completa
│   └── ctl.sh                # Control de servicios (start/stop/status)
└── README.md                 # Este archivo
```

---

## Instalación Rápida

```bash
# 1. Dar permisos de ejecución a los scripts
chmod +x scripts/*.sh

# 2. Ejecutar el setup (instala systemd y arranca servicios)
./scripts/setup.sh

# 3. Editar .env con tus API keys
nano .env
```

---

## Auto-Inicio (Systemd)

El servicio `chappie-infra.service` se instala como servicio de usuario en systemd y se habilita para arrancar automáticamente al iniciar sesión.

```bash
# Ver estado del servicio
systemctl --user status chappie-infra

# Iniciar / Detener manualmente
systemctl --user start chappie-infra
systemctl --user stop chappie-infra

# Ver logs del servicio
journalctl --user -u chappie-infra -f
```

---

## Comandos Rápidos

```bash
# Iniciar todo
./scripts/ctl.sh start

# Detener todo
./scripts/ctl.sh stop

# Ver estado
./scripts/ctl.sh status

# Ver logs
./scripts/ctl.sh logs
```

---

## Dependencias del Sistema

- **Docker** ≥ 24.0 + **Docker Compose** ≥ v2.20
- **systemd** (incluido en la mayoría de distribuciones Linux)

---

## Endpoints Post-Arranque

| Servicio | URL | Credenciales |
|---|---|---|
| n8n Web UI | http://localhost:5678 | `.env` → `N8N_USER` / `N8N_PASSWORD` |
| RabbitMQ Management | http://localhost:15672 | `.env` → `RABBITMQ_USER` / `RABBITMQ_PASSWORD` |

---

*Documento mantenido por: Enterprise Architect*
