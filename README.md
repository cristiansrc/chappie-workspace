# Chappie Workspace

**Asistente de Voz AI con Personalidad - Inspirado en CHAPPIE (2015)**

Workspace de solución para el ecosistema Chappie, un asistente de voz inteligente con personalidad única, orquestado por n8n y con integración multi-proveedor de modelos de IA.

---

## Visión General

Chappie es un asistente de voz que combina:
- **Personalidad única** basada en el robot de la película CHAPPIE (2015)
- **Orquestación inteligente** mediante n8n workflows
- **Multi-proveedor de IA** (OpenCode, Google Gemini, Claude, GPT)
- **Control adaptativo de audio** (volume ducking durante TTS)
- **Notificaciones interactivas** con SwayNC
- **Widget de texto visual** con Quickshell
- **Ejecución de agentes** especializados de OpenCode
- **Sistema de eventos** con RabbitMQ

---

## Arquitectura del Ecosistema

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                           CHAPPIE ECOSYSTEM                                   │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌───────────────────────────────────────────┐                                │
│  │  chappie-infrastructure                   │                                │
│  │  (Docker Compose + Systemd)               │                                │
│  │                                           │                                │
│  │  ┌────────────────┐ ┌────────────────┐   │                                │
│  │  │  chappie-n8n   │ │  chappie-      │   │                                │
│  │  │  Orchestrator  │ │  rabbitmq      │   │                                │
│  │  │  (Workflows)   │ │  (Event Bus)   │   │                                │
│  │  └───────┬────────┘ └────────┬───────┘   │                                │
│  └──────────┼───────────────────┼───────────┘                                │
│             │                   │                                             │
│  ┌──────────▼───────────────────▼──────────┐                                │
│  │  chappie-daemon                         │                                │
│  │  (Grabación, Ducking, Playback, Estado) │                                │
│  │  HTTP API :8765                         │                                │
│  └──────┬─────────────┬────────────────────┘                                │
│         │             │                                                      │
│         │             │                                                      │
│  ┌──────▼──────────┐  │  ┌──────────────────────────────────────────┐      │
│  │  chappie-config │  │  │  chappie-notification                    │      │
│  │  (Config +      │  │  │  (Consumers: execution, error, tts, notif)│      │
│  │   Personality)  │  │  │  - Genera TTS → POST /play-tts a daemon │      │
│  └─────────────────┘  │  │  - Ejecuta agentes OpenCode             │      │
│                       │  │  - Notificaciones SwayNC + Quickshell   │      │
│                       │  └──────────────────┬───────────────────────┘      │
│                       │                     │                                │
│                       │                     ▼                                │
│                       │           ┌──────────────────┐                      │
│                       │           │ chappie-quickshell│                      │
│                       │           │ (Widget TTS +    │                      │
│                       └───────────│  Estado Visual)  │                      │
│                                   └──────────────────┘                      │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────┐            │
│  │  Servicios Ext.: Gemini (STT), Edge-TTS, OpenCode API/CLI  │            │
│  └─────────────────────────────────────────────────────────────┘            │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## Proyectos del Workspace

| Proyecto | Responsabilidad | Estado |
|---|---|---|
| **chappie-infrastructure** | Docker Compose (n8n + RabbitMQ), Systemd auto-inicio, scripts de control | ✅ Active |
| **chappie-daemon** | Servicio de grabación, control de volumen, STT y reproducción TTS | ✅ Active |
| **chappie-n8n-workflows** | Workflows de n8n para orquestación del asistente | ✅ Active |
| **chappie-notification** | Consumer de RabbitMQ para ejecución y notificaciones | ✅ Active |
| **chappie-quickshell** | Widget de Quickshell para visualización de texto TTS y estado del daemon | ✅ Active |
| **chappie-config** | Configuración centralizada de agentes, skills y personalidades | ✅ Active |

---

> **Estado:** Fases 1-3 completadas. **Fase 4** (widget-initial) completada. Todos los 6 proyectos del ecosistema están implementados.

## Fases de Implementación

### Fase 1 - Core Voice Loop (MVP)
- [x] Crear estructura de directorios del workspace
- [x] Configurar Docker Compose con n8n y RabbitMQ (proyecto chappie-infrastructure)
- [x] Definir arquitectura global (System Landscape, Context Map, Integration Map, ADRs)
- [x] Definir Master Spec global del ecosistema
- [x] Configurar auto-inicio de infraestructura con systemd
- [x] Completar configuración de infraestructura (`.env`, directorios bind mount, fix rutas)
- [x] Configuración YAML básica (proveedores, personalidad) en `chappie-config`
- [x] Implementar `chappie-daemon` (grabación + control volumen + STT) - *Initial setup completado*
- [x] Crear workflow básico en n8n (STT → Modelo → JSON → TTS) en `chappie-n8n-workflows`
- [x] Implementar volume ducking durante TTS (todos los sinks)
- [x] Instalar SwayNC para notificaciones
- [x] Instalar Quickshell para widget de texto
- [x] Implementar reproducción de TTS en daemon

### Fase 2 - Widget de Texto y Notificaciones
- [x] Implementar `chappie-notification` consumers
- [x] Notificaciones básicas con SwayNC
- [x] Crear widget de Quickshell para texto TTS y estado del daemon
- [ ] Implementar toggle de texto (SUPER+ALT+T) — gestionado externamente por chappie-daemon

### Fase 3 - Agentes y RabbitMQ
- [x] Integración con OpenCode CLI via n8n
- [x] Flujo de ejecución en background (agentes + comandos)
- [x] Manejo de errores con retry y notificación
- [x] Memoria con auto-compresión
- [x] Sistema de preguntas/respuestas con SwayNC

### Fase 4 - Pulido y Expansión
- [x] Overlay de estado (escuchando/pensando/trabajando) en Quickshell
- [ ] Ojo Biónico (captura de pantalla + análisis)
- [ ] Multi-proveedor completo (Claude, GPT, Azure TTS)
- [ ] Clonación de voz de Chappie (cuando esté disponible)

---

## Atajos de Hyprland

| Atajo | Acción |
|---|---|
| `SUPER + ALT + C` | Activar/desactivar grabación de Chappie (walkie-talkie) |
| `SUPER + ALT + T` | Toggle visualización de texto TTS |

---

## Documentación Arquitectónica

- [Master Spec (Global)](docs/specs/master_spec.md)
- [System Landscape](docs/architecture/system-landscape.md)
- [Context Map](docs/architecture/context-map.md)
- [Integration Map](docs/architecture/integration-map.md)
- [Workspace Mapping](docs/architecture/workspace-mapping.md)
- [Decision Records](docs/architecture/decision-records/)
- [Workspace Changes (Historial)](docs/specs/workspace_changes.md)
- [Technical Debt (Global)](docs/specs/technical_debt.md)

---

## Tecnologías

- **Orquestación:** n8n
- **Mensajería:** RabbitMQ
- **Notificaciones:** SwayNC
- **Widget UI:** Quickshell (QML/Qt6)
- **STT:** Gemini 2.5 Flash (ASR)
- **TTS:** Edge-TTS (configurable: Gemini TTS, Azure, Mimo)
- **Modelos IA:** OpenCode (free), Google Gemini, Claude, GPT
- **Compositor:** Hyprland
- **Contenedores:** Docker Compose

---

## Licencia

Ver [LICENSE.md](LICENSE.md)

---

*Creado: 2026-06-13*  
*Última actualización: 2026-06-15 (completado chappie-quickshell - Fase 4)*
