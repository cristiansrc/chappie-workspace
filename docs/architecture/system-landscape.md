# System Landscape - Chappie Ecosystem

**Estado:** Active  
**Owner:** Enterprise Architect  
**Última actualización:** 2026-06-14

---

## 1. Propósito del Sistema

Chappie es un ecosistema de asistente de voz personal con personalidad única (basada en el robot de la película CHAPPIE 2015), diseñado para operar en un entorno Linux/Hyprland. El sistema combina:
- Captura de voz por atajo de teclado (modo walkie-talkie)
- Transcripción de voz a texto (STT)
- Procesamiento inteligente con múltiples proveedores de IA
- Síntesis de voz (TTS) con control adaptativo de volumen
- Ejecución de agentes especializados de OpenCode
- Notificaciones interactivas y widget de texto visual

---

## 2. Usuarios y Actores

| Actor | Descripción | Interacción |
|---|---|---|
| **Cris (El Creador)** | Usuario principal, desarrollador de software | Interacción por voz mediante atajo de teclado |
| **Chappie (El Asistente)** | IA con personalidad de robot consciente | Responde por voz, ejecuta tareas, delega a agentes |
| **Agentes OpenCode** | Agentes especializados de desarrollo | Ejecutan tareas delegadas por Chappie |

---

## 3. Sistemas y Contenedores (C4 Level 2)

### 3.1 Sistemas Externos

| Sistema | Tipo | Propósito | Owner |
|---|---|---|---|
| **OpenCode API** | Cloud API | Acceso a modelos free (DeepSeek V4 Flash, Mimo V2.5, Qwen 3.6 Plus) | OpenCode |
| **Google Gemini API** | Cloud API | STT (Gemini 2.5 Flash) y modelos de procesamiento | Google |
| **Claude API** | Cloud API | Modelos de procesamiento (futuro) | Anthropic |
| **GPT API** | Cloud API | Modelos de procesamiento (futuro) | OpenAI |
| **Microsoft Edge TTS** | Cloud API | Síntesis de voz (es-AR-ElenaNeural) | Microsoft |
| **OpenCode CLI** | Local CLI | Ejecución de agentes especializados | Local |

### 3.2 Contenedores del Ecosistema Chappie

| Contenedor | Tecnología | Responsabilidad | Puerto |
|---|---|---|---|
| **chappie-infrastructure** | Docker Compose + Systemd | Orquestación de infraestructura: n8n + RabbitMQ + auto-inicio al boot | N/A |
| **chappie-daemon** | Python 3 + asyncio | Servicio de grabación, control de volumen, STT, reproducción TTS, escritura de estado | 8765 (HTTP API) |
| **chappie-n8n** | n8n (Node.js) | Orquestación de workflows: STT → Modelo → JSON → TTS | 5678 (Web UI) |
| **chappie-rabbitmq** | RabbitMQ 3.13 | Cola de mensajes para eventos, errores, TTS, notificaciones | 5672 (AMQP), 15672 (Management UI) |
| **chappie-notification** | Python 3 + pika | Consumer de RabbitMQ: ejecución de agentes, comandos, TTS, notificaciones | N/A |
| **chappie-quickshell** | QML/Qt6 | Widget de visualización de texto TTS y estado | N/A |
| **SwayNC** | C/GTK | Daemon de notificaciones con acciones interactivas | N/A |

### 3.3 Diagrama de Contenedores

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CHAPPIE ECOSYSTEM - CONTAINERS                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    LOCAL MACHINE (Hyprland)                       │  │
│  │                                                                   │  │
│  │  ┌─────────────────┐         ┌─────────────────────────────┐    │  │
│  │  │ chappie-daemon   │         │  chappie-quickshell         │    │  │
│  │  │                  │         │                             │    │  │
│  │  │ - Grabación audio│         │ - Widget texto TTS          │    │  │
│  │  │ - Volume ducking │         │ - Widget estado             │    │  │
│  │  │ - STT (Gemini)   │         │ - Toggle SUPER+ALT+T        │    │  │
│  │  │ - TTS Player     │         │                             │    │  │
│  │  │ - HTTP API:8765  │         │ Lee archivos de estado:     │    │  │
│  │  └────────┬─────────┘         │ /tmp/chappie_tts_text.txt   │    │  │
│  │           │                   │ /tmp/chappie_tts_state.txt  │    │  │
│  │           │ HTTP POST         └─────────────────────────────┘    │  │
│  │           ▼                                                       │  │
  │  │  ┌─────────────────────────────────────────────────────────┐     │  │
  │  │  │  chappie-infrastructure (Docker Compose + Systemd)        │     │  │
  │  │  │  Auto-inicio al boot vía systemd --user                   │     │  │
  │  │  │                                                          │     │  │
  │  │  │  ┌──────────────────┐    ┌────────────────────────┐    │     │  │
  │  │  │  │  chappie-n8n      │    │  chappie-rabbitmq      │    │     │  │
