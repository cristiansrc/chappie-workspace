# ADR-002: RabbitMQ para Bus de Eventos

**Estado:** Accepted  
**Fecha:** 2026-06-13  
**Owner:** Enterprise Architect  
**Superseded by:** N/A

---

## Contexto

Chappie necesita un mecanismo de comunicación asíncrona entre:
- n8n (orquestador) y chappie-notification (consumer)
- chappie-notification y los diferentes consumers (execution, error, tts, notification)
- Agentes de OpenCode y el sistema de notificaciones

Las opciones evaluadas fueron:

1. **Comunicación directa HTTP:** Cada componente llama directamente al siguiente.
2. **Redis Pub/Sub:** Mensajería ligera con Redis.
3. **RabbitMQ:** Bus de mensajes con colas durables.
4. **Apache Kafka:** Streaming de eventos.

## Decisión

**Usar RabbitMQ** como bus de eventos para todas las comunicaciones asíncronas de Chappie.

## Alternativas Consideradas

### Opción 1: Comunicación directa HTTP
- **Ventajas:** Simple, sin componentes adicionales.
- **Desventajas:** Acoplamiento fuerte, si un consumer falla se pierde el mensaje, difícil implementar retry, sin dead-letter queue.

### Opción 2: Redis Pub/Sub
- **Ventajas:** Ligero, rápido, simple.
- **Desventajas:** Mensajes no durables (se pierden si el consumer no está), sin dead-letter queue, sin priorización de mensajes, sin routing complejo.

### Opción 3: RabbitMQ ✅ (Elegida)
- **Ventajas:**
  - Mensajes durables con persistencia.
  - Dead-letter queues para mensajes fallidos.
  - Priorización de mensajes (errores > normal).
  - Routing flexible (direct, topic, fanout exchanges).
  - Acknowledgement manual para procesamiento confiable.
  - TTL por mensaje.
  - Management UI para monitoreo.
  - Self-hosted con Docker.
  - Cliente Python maduro (pika, aio-pika).
- **Desventajas:** Un componente más que mantener, overhead de ~50ms por mensaje.

### Opción 4: Apache Kafka
- **Ventajas:** Streaming de eventos, replay, alta throughput.
- **Desventajas:** Overkill para el caso de uso de Chappie, más complejo de operar, requiere ZooKeeper o KRaft, mayor uso de recursos.

## Consecuencias

### Positivas
- Desacoplamiento completo entre productores y consumidores.
- Mensajes no se pierden si un consumer falla.
- Dead-letter queues para diagnóstico de errores.
- Priorización de mensajes de error sobre mensajes normales.
- Management UI para ver el estado de las colas.
- Fácil agregar nuevos consumers sin modificar producers.

### Negativas
- Un componente más que mantener (RabbitMQ en Docker).
- Overhead de latencia por mensaje (~50ms).
- Necesidad de gestionar conexiones y reconexiones.

### Riesgos
- RabbitMQ debe estar disponible para la comunicación entre componentes.
- Las colas pueden llenarse si un consumer falla.

## Mitigación
- Docker Compose para asegurar que RabbitMQ inicie con el sistema.
- Health checks en Docker.
- TTL en mensajes para evitar acumulación.
- Dead-letter queues para mensajes fallidos.
- Monitoreo con Management UI.

## Colas Definidas

| Cola | Producer | Consumer | Propósito |
|---|---|---|---|
| chappie.responses | n8n | execution_consumer | Respuestas del modelo |
| chappie.errors | execution_consumer | error_consumer | Errores de ejecución |
| chappie.tts.requests | execution/error consumer | tts_consumer | Solicitudes de TTS |
| chappie.agent.results | execution_consumer | notification_consumer | Resultados de agentes |
| chappie.agent.questions | agentes | notification_consumer | Preguntas de agentes |
| chappie.agent.answers | notification_consumer | agentes | Respuestas del usuario |
| chappie.notifications | múltiples | notification_consumer | Notificaciones genéricas |

---

*Decisión revisada: N/A*
