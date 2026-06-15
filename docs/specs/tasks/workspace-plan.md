# Plan de Trabajo del Workspace - Chappie Ecosystem

**Estado:** Active
**Última actualización:** 2026-06-15

Este documento detalla el plan de trabajo global para implementar el ecosistema Chappie, basado en la arquitectura definida en `docs/architecture/system-landscape.md`.

## Reglas de Flujo de Trabajo (Workflow Rules)

1. **Validación de Specs:** Todo trabajo relacionado con especificaciones (Master Spec, Delta Specs, OpenAPI, etc.) debe ser revisado y aprobado por el agente `spec-validator` antes de pasar a descomposición o implementación.
2. **Revisión de Código (Code Review):** Después de terminar la implementación y las pruebas de cada avance, y **antes de hacer commit/push a Git**, se debe delegar al agente `reviewer` para que revise el código.
3. **Corrección de Hallazgos:** Si el `reviewer` encuentra problemas, se debe delegar la corrección a los agentes indicados (ej. `executor` o `refactor`). Si hay problemas en las specs, se debe usar `spec-remediator` o `planner`.

## Fase 1: Configuración Base y Core de Voz (Prioridad Alta)

- [x] **chappie-config**: Archivos YAML base creados (providers, TTS, whitelist, personalidad).
- [x] **chappie-daemon (initial-setup)**: Implementado y revisado. Rama `develop` creada. Incluye captura de voz, ducking, reproducción TTS endpoint `/play-tts`, escritura de estado y tests con cobertura 90%.
  - Pendiente: Push al remoto (requiere autenticación del usuario).

## Fase 2: Orquestación y Procesamiento (Prioridad Alta)

- [x] **chappie-n8n-workflows**: Voice Pipeline y Error Handler implementados (workflows JSON). Configuración YAML completa de proveedores, personalidad y memoria.

## Fase 3: Notificaciones, TTS y Ejecución (Prioridad Media)

- [x] **chappie-notification**: Completado (incremento anterior). Arquitectura hexagonal con 4 consumers RabbitMQ, Edge-TTS, OpenCode, SwayNC. Tests unitarios e integración.

## Fase 4: UI Visual (Prioridad Baja)

- [~] **chappie-quickshell**: Especificación creada y validada por `spec-validator` (veredicto: ready). En espera de aprobación humana para descomposición e implementación.

---

## Delegación Actual

| Proyecto | Estado | Próxima acción |
|---|---|---|
| **chappie-infrastructure** | ✅ Completo | Push al remoto |
| **chappie-config** | ✅ Completo (YAML base) | Push al remoto |
| **chappie-daemon** | ✅ Completo (initial-setup) | Push al remoto (requiere autenticación) |
| **chappie-n8n-workflows** | ✅ Completo (initial-setup) | Push y QA manual |
| **chappie-notification** | ✅ Completo (initial-setup) | Push y QA manual |
| **chappie-quickshell** | 🔶 Spec lista (awaiting approval) | Esperando aprobación humana |

## Observaciones

- Todos los proyectos de backend están **completos**: infrastructure, config, daemon, n8n-workflows y notification.
- **chappie-quickshell** tiene la spec lista y validada. Pendiente de aprobación humana para iniciar implementación.