│  │  │  │                   │    │                        │    │     │  │
│  │  │  │  Workflows:       │    │  Queues:               │    │     │  │
│  │  │  │  - Voice Pipeline │    │  - chappie.responses   │    │     │  │
│  │  │  │  - Error Handler  │    │  - chappie.errors      │    │     │  │
│  │  │  │                   │    │  - chappie.tts.requests│    │     │  │
│  │  │  │                   │    │  - chappie.agent.*     │    │     │  │
│  │  │  │  Puerto: 5678     │    │  Puertos: 5672, 15672  │    │     │  │
│  │  │  └──────────────────┘    └────────────────────────┘    │     │  │
│  │  └─────────────────────────────────────────────────────────┘     │  │
│  │                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────┐     │  │
│  │  │  chappie-notification (Python Consumer)                  │     │  │
│  │  │                                                          │     │  │
│  │  │  - execution_consumer: Agentes + Comandos (background)  │     │  │
│  │  │  - error_consumer: Manejo de errores                    │     │  │
│  │  │  - tts_consumer: Genera y reproduce TTS                 │     │  │
│  │  │  - notification_consumer: SwayNC + Quickshell           │     │  │
│  │  └─────────────────────────────────────────────────────────┘     │  │
│  │                                                                   │  │
│  │  ┌─────────────────────────────────────────────────────────┐     │  │
│  │  │  SwayNC (Notification Daemon)                            │     │  │
│  │  │  - Notificaciones con acciones interactivas             │     │  │
│  │  │  - Centro de notificaciones                             │     │  │
│  │  └─────────────────────────────────────────────────────────┘     │  │
│  │                                                                   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                    EXTERNAL SERVICES (Cloud)                      │  │
│  │                                                                   │  │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────┐  │  │
│  │  │ OpenCode API │ │ Gemini API   │ │ Claude API   │ │ GPT API│  │  │
│  │  │ (free models)│ │ (STT + LLM)  │ │ (future)     │ │(future)│  │  │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └────────┘  │  │
│  │                                                                   │  │
│  │  ┌──────────────┐ ┌──────────────────────────────────────────┐   │  │
│  │  │ Edge TTS     │ │ OpenCode CLI (Local)                     │   │  │
│  │  │ (Microsoft)  │ │ - Agentes especializados                 │   │  │
│  │  └──────────────┘ │ - opencode run --agent <name> "<prompt>" │   │  │
│  │                    └──────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Flujos Principales

### 4.1 Flujo de Voz (Voice Loop)

