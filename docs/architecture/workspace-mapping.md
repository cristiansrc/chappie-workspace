# Workspace Mapping - Chappie Ecosystem

**Estado:** Active  
**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14

---

## 1. Estructura del Workspace

```
/home/cristiansrc/Documentos/Proyectos/chappie-workspace/
├── .gitignore
├── README.md
├── LICENSE.md
├── docs/
│   ├── specs/
│   │   └── master_spec.md
│   └── architecture/
│       ├── system-landscape.md
│       ├── context-map.md
│       ├── integration-map.md
│       ├── workspace-mapping.md
│       └── decision-records/
│           ├── ADR-001-n8n-orchestration.md
│           ├── ADR-002-rabbitmq-events.md
│           ├── ADR-003-swaync-notifications.md
│           └── ADR-004-quickshell-text-widget.md
└── projects/
    ├── chappie-infrastructure/
    ├── chappie-daemon/
    ├── chappie-n8n-workflows/
    ├── chappie-notification/
    ├── chappie-quickshell/
    └── chappie-config/
```

---

## 2. Proyectos

| Proyecto | Ruta Relativa | Bounded Context | Owner | Estado |
|---|---|---|---|---|---|
| **chappie-infrastructure** | `projects/chappie-infrastructure/` | Infrastructure (Docker, Systemd) | Cris | Active |
| **chappie-daemon** | `projects/chappie-daemon/` | Voice Capture, Audio Output Control, STT Client | Cris | Pendiente |
| **chappie-n8n-workflows** | `projects/chappie-n8n-workflows/` | Orchestration, Memory | Cris | Pendiente |
| **chappie-notification** | `projects/chappie-notification/` | Agent Execution, Event Bus Consumer, TTS, Notification | Cris | Pendiente |
| **chappie-quickshell** | `projects/chappie-quickshell/` | Notification UI (Widget) | Cris | Pendiente |
| **chappie-config** | `projects/chappie-config/` | Configuration, Personality | Cris | Pendiente |

---

## 3. Repositorios

Cada proyecto en `projects/` es un repositorio independiente. El workspace principal (`chappie-workspace`) versiona únicamente la documentación arquitectónica y `chappie-infrastructure` (Docker Compose + Systemd para auto-inicio global).

El `.gitignore` del workspace ignora `projects/**` EXCEPTO `projects/chappie-infrastructure/`, que se versiona en el workspace porque contiene la configuración de infraestructura base necesaria para el arranque.

---

## 4. Dependencias entre Proyectos

```
chappie-infrastructure (Docker: n8n + RabbitMQ, Systemd auto-start)
       │
       ├──▶ chappie-n8n-workflows (se despliega en n8n)
       └──▶ chappie-notification (consume de RabbitMQ)

chappie-config (Configuration, Personality)
       │
       ├──▶ chappie-daemon (lee config al iniciar)
       ├──▶ chappie-n8n-workflows (lee providers, personality)
       └──▶ chappie-notification (lee commands-whitelist, tts-config)

chappie-daemon ──HTTP──▶ chappie-n8n-workflows (webhook)
chappie-n8n-workflows ──AMQP──▶ chappie-notification (RabbitMQ)
chappie-notification ──HTTP──▶ chappie-daemon (play-tts)
chappie-notification ──files──▶ chappie-quickshell (estado)
```

---

## 5. Convenciones

- **Idioma:** Todo el código, documentación y comentarios en ESPAÑOL.
- **Nombres de proyectos:** Prefijo `chappie-` seguido del nombre del bounded context principal.
- **Rutas de config:** `~/.config/chappie/` para configuración de usuario.
- **Archivos de estado:** `/tmp/chappie_*.txt` para comunicación entre procesos.
- **Puertos:** Ver integration-map.md.

---

*Documento mantenido por: Enterprise Architect*
