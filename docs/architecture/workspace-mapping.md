# Workspace Mapping - Chappie Ecosystem

**Estado:** Active  
**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-13

---

## 1. Estructura del Workspace

```
/home/cristiansrc/Documentos/Proyectos/chappie-workspace/
├── .gitignore
├── README.md
├── LICENSE.md
├── docker-compose.yaml
├── docs/
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
    ├── chappie-daemon/
    ├── chappie-n8n-workflows/
    ├── chappie-notification/
    ├── chappie-quickshell/
    └── chappie-config/
```

---

## 2. Proyectos

| Proyecto | Ruta Relativa | Bounded Context | Owner | Estado |
|---|---|---|---|---|
| **chappie-daemon** | `projects/chappie-daemon/` | Voice Capture, Audio Output Control, STT Client | Cris | Pendiente |
| **chappie-n8n-workflows** | `projects/chappie-n8n-workflows/` | Orchestration, Memory | Cris | Pendiente |
| **chappie-notification** | `projects/chappie-notification/` | Agent Execution, Event Bus Consumer, TTS, Notification | Cris | Pendiente |
| **chappie-quickshell** | `projects/chappie-quickshell/` | Notification UI (Widget) | Cris | Pendiente |
| **chappie-config** | `projects/chappie-config/` | Configuration, Personality | Cris | Pendiente |

---

## 3. Repositorios

Cada proyecto en `projects/` es un repositorio independiente. El workspace principal (`chappie-workspace`) versiona únicamente la documentación arquitectónica y el `docker-compose.yaml`.

El `.gitignore` del workspace ignora `projects/**` para evitar versionar sub-repositorios dentro del repo de arquitectura.

---

## 4. Dependencias entre Proyectos

```
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