```
1. USUARIO oprime SUPER+ALT+C (hold)
       │
       ▼
2. chappie-daemon detecta atajo
       ├──▶ Lee tts-config.yaml (volume ducking)
       ├──▶ BAJA volumen al 10% en TODOS los sinks activos
       ├──▶ Inicia grabación del micrófono
       │
       ▼
3. USUARIO suelta SUPER+ALT+C
       ├──▶ RESTAURA volumen original en TODOS los sinks
       ├──▶ Guarda WAV en /tmp/chappie_capture.wav
       │
       ▼
4. chappie-daemon envía audio a n8n
   POST http://localhost:5678/webhook/chappie-voice-capture
   Body: { audio_base64, timestamp, session_id, include_screen }
       │
       ▼
5. n8n WORKFLOW: "Chappie Voice Pipeline"
       ├──▶ STT → Gemini 2.5 Flash → texto transcrito
       ├──▶ Leer config (providers.yaml, personalities/chappie.yaml, memory/)
       ├──▶ Llamada al Modelo de Procesamiento → JSON estructurado
       ├──▶ Publicar en RabbitMQ: chappie.responses
       └──▶ Actualizar memoria
       │
       ▼
6. chappie-notification (execution_consumer) escucha chappie.responses
       ├──▶ Parsear JSON
       ├──▶ SI hay agent_call O terminal_command:
       │   ├──▶ Ejecutar en BACKGROUND
       │   ├──▶ SI comenzaron → Publicar en chappie.tts.requests
       │   └──▶ Monitorear: éxito → chappie.agent.results | error → chappie.errors
       └──▶ SI NO hay ejecución → Publicar en chappie.tts.requests
       │
        ▼
7. chappie-notification (tts_consumer) escucha chappie.tts.requests
       ├──▶ Generar audio con proveedor TTS configurado
       ├──▶ Guardar audio en /tmp/chappie_tts.mp3
       ├──▶ Escribir texto en /tmp/chappie_tts_text.txt
       └──▶ Enviar a chappie-daemon: POST /play-tts
               Body: { audio_file: "/tmp/chappie_tts.mp3", text: "...", ducking: true }
       │
       ▼
8. chappie-daemon procesa POST /play-tts
       ├──▶ Leer tts-config.yaml (volume_ducking config)
       ├──▶ BAJA volumen al 10% en TODOS los sinks activos
       ├──▶ Escribir estado "speaking" en /tmp/chappie_tts_state.txt
       ├──▶ Reproducir audio
       ├──▶ Esperar fin de reproducción
       ├──▶ RESTAURA volumen original
       └──▶ Escribir estado "idle" en /tmp/chappie_tts_state.txt
       │
       ▼
9. chappie-quickshell lee archivos de estado
       ├──▶ Muestra texto de Chappie en widget
       └──▶ Oculta widget cuando estado = "idle"
```

### 4.2 Flujo de Error

```
1. execution_consumer detecta error
       │
       ▼
2. Publica en chappie.errors
   { original_request, error, context }
       │
       ▼
3. error_consumer escucha chappie.errors
       ├──▶ NO reproducir voz original
       ├──▶ Llamar a n8n webhook: chappie-error-handler
       ├──▶ n8n workflow "Error Handler":
       │   ├──▶ Modelo genera nueva respuesta con pregunta
       │   └──▶ n8n publica directamente en chappie.tts.requests (RabbitMQ)
       └──▶ [Fin] error_consumer no publica en TTS
```

### 4.3 Flujo de Notificación Interactiva

```
1. Agente necesita preguntar algo
       │
       ▼
2. Publica en chappie.agent.questions
   { agent, question, options[], notification_id }
       │
       ▼
3. notification_consumer crea notificación SwayNC
   notify-send "Chappie necesita tu atención" \
     "..." --action="opt1=Opción 1" --action="opt2=Opción 2"
       │
       ▼
4. USUARIO hace clic en un botón
       │
       ▼
5. notification_consumer captura acción
       └──▶ Publica en chappie.agent.answers
           { notification_id, answer }
```

---

## 5. Dependencias Externas

| Dependencia | Tipo | Criticalidad | Fallback |
|---|---|---|---|
| Internet | Red | Alta | Whisper local para STT |
| Docker | Runtime | Alta | N/A |
| PipeWire/WirePlumber | Audio | Alta | ALSA fallback |
| Hyprland | Compositor | Alta | N/A |
| OpenCode CLI | Local binary | Media | N/A |

---

## 6. Requisitos de Infraestructura

| Recurso | Mínimo | Recomendado |
|---|---|---|
| RAM | 4 GB libres | 8 GB libres |
| Disco | 2 GB | 5 GB |
| CPU | 2 cores | 4 cores |
| Red | 10 Mbps | 50 Mbps |
| Micrófono | 1 | 1+ |
| Altavoces/Audífonos | 1 | 1+ |

---

## 7. Seguridad

| Aspecto | Implementación |
|---|---|
| API Keys | Variables de entorno en Docker Compose |
| Comandos de terminal | Whitelist estricta en commands-whitelist.yaml |
| Sin sudo | Todos los comandos sin privilegios elevados |
| RabbitMQ Auth | Usuario/contraseña en variables de entorno |
| n8n Auth | Basic auth o API key |

---

## 8. Observabilidad

| Componente | Métrica |
|---|---|
| chappie-infrastructure | systemctl --user status chappie-infra, docker compose ps, docker compose logs |
| chappie-daemon | Logs en journalctl, estado en /tmp/chappie_state |
| n8n | Logs en Docker, Execution History en Web UI |
| RabbitMQ | Management UI en puerto 15672 |
| chappie-notification | Logs en journalctl |

---

*Documento mantenido por: Enterprise Architect*  
*Próxima revisión: Al completar Fase 1*
