# ADR-001: n8n como Orquestador Central

**Estado:** Accepted  
**Fecha:** 2026-06-13  
**Owner:** Enterprise Architect  
**Superseded by:** N/A

---

## Contexto

Chappie necesita un sistema de orquestación que coordine múltiples pasos: STT, procesamiento con modelos de IA, ejecución de agentes, TTS y notificaciones. Las opciones evaluadas fueron:

1. **Orquestación en Python (daemon):** Toda la lógica en el daemon Python.
2. **n8n Workflows:** Orquestación visual con n8n.
3. **Node-RED:** Alternativa similar a n8n.
4. **Custom orchestrator en Go:** Servicio dedicado.

## Decisión

**Usar n8n como orquestador central** para todos los flujos de trabajo de Chappie.

## Alternativas Consideradas

### Opción 1: Orquestación en Python (daemon)
- **Ventajas:** Menos componentes, todo en un solo proceso, menor latencia.
- **Desventajas:** Lógica compleja embebida en el daemon, difícil de modificar sin reiniciar, sin UI de gestión de flujos, acoplamiento fuerte entre STT/procesamiento/TTS.

### Opción 2: n8n Workflows ✅ (Elegida)
- **Ventajas:**
  - UI visual para diseñar y modificar flujos.
  - Nodos pre-construidos para HTTP, RabbitMQ, OpenAI-compatible APIs.
  - Separación clara de responsabilidades: daemon solo captura/reproduce, n8n orquesta.
  - Fácil agregar nuevos pasos o modificar el flujo sin tocar código Python.
  - Historial de ejecuciones para debugging.
  - Self-hosted con Docker.
- **Desventajas:** Latencia adicional (~100ms), un componente más que mantener.

### Opción 3: Node-RED
- **Ventajas:** Similar a n8n, más maduro.
- **Desventajas:** UI menos moderna, menos nodos nativos para APIs de IA, comunidad más pequeña.

### Opción 4: Custom orchestrator en Go
- **Ventajas:** Máximo rendimiento, control total.
- **Desventajas:** Desarrollo significativo, sin UI, reinventar la rueda.

## Consecuencias

### Positivas
- El daemon Python se simplifica: solo graba, envía a n8n y reproduce audio.
- Los flujos se pueden modificar desde la UI de n8n sin reiniciar servicios.
- Fácil agregar nuevos proveedores de IA como nodos.
- Historial de ejecuciones para debugging.
- Workflows versionables como JSON.

### Negativas
- Un componente más que mantener (n8n en Docker).
- Latencia adicional de ~100ms por el HTTP roundtrip.
- Necesidad de gestionar la comunicación daemon ↔ n8n (webhooks).

### Riesgos
- n8n debe estar disponible para que el asistente funcione.
- Los webhooks deben ser seguros (auth con secret).

## Mitigación
- Docker Compose para asegurar que n8n inicie con el sistema.
- Health checks en Docker.
- Fallback a procesamiento local en el daemon si n8n no responde.

---

*Decisión revisada: N/A*
