# Plan de Trabajo del Workspace - Chappie Ecosystem

**Estado:** Active
**Última actualización:** 2026-06-14

Este documento detalla el plan de trabajo global para implementar el ecosistema Chappie, basado en la arquitectura definida en `docs/architecture/system-landscape.md`.

## Fase 1: Configuración Base y Core de Voz (Prioridad Alta)

- [ ] **chappie-config**: Crear estructura base y archivos YAML de configuración (proveedores, TTS, whitelist, personalidad).
- [ ] **chappie-daemon**: Planificar e implementar el servicio de captura de voz, detección de atajos (SUPER+ALT+C), volume ducking y envío de audio a n8n.

## Fase 2: Orquestación y Procesamiento (Prioridad Alta)

- [ ] **chappie-n8n-workflows**: Diseñar e implementar los workflows de n8n para el procesamiento de voz (STT -> LLM -> JSON) y manejo de errores.

## Fase 3: Notificaciones, TTS y Ejecución (Prioridad Media)

- [ ] **chappie-notification**: Planificar e implementar el consumer de RabbitMQ para ejecutar agentes OpenCode, generar audio TTS y mostrar notificaciones SwayNC.
- [ ] **chappie-daemon (Integración TTS)**: Implementar el endpoint `POST /play-tts` para reproducir el audio generado con volume ducking.

## Fase 4: UI Visual (Prioridad Baja)

- [ ] **chappie-quickshell**: Planificar e implementar el widget visual en QML/Qt6 para mostrar el texto TTS y el estado del sistema.

---

## Delegación Actual

1. **chappie-config**: Delegado a `executor` para crear los archivos YAML base.
2. **chappie-daemon**: Delegado a `planner` para crear la Master Spec local y el diseño detallado.
3. **chappie-notification**: Delegado a `planner` para crear la Master Spec local y el diseño detallado.