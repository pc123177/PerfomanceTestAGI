# 🚀 BlazeDemo - Teste de Performance com JMeter

Projeto de testes de performance para o site [BlazeDemo](https://www.blazedemo.com), simulando o fluxo completo de **compra de passagem aérea**.

---

## 📋 Índice

- [Cenário Testado](#cenario-testado)
- [Critério de Aceitação](#criterio-de-aceitacao)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pre-requisitos)
- [Configuração do Ambiente](#configuracao-do-ambiente)
- [Execução dos Testes](#execucao-dos-testes)
- [Estratégia de Testes](#estrategia-de-testes)
- [Relatório de Execução](#relatorio-de-execucao)
- [Análise e Conclusão](#analise-e-conclusao)
- [Pipeline CI/CD](#pipeline-cicd)

---

## 🎯 Cenário testado {#cenario-testado}

**URL:** `https://www.blazedemo.com`

O teste simula o fluxo completo de compra de passagem aérea, composto por 4 transações encadeadas:

| #   | Transação                    | Método | Endpoint            |
| --- | ---------------------------- | ------ | ------------------- |
| T01 | Acessar Home Page            | GET    | `/`                 |
| T02 | Buscar Voos (Paris → London) | POST   | `/reserve.php`      |
| T03 | Selecionar Voo               | POST   | `/purchase.php`     |
| T04 | Confirmar Compra             | POST   | `/confirmation.php` |

**Validações em cada transação:**

- ✅ HTTP 200 OK
- ✅ Conteúdo esperado presente na resposta (assertions)
- ✅ Tempo de resposta < 2000ms

---

## ✅ Critério de aceitação {#criterio-de-aceitacao}

> **250 requisições por segundo** com **tempo de resposta P90 inferior a 2 segundos**.

---

## 📁 Estrutura do Projeto {#estrutura-do-projeto}

```text
blazedemo-performance/
├── jmeter/
│   └── blazedemo-performance.jmx   # Script JMeter (Load + Spike Tests)
├── results/                         # Resultados gerados após execução
│   ├── load-test-results.jtl
│   ├── spike-test-results.jtl
│   └── *-html-report/              # Relatórios HTML interativos
├── run-tests.sh                    # Script de execução (Linux/macOS)
├── run-tests.bat                   # Script de execução (Windows)
└── README.md
```

---

## 🛠 Pré-requisitos {#pre-requisitos}

| Ferramenta     | Versão Mínima        | Download                                                           |
| -------------- | -------------------- | ------------------------------------------------------------------ |
| Java (JDK/JRE) | 8+ (recomendado 11+) | [adoptium.net](https://adoptium.net/)                              |
| Apache JMeter  | 5.6+                 | [jmeter.apache.org](https://jmeter.apache.org/download_jmeter.cgi) |

**Verificar instalações:**

```bash
java -version
# java version "11.x.x" ...

~/apache-jmeter-5.6.3/bin/jmeter --version
# Version 5.6.3
```

---

## ⚙️ Configuração do ambiente {#configuracao-do-ambiente}

### 1. Clonar o repositório

```bash
git clone https://github.com/pc123177/PerfomanceTestAGI.git
cd PerfomanceTestAGI
```

### 2. Baixar e instalar o JMeter

**Linux / macOS:**

```bash
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz -C ~/
```

**Windows:**  
Baixe o `.zip` em [jmeter.apache.org](https://jmeter.apache.org/download_jmeter.cgi) e extraia em `C:\apache-jmeter-5.6.3`.

### 3. (Opcional) Configurar variável de ambiente

```bash
# Linux / macOS — adicione ao ~/.bashrc ou ~/.zshrc
export JMETER_HOME=~/apache-jmeter-5.6.3

# Windows (PowerShell)
$env:JMETER_HOME = "C:\apache-jmeter-5.6.3"
```

---

## ▶️ Execução dos testes {#execucao-dos-testes}

### Linux / macOS

```bash
# Dar permissão de execução (apenas na primeira vez)
chmod +x run-tests.sh

# Teste de Carga (padrão)
./run-tests.sh load

# Teste de Pico
./run-tests.sh spike

# Ambos em sequência
./run-tests.sh both
```

### Windows

```bat
REM Teste de Carga
run-tests.bat load

REM Teste de Pico
run-tests.bat spike

REM Ambos em sequência
run-tests.bat both
```

### Linha de comando direta (JMeter)

```bash
# Teste de Carga
$JMETER_HOME/bin/jmeter \
  -n \
  -t jmeter/blazedemo-performance.jmx \
  -l results/load-results.jtl \
  -e -o results/load-html-report

# Visualizar no JMeter GUI (para debug)
$JMETER_HOME/bin/jmeter -t jmeter/blazedemo-performance.jmx
```

### Visualizar relatório HTML

Após a execução, abra no navegador:

```text
file:///results/load-test-<timestamp>/html-report/index.html
```

---

## 🧪 Estratégia de testes {#estrategia-de-testes}

### Teste de Carga (Load Test)

Valida o comportamento da aplicação sob carga **sustentada e esperada**.

| Parâmetro                   | Valor                    |
| --------------------------- | ------------------------ |
| Usuários virtuais (threads) | 300                      |
| Ramp-up                     | 120 segundos (2 min)     |
| Duração                     | 480 segundos (8 min)     |
| Meta de throughput          | ~250 req/s               |
| Think time                  | 1–3 segundos (aleatório) |

> **Cálculo:** 300 threads × 4 req/fluxo ÷ (tempo de resposta médio + think time) ≈ 250 req/s

### Teste de Pico (Spike Test)

Valida o comportamento da aplicação diante de um **aumento súbito e agressivo** de tráfego (2× a carga normal).

| Parâmetro                   | Valor                       |
| --------------------------- | --------------------------- |
| Usuários virtuais (threads) | 600                         |
| Ramp-up                     | 30 segundos (spike abrupto) |
| Duração                     | 180 segundos (3 min)        |
| Meta de throughput          | ~500 req/s                  |
| Think time                  | 500ms (constante)           |