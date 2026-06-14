# Plan de Trabajo del Workspace - Chappie Ecosystem

**Estado:** Active
**Última actualización:** 2026-06-14

Este documento detalla el plan de trabajo global para implementar el ecosistema Chappie, basado en la arquitectura definida en `docs/architecture/system-landscape.md`.

## Reglas de Flujo de Trabajo (Workflow Rules)

1. **Validación de Specs:** Todo trabajo relacionado con especificaciones (Master Spec, Delta Specs, OpenAPI, etc.) debe ser revisado y aprobado por el agente `spec-validator` antes de pasar a descomposición o implementación.
2. **Revisión de Código (Code Review):** Después de terminar la implementación y las pruebas de cada avance, y **antes de hacer commit/push a Git**, se debe delegar al agente `reviewer` para que revise el código.
3. **Corrección de Hallazgos:** Si el `reviewer` encuentra problemas, se debe delegar la corrección a los agentes indicados (ej. `executor` o `refactor`). Si hay problemas en las specs, se debe usar `spec-remediator` o `planner`.

## Fase 1: Configuración Base y Core de Voz (Prioridad Alta)

- [x] **chappie-config**: Crear estructura base y archivos YAML de configuración (proveedores, TTS, whitelist, personalidad).
- [x] **chappie-daemon (initial-setup)**: Planificación completada, spec validada, tareas de setup implementadas y rama `develop` creada desde `feature/initial-setup`.
  - Pendiente: Fase 2 (notificaciones TTS), Fase 3 (UI Quickshell).

## Fase 2: Orquestación y Procesamiento (Prioridad Alta)

- [ ] **chappie-n8n-workflows**: Diseñar e implementar los workflows de n8n para el procesamiento de voz (STT -> LLM -> JSON) y manejo de errores. (En progreso)

## Fase 3: Notificaciones, TTS y Ejecución (Prioridad Media)

- [ ] **chappie-notification**: Planificar e implementar el consumer de RabbitMQ para ejecutar agentes OpenCode, generar audio TTS y mostrar notificaciones SwayNC.
- [ ] **chappie-daemon (Integración TTS)**: Implementar el endpoint `POST /play-tts` para reproducir el audio generado con volume ducking.

## Fase 4: UI Visual (Prioridad Baja)

- [ ] **chappie-quickshell**: Planificar e implementar el widget visual en QML/Qt6 para mostrar el texto TTS y el estado del sistema.

---

## Delegación Actual

1. **chappie-config**: Completado.
2. **chappie-daemon**: Initial-setup completado por `executor`. Rama `develop` creada. Pendiente de push al remoto por el usuario.
3. **chappie-n8n-workflows**: Delegado a `planner` para crear la Master Spec local y el diseño detallado de los workflows.
4. **chappie-notification**: Delegado a `planner` para crear la Master Spec local y el diseño detallado.