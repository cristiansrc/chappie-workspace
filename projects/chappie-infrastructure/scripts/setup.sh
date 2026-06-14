#!/usr/bin/env bash
# ============================================
# Chappie Infrastructure - Setup Script
# ============================================
# Este script configura la infraestructura base de Chappie:
# 1. Verifica/instala Docker + Docker Compose
# 2. Copia .env.example → .env (si no existe)
# 3. Instala y habilita el servicio systemd para auto-inicio
# 4. Inicia los servicios de infraestructura
#
# Uso: ./setup.sh
# ============================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SYSTEMD_DIR="${HOME}/.config/systemd/user"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Chappie Infrastructure - Setup${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# ────────────────────────────────────────────
# 1. Verificar Docker
# ────────────────────────────────────────────
echo -e "${YELLOW}[1/4] Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker no está instalado.${NC}"
    echo "Instala Docker primero: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose no está disponible.${NC}"
    echo "Instala Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}  ✔ Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1)${NC}"
echo -e "${GREEN}  ✔ Docker Compose $(docker compose version --short)${NC}"
echo ""

# ────────────────────────────────────────────
# 2. Configurar .env
# ────────────────────────────────────────────
echo -e "${YELLOW}[2/4] Configurando variables de entorno...${NC}"
if [ ! -f "${PROJECT_DIR}/.env" ]; then
    cp "${PROJECT_DIR}/.env.example" "${PROJECT_DIR}/.env"
    echo -e "${YELLOW}  ⚠ Archivo .env creado desde .env.example${NC}"
    echo -e "${YELLOW}  ⚠ Edita ${PROJECT_DIR}/.env con tus API keys antes de iniciar${NC}"
else
    echo -e "${GREEN}  ✔ .env ya existe${NC}"
fi
echo ""

# ────────────────────────────────────────────
# 3. Instalar y habilitar servicio systemd
# ────────────────────────────────────────────
echo -e "${YELLOW}[3/4] Configurando auto-inicio con systemd...${NC}"

mkdir -p "${SYSTEMD_DIR}"

SERVICE_FILE="${SYSTEMD_DIR}/chappie-infra.service"
cp "${SCRIPT_DIR}/../systemd/chappie-infra.service" "${SERVICE_FILE}"

# Reemplazar %h por el HOME real en el archivo de servicio
sed -i "s|%h|${HOME}|g" "${SERVICE_FILE}"

# Recargar systemd y habilitar el servicio
systemctl --user daemon-reload
systemctl --user enable chappie-infra.service

echo -e "${GREEN}  ✔ Servicio systemd instalado en ${SERVICE_FILE}${NC}"
echo -e "${GREEN}  ✔ Auto-inicio habilitado (se inicia al prender el PC)${NC}"
echo ""

# ────────────────────────────────────────────
# 4. Iniciar servicios ahora
# ────────────────────────────────────────────
echo -e "${YELLOW}[4/4] Iniciando servicios de infraestructura...${NC}"

cd "${PROJECT_DIR}"
docker compose up -d

echo -e "${GREEN}  ✔ Servicios iniciados:${NC}"
echo -e "${GREEN}    - n8n:            http://localhost:5678${NC}"
echo -e "${GREEN}    - RabbitMQ:       http://localhost:15672 (user: chappie)${NC}"
echo -e "${GREEN}    - RabbitMQ AMQP:  localhost:5672${NC}"
echo ""

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Setup completado exitosamente ✓${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Comandos útiles:"
echo "  systemctl --user status chappie-infra   # Ver estado"
echo "  systemctl --user stop chappie-infra     # Detener servicios"
echo "  systemctl --user start chappie-infra    # Iniciar servicios"
echo "  docker compose logs -f                  # Ver logs"
echo "  docker compose ps                       # Ver contenedores"
echo ""
echo "Próximo paso: Configurar API keys en ${PROJECT_DIR}/.env"
