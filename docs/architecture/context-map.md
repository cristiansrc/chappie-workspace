# Context Map - Chappie Ecosystem

**Estado:** Active  
**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14

---

## 1. Bounded Contexts

### 1.1 Identificación de Contextos

| Bounded Context | Responsabilidad | Lenguaje Ubicuo | Proyecto |
|---|---|---|---|---|
| **Infrastructure** | Docker Compose, Systemd, auto-inicio, gestión de contenedores | "docker", "contenedor", "auto-inicio", "systemd" | chappie-infrastructure |
| **Voice Capture** | Grabación de audio, control de volumen del micrófono, detección de atajos | "grabación", "captura", "walkie-talkie", "atajo" | chappie-daemon |
| **Audio Output Control** | Volume ducking, restauración de volumen, gestión de sinks de audio | "ducking", "sink", "volumen", "mute" | chappie-daemon, chappie-notification |
| **Speech-to-Text (STT)** | Transcripción de audio a texto | "transcripción", "STT", "audio", "texto" | chappie-daemon, n8n |
| **Text-to-Speech (TTS)** | Síntesis de voz, reproducción de audio | "voz", "TTS", "reproducción", "audio" | chappie-notification |
| **Orchestration** | Routing de prompts, gestión de workflows, procesamiento de JSON | "workflow", "pipeline", "enrutamiento" | chappie-n8n-workflows |
| **Agent Execution** | Ejecución de agentes OpenCode, comandos de terminal | "agente", "delegación", "comando", "ejecución" | chappie-notification |
| **Event Bus** | Colas de mensajes, publicación/suscripción de eventos | "evento", "cola", "publicar", "suscribir" | chappie-rabbitmq, chappie-notification |
| **Notification** | Notificaciones visuales, interactivas, widget de texto | "notificación", "alerta", "widget", "overlay" | chappie-notification, chappie-quickshell, SwayNC |
| **Memory** | Contexto conversacional, resúmenes, caducidad | "memoria", "contexto", "sesión", "historial" | chappie-n8n-workflows |
| **Configuration** | Proveedores, personalidades, dispositivos, whitelist | "configuración", "proveedor", "personalidad" | chappie-config |
| **Personality** | System prompt, tono, expresiones, identidad de Chappie | "personalidad", "Chappie", "Creador", "flow" | chappie-config |

### 1.2 Relaciones entre Contextos

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CONTEXT MAP                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐                                                   │
│  │  Voice Capture    │─────── Customer-Supplier ──────▶┌──────────────┐│
│  │  (chappie-daemon) │                                  │  STT          ││
│  └────────┬─────────┘                                  │  (n8n/Gemini) ││
│           │                                            └──────┬───────┘│
│           │ Upstream                                          │         │
│           ▼                                                   ▼         │
│  ┌──────────────────┐                           ┌──────────────────────┐│
│  │ Audio Output     │                           │  Orchestration       ││
│  │ Control          │                           │  (chappie-n8n)       ││
│  │ (daemon/notif)   │                           └──────────┬───────────┘│
│  └────────┬─────────┘                                      │            │
│           │                                                │            │
│           │ Shared Kernel                                  │ Customer-  │
│           ▼                                                │ Supplier   │
│  ┌──────────────────┐                                      ▼            │
│  │  Configuration   │                           ┌──────────────────────┐│
│  │  (chappie-config)│                           │  Agent Execution     ││
│  └────────┬─────────┘                           │  (chappie-notif)     ││
│           │                                     └──────────┬───────────┘│
│           │ Conformist                                      │            │
│           ▼                                                │            │
│  ┌──────────────────┐                                      │            │
│  │  Personality     │                           ┌──────────▼───────────┐│
│  │  (chappie-config)│                           │  Event Bus           ││
│  └──────────────────┘                           │  (RabbitMQ)          │││
│                                                  └──────────┬───────────┘│
│                                                             │            │
│                                                             ▼            │
│                                                  ┌──────────────────────┐│
│                                                  │  TTS                 ││
│                                                  │  (chappie-notif)     ││
│                                                  └──────────┬───────────┘│
│                                                             │            │
│                                                             ▼            │
│                                                  ┌──────────────────────┐│
│                                                  │  Notification        ││
│                                                  │  (SwayNC/Quickshell) ││
│                                                  └──────────────────────┘│
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Relaciones DDD Detalladas

### 2.1 Voice Capture → STT
- **Relación:** Customer-Supplier
- **Upstream:** Voice Capture (provee audio)
- **Downstream:** STT (consume audio, produce texto)
- **Contrato:** Audio en base64, formato WAV, 16kHz, mono
- **SLA:** Latencia < 5 segundos para clips de 30 segundos

