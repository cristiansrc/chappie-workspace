# Technical Debt - Chappie Ecosystem (Global)

**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14

---

## Deuda Activa

| ID | Descripción | Proyecto | Impacto | Plan de mitigación | Estado |
|---|---|---|---|---|---|---|
| TD-001 | API keys vacías en `.env` | chappie-infrastructure | Los servicios Docker (n8n) no podrán usar Gemini, Claude, GPT ni Azure TTS sin las keys reales | Completar keys antes del primer `docker compose up` | active |

---

## Deuda Resuelta

| ID | Descripción | Fecha resolución | Fix |
|---|---|---|---|
| DEBT-001 | D-Bus Implementation Incompleta (chappie-notification) | 2026-06-14 | Migrado de `dasbus` a `dbus-next`. Implementado `_ensure_dbus_connection()` con `dbus-next` async MessageBus, `_on_action_invoked()` como signal handler para `ActionInvoked`, y `--print-id` en `notify-send` para obtener el ID real de notificación del servidor. |
| TD-002 | Directorios `workflows/` y `config/` vacíos | chappie-n8n-workflows | 2026-06-15 | Implementados workflows JSON (Voice Pipeline, Error Handler) y archivos YAML de configuración (providers, personality, memory). Directorios ya contienen archivos reales. |
| TD-003 | Sin specs SDD por proyecto | workspace global | 2026-06-15 | Creadas Master Specs locales por proyecto (chappie-config, chappie-daemon, chappie-n8n-workflows, chappie-notification, chappie-infrastructure). |
| TD-004 | Sin tests automatizados | workspace global | 2026-06-15 | Implementados tests unitarios con cobertura >94% en chappie-notification. Pendiente: tests para chappie-daemon y chappie-quickshell. |

---

## Deuda por Proyecto (Local)

Cada proyecto debe mantener su propio `docs/specs/technical_debt.md` local:

| Proyecto | Archivo local | Estado |
|---|---|---|
| chappie-infrastructure | No creado aún | — |
| chappie-daemon | No creado aún | — |
| chappie-n8n-workflows | No creado aún | — |
| chappie-notification | `projects/chappie-notification/docs/specs/technical_debt.md` | Sincronizado |
| chappie-quickshell | No creado aún | — |
| chappie-config | No creado aún | — |

### chappie-notification

| ID | Descripción | Impacto | Plan de mitigación | Estado |
|---|---|---|---|---|
| DEBT-001 | D-Bus Implementation Incompleta | Las notificaciones con acciones nunca reciben respuesta del usuario real. | Migrado de `dasbus` a `dbus-next`. Implementado `_ensure_dbus_connection()` con `dbus-next` async MessageBus, `_on_action_invoked()` como signal handler para `ActionInvoked`, y `--print-id` en `notify-send` para obtener el ID real de notificación del servidor. | `resolved` |

---

*Documento mantenido por: Enterprise Architect*
