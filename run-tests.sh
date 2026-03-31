#!/bin/bash
# =============================================================
# Script de execução dos testes de performance - BlazeDemo
# Compatível com Linux e macOS
# =============================================================

set -e

JMETER_HOME="${JMETER_HOME:-$HOME/apache-jmeter-5.6.3}"
JMETER_BIN="$JMETER_HOME/bin/jmeter"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JMX_FILE="$SCRIPT_DIR/jmeter/blazedemo-performance.jmx"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
  echo -e "${BLUE}"
  echo "============================================================"
  echo "  🚀 BlazeDemo - Performance Test Suite"
  echo "  Critério: 250 req/s | P90 < 2000ms"
  echo "============================================================"
  echo -e "${NC}"
}

check_jmeter() {
  if [ ! -f "$JMETER_BIN" ]; then
    echo -e "${YELLOW}⚠️  JMeter não encontrado em: $JMETER_HOME${NC}"
    echo ""
    echo "Opções:"
    echo "  1. Defina a variável JMETER_HOME: export JMETER_HOME=/caminho/para/jmeter"
    echo "  2. Baixe o JMeter em: https://jmeter.apache.org/download_jmeter.cgi"
    echo ""
    echo "Instalação rápida (Linux/macOS):"
    echo "  wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.tgz"
    echo "  tar -xzf apache-jmeter-5.6.3.tgz -C ~/"
    exit 1
  fi
  echo -e "${GREEN}✅ JMeter encontrado: $JMETER_BIN${NC}"
  echo -e "   Versão: $($JMETER_BIN --version 2>&1 | head -1)"
}

run_load_test() {
  echo -e "\n${BLUE}📋 Iniciando TESTE DE CARGA...${NC}"
  echo "   Threads: 300 | Ramp-up: 120s | Duração: 480s"
  echo ""

  LOAD_RESULTS="$RESULTS_DIR/load-test-$TIMESTAMP"
  mkdir -p "$LOAD_RESULTS"

  "$JMETER_BIN" \
    -n \
    -t "$JMX_FILE" \
    -l "$LOAD_RESULTS/results.jtl" \
    -e \
    -o "$LOAD_RESULTS/html-report" \
    -j "$LOAD_RESULTS/jmeter.log" \
    2>&1 | tee "$LOAD_RESULTS/console.log"

  echo ""
  echo -e "${GREEN}✅ Load Test concluído!${NC}"
  echo -e "   📄 JTL: $LOAD_RESULTS/results.jtl"
  echo -e "   🌐 HTML Report: $LOAD_RESULTS/html-report/index.html"
}

run_spike_test() {
  echo -e "\n${BLUE}⚡ Iniciando TESTE DE PICO...${NC}"
  echo "   Threads: 600 | Ramp-up: 30s | Duração: 180s"
  echo ""

  SPIKE_RESULTS="$RESULTS_DIR/spike-test-$TIMESTAMP"
  mkdir -p "$SPIKE_RESULTS"

  "$JMETER_BIN" \
    -n \
    -t "$JMX_FILE" \
    -l "$SPIKE_RESULTS/results.jtl" \
    -e \
    -o "$SPIKE_RESULTS/html-report" \
    -j "$SPIKE_RESULTS/jmeter.log" \
    2>&1 | tee "$SPIKE_RESULTS/console.log"

  echo ""
  echo -e "${GREEN}✅ Spike Test concluído!${NC}"
  echo -e "   📄 JTL: $SPIKE_RESULTS/results.jtl"
  echo -e "   🌐 HTML Report: $SPIKE_RESULTS/html-report/index.html"
}

show_usage() {
  echo "Uso: $0 [load|spike|both]"
  echo ""
  echo "  load  - Executa apenas o teste de carga (padrão)"
  echo "  spike - Executa apenas o teste de pico"
  echo "  both  - Executa ambos os testes em sequência"
}

# Main
print_header
check_jmeter
mkdir -p "$RESULTS_DIR"

TEST_TYPE="${1:-load}"

case "$TEST_TYPE" in
  load)
    run_load_test
    ;;
  spike)
    run_spike_test
    ;;
  both)
    run_load_test
    run_spike_test
    ;;
  --help|-h)
    show_usage
    ;;
  *)
    echo -e "${RED}❌ Opção inválida: $TEST_TYPE${NC}"
    show_usage
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}============================================================"
echo "  ✅ Execução finalizada! Verifique os relatórios em:"
echo "     $RESULTS_DIR"
echo -e "============================================================${NC}"