### 2.2 STT → Orchestration
- **Relación:** Customer-Supplier
- **Upstream:** STT (provee texto transcrito)
- **Downstream:** Orchestration (consume texto, produce JSON estructurado)
- **Contrato:** Texto en español, sin formato especial
- **SLA:** Latencia < 10 segundos para procesamiento completo

### 2.3 Orchestration → Agent Execution
- **Relación:** Customer-Supplier
- **Upstream:** Orchestration (provee JSON con instrucciones)
- **Downstream:** Agent Execution (ejecuta agentes/comandos)
- **Contrato:** JSON con campos: voice_response, agent_call, terminal_command, notification
- **SLA:** Ejecución en background, notificación asíncrona

### 2.4 Agent Execution → Event Bus
- **Relación:** Published Language
- **Publica en:** chappie.responses, chappie.errors, chappie.agent.results
- **Schema:** JSON estructurado definido en integration-map.md

### 2.5 Event Bus → TTS
- **Relación:** Customer-Supplier
- **Upstream:** Event Bus (provee texto para dictar)
- **Downstream:** TTS (consume texto, produce audio)
- **Contrato:** Texto plano en español, sin emojis ni caracteres especiales
- **SLA:** Latencia < 3 segundos para generación de audio

### 2.6 Event Bus → Notification
- **Relación:** Customer-Supplier
- **Upstream:** Event Bus (provee eventos de notificación)
- **Downstream:** Notification (consume eventos, muestra notificaciones)
- **Contrato:** JSON con title, message, urgency, actions[]
- **SLA:** Notificación inmediata (< 1 segundo)

### 2.7 Configuration → Todos los Contextos
- **Relación:** Conformist
- **Todos los contextos** se adaptan a la configuración definida en chappie-config
- **No hay negociación:** Los contextos leen la configuración y se adaptan

### 2.8 Personality → Orchestration
- **Relación:** Customer-Supplier
- **Upstream:** Personality (provee system prompt)
- **Downstream:** Orchestration (usa system prompt para llamadas a modelos)
- **Contrato:** Texto plano con instrucciones de personalidad

### 2.9 Audio Output Control ↔ TTS
- **Relación:** Shared Kernel
- **Comparten:** Lógica de volume ducking
- **Implementación:** chappie-daemon y chappie-notification usan la misma configuración de tts-config.yaml

---

## 3. Anti-Corruption Layers

No se requieren ACLs en la arquitectura actual. Todos los contextos se comunican mediante contratos JSON bien definidos a través de RabbitMQ o HTTP.

Si en el futuro se integran nuevos proveedores de IA con formatos incompatibles, se creará un ACL en el contexto de Orchestration para adaptar los contratos.

---

## 4. Shared Kernel

| Shared Kernel | Contextos que lo comparten | Contenido |
|---|---|---|
| **tts-config.yaml** | Voice Capture, TTS, Audio Output Control | Configuración de volume ducking, proveedor TTS, voz |
| **providers.yaml** | STT, Orchestration, TTS | APIs de proveedores, modelos, endpoints |
| **commands-whitelist.yaml** | Agent Execution, Configuration | Lista de comandos permitidos |

---

## 5. Lenguaje Ubicuo Global

| Término | Definición | Contexto de uso |
|---|---|---|
| **Creador** | El usuario (Cris) | Personality, Notification |
| **Chappie** | El asistente de voz | Todos los contextos |
| **Grabación** | Captura de audio del micrófono | Voice Capture |
| **Ducking** | Reducción temporal de volumen | Audio Output Control, TTS |
| **Transcripción** | Conversión de audio a texto | STT |
| **Workflow** | Flujo de trabajo en n8n | Orchestration |
| **Agente** | Especialista de OpenCode | Agent Execution |
| **Evento** | Mensaje en RabbitMQ | Event Bus |
| **Notificación** | Alerta visual en SwayNC | Notification |
| **Widget** | Elemento visual en Quickshell | Notification |
| **Personalidad** | System prompt de Chappie | Personality |
| **Flow** | Expresión de Chappie para "estilo" | Personality |

---

## 6. Ownership

| Bounded Context | Owner Funcional | Owner Técnico |
|---|---|---|---|
| Infrastructure | Cris | chappie-infrastructure |
| Voice Capture | Cris | chappie-daemon |
| Audio Output Control | Cris | chappie-daemon, chappie-notification |
| STT | Cris | chappie-daemon, n8n |
| TTS | Cris | chappie-notification |
| Orchestration | Cris | chappie-n8n-workflows |
| Agent Execution | Cris | chappie-notification |
| Event Bus | Cris | chappie-rabbitmq, chappie-notification |
| Notification | Cris | chappie-notification, chappie-quickshell |
| Memory | Cris | chappie-n8n-workflows |
| Configuration | Cris | chappie-config |
| Personality | Cris | chappie-config |

---

*Documento mantenido por: Enterprise Architect*  
*Próxima revisión: Al completar Fase 1*
