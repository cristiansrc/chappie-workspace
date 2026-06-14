# Technical Debt - Chappie Ecosystem (Global)

**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14

---

## Deuda Activa

| ID | Descripción | Proyecto | Impacto | Plan de mitigación | Estado |
|---|---|---|---|---|---|
| TD-001 | API keys vacías en `.env` | chappie-infrastructure | Los servicios Docker (n8n) no podrán usar Gemini, Claude, GPT ni Azure TTS sin las keys reales | Completar keys antes del primer `docker compose up` | active |
| TD-002 | Directorios `workflows/` y `config/` vacíos | chappie-n8n-workflows | n8n arranca pero sin workflows ni configuración que cargar | Implementar chappie-n8n-workflows (Fase 1) | active |
| TD-003 | Sin specs SDD por proyecto | workspace global | Sin descomposición en incrementos, el desarrollo no tiene guía estructurada | Crear master specs e incrementos por proyecto al iniciar implementación | active |
| TD-004 | Sin tests automatizados | workspace global | No hay verificación de regresiones ni calidad | Implementar tests por proyecto al desarrollar cada componente | active |

---

## Deuda Resuelta

| ID | Descripción | Fecha resolución | Fix |
|---|---|---|---|
| — | — | — | — |

---

## Deuda por Proyecto (Local)

Cada proyecto debe mantener su propio `docs/specs/technical_debt.md` local:

| Proyecto | Archivo local | Estado |
|---|---|---|
| chappie-infrastructure | No creado aún | — |
| chappie-daemon | No creado aún | — |
| chappie-n8n-workflows | No creado aún | — |
| chappie-notification | No creado aún | — |
| chappie-quickshell | No creado aún | — |
| chappie-config | No creado aún | — |

---

*Documento mantenido por: Enterprise Architect*
