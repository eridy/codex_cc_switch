# Claude/Codex API Smart Switch

> **Intelligent Multi-API Gateway** - Supports Claude Code, Codex CLI, and OpenAI format with smart routing and failover

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🌟 Features

### 🔄 Intelligent API Management
- **Multi-API Support**: Configure multiple Claude and Codex API keys
- **Smart Failover**: Auto-switch to backup APIs on errors (3-error threshold)
- **Priority Scheduling**: Automatic API selection by priority order
- **Time-based Rotation**: Enable APIs by day of week (Monday-Sunday)
- **Scheduled Activation**: Auto-activate API billing cycles at specified times

### 🛡️ Advanced Error Handling
- **Real-time Error Detection**: Monitor API errors and response quality
- **Auto-switching**: Switch APIs when error threshold reached
- **Cooldown Management**: 10-minute cooldown for failed APIs
- **Retry Strategies**: Strategy retry, normal retry, and API switching
- **Timeout Control**: Fine-grained timeout configuration

### 📊 Real-time Monitoring
- **Token Statistics**: Track token usage per model and date
- **Cache Analytics**: Separate stats for input, output, cache creation, cache read
- **Web Dashboard**: Graphical configuration and monitoring interface
- **Daily Reports**: Visualize usage patterns with charts

### 🔧 Flexible Configuration
- **Web UI**: Manage all settings via browser
- **Hot Reload**: Apply configuration changes without restart
- **JSON Storage**: All configs saved in `json_data/all_configs.json`

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- pip package manager

### Installation

1. **Clone the repository**
```bash
git clone git@github.com:cd555yong/codex_cc_switch.git
cd codex_cc_switch
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure API keys**

   Edit `json_data/all_configs.json` or use the web interface after starting the server.

4. **Start the server**
```bash
python app.py
```

The server will start on port **5101**.

5. **Access Web Dashboard**

   Open your browser and visit: `http://localhost:5101`

---

## 📖 Usage

### 1. Claude Code Direct Mode

**Endpoint**: `POST /v1/messages`

**Example** (Python):
```python
import httpx

url = "http://localhost:5101/v1/messages"
headers = {
    "authorization": "Bearer YOUR_KEY",
    "content-type": "application/json",
    "anthropic-version": "2023-06-01"
}

data = {
    "model": "claude-sonnet-4-5-20250929",
    "max_tokens": 8192,
    "messages": [
        {
            "role": "user",
            "content": [{"type": "text", "text": "Hello!"}]
        }
    ],
    "stream": True
}

with httpx.Client() as client:
    with client.stream("POST", url, json=data, headers=headers) as response:
        for line in response.iter_lines():
            print(line)
```

### 2. Codex CLI Direct Mode

**Endpoint**: `POST /openai/responses`

**Example** (Python):
```python
import httpx

url = "http://localhost:5101/openai/responses"
data = {
    "model": "gpt-5-codex",
    "input": [
        {
            "type": "message",
            "role": "user",
            "content": [{"type": "input_text", "text": "Analyze this code"}]
        }
    ],
    "stream": True
}

headers = {
    "authorization": "Bearer YOUR_KEY",
    "content-type": "application/json"
}

with httpx.Client() as client:
    with client.stream("POST", url, json=data, headers=headers) as response:
        for line in response.iter_lines():
            print(line)
```

### 3. OpenAI Format Conversion Mode

**Endpoint**: `POST /v1/chat/completions`

**Example** (Python):
```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_KEY",
    base_url="http://localhost:5101/v1"
)

response = client.chat.completions.create(
    model="gpt-4",  # Auto-converted to Claude model
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "Hello!"}
    ],
    stream=True
)

for chunk in response:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='', flush=True)
```

---

## 🎯 Configuration

### Web Dashboard

Access `http://localhost:5101` to manage:

- **API Configs**: Claude and Codex API keys, priorities, time-based activation
- **OpenAI Conversion**: Dedicated configs for OpenAI format conversion
- **Retry Strategies**: Configure multiple retry strategies with different timeouts
- **Model Conversions**: Auto-convert model names (e.g., gpt-4 → claude-sonnet-4)
- **Error Handling**: Configure HTTP status code handling strategies
- **Timeout Settings**: Connection, read, write timeouts for different scenarios
- **Token Statistics**: Real-time token usage charts and reports

### Configuration File

All settings are stored in `json_data/all_configs.json`:

```json
{
  "api_configs": [...],
  "codex_configs": [...],
  "openai_to_claude_configs": [...],
  "retry_configs": [...],
  "model_conversions": [...],
  "timeout_settings": {...},
  "error_handling_strategies": {...}
}
```

---

## 🔧 Architecture

### Tech Stack

- **Framework**: FastAPI (async web framework)
- **HTTP Client**: httpx (async HTTP)
- **Config Management**: JSON file-based
- **Logging**: Python logging module
- **Statistics**: Custom token tracking module

### Core Modules

1. **app.py** - FastAPI application, API routing, reverse proxy, failover logic
2. **config_manager.py** - Unified configuration management, JSON persistence
3. **openai_adapter.py** - OpenAI→Claude format conversion, thinking mode support
4. **openai_to_codex.py** - OpenAI→Codex format conversion, full Codex protocol
5. **token_stats.py** - Token usage tracking, real-time aggregation

### Data Flow

```
Client Request
  ↓
Path Recognition (/v1/messages | /v1/chat/completions | /openai/responses)
  ↓
Format Conversion (OpenAI→Claude | OpenAI→Codex | Direct)
  ↓
API Selection (Primary → Backup → Retry Strategy)
  ↓
Request Forwarding (Streaming/Non-streaming)
  ↓
Error Handling (Detect → Record → Switch/Retry)
  ↓
Response Conversion (Claude→OpenAI | Codex→OpenAI | Direct)
  ↓
Token Statistics (Extract usage → Record → Aggregate)
  ↓
Return to Client
```

---

## 📝 Documentation

For detailed documentation in Chinese, see [使用说明.md](./使用说明.md).

Topics covered:
- Client configuration (Claude Code CLI, Codex CLI, Python SDK)
- Advanced API management
- Smart failover mechanisms
- Token statistics and monitoring
- Troubleshooting FAQ
- Maintenance and operations

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Anthropic](https://www.anthropic.com/) - Claude API
- [OpenAI](https://openai.com/) - Codex CLI
- [FastAPI](https://fastapi.tiangolo.com/) - Modern web framework
- [httpx](https://www.python-httpx.org/) - HTTP client library

---

**Version**: 1.0
**Port**: 5101
**Repository**: https://github.com/cd555yong/codex_cc_switch

🚀 Generated with [Claude Code](https://claude.com/claude-code)
