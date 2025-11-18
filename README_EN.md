# Claude/Codex API Proxy - Complete Usage Guide

> **Universal API Proxy** - Supports Claude Code, Codex CLI, and OpenAI format with intelligent routing and format conversion

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)](https://fastapi.tiangolo.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**English** | [简体中文](./README.md)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Core Features](#core-features)
- [Quick Start](#quick-start)
- [Client Configuration Examples](#client-configuration-examples)
  - [Claude Code CLI Configuration](#claude-code-cli-configuration)
  - [Codex CLI Configuration](#codex-cli-configuration)
  - [Python OpenAI SDK Configuration](#python-openai-sdk-configuration)
- [API Endpoints](#api-endpoints)
- [Requirements](#requirements)

---

## Project Overview

This is a fully-featured **multi-protocol API proxy server** that supports:

- ✅ **Claude Code API** - Proxy with multi-key rotation
- ✅ **Codex CLI API** - Complete proxy (GPT-5-Codex)
- ✅ **OpenAI Format** - Auto-conversion to Claude format
- ✅ **Smart Failover** - Auto-switch, retry, cooldown management
- ✅ **Real-time Stats** - Token usage tracking and visualization
- ✅ **Web Management** - Graphical configuration interface

**Port**: `5101`
**Protocol**: HTTP/HTTPS
**Start Command**: `python app.py`

---

## Core Features

### 🔄 Intelligent Multi-API Management
- **Multi-config Support**: Configure multiple Claude and Codex APIs
- **Primary-Backup Switch**: Auto-switch to backup when primary fails
- **Time-based Enable**: Enable different APIs by day of week (Mon-Sun)
- **Priority Scheduling**: Auto-select optimal API by config order
- **Scheduled Activation**: Auto-activate API billing at specified times

### 🛡️ Smart Failover Mechanism
- **Error Detection**: Real-time API error detection and logging
- **Auto-switch**: Switch API when consecutive errors reach threshold
- **Cooldown Management**: Failed APIs enter cooldown to avoid frequent calls
- **Retry Strategies**: Strategy retry, normal retry, switch retry
- **Timeout Control**: Fine-grained timeout configuration

### 📊 Real-time Statistics & Monitoring
- **Token Statistics**: Auto-track token usage per request
- **Per-model Stats**: Separate statistics for different models
- **Daily Statistics**: Daily usage tracking and visualization
- **Cache Statistics**: Separate new input, output, cache creation, cache read

### 🔧 Flexible Configuration
- **Web Management UI**: Graphical configuration for all parameters
- **Hot Reload**: Apply config changes without restart
- **JSON Config**: All configs saved in `json_data/all_configs.json`

---

## Quick Start

### 1. Clone the Project

```bash
git clone git@github.com:cd555yong/codex_cc_switch.git
cd codex_cc_switch
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

Or install manually:
```bash
pip install fastapi uvicorn httpx
```

### 3. Start Service

```bash
python app.py
```

After starting, you'll see:
```
============================================================
Claude Code API Server Startup
============================================================
API Rotation Config:
  Primary APIs (by config priority):
    Priority#1: Monday KEY | https://api-provider-1.example.com
    ...
  Backup APIs (available all week):
    Backup API: https://api-provider-2.example.com/code
    ...
Port: 5101
============================================================
```

### 3. Access Admin Panel

Open browser and visit: `http://localhost:5101`

You can manage:
- API configs (Claude and Codex)
- OpenAI to Claude configs
- Timeout retry strategies
- Model conversion rules
- Error handling strategies
- Token usage statistics

---

## Client Configuration Examples

### Claude Code CLI Configuration

**Config file location**: `~/.claude/settings.json` (Windows: `C:\Users\username\.claude\settings.json`)

**Config content**:
```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "123",
    "ANTHROPIC_BASE_URL": "http://localhost:5101/api",
    "CLAUDE_CODE_MAX_THINKING_TOKENS": "32000",
    "MAX_THINKING_TOKENS": "32000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "API_TIMEOUT_MS": "600000"
  },
  "permissions": {
    "allow": [],
    "deny": []
  }
}
```

**Field descriptions**:
- `ANTHROPIC_AUTH_TOKEN`: User key (needs to be mapped in proxy service's app.py)
- `ANTHROPIC_BASE_URL`: Proxy service address (note the `/api` path)
- `CLAUDE_CODE_MAX_THINKING_TOKENS`: Max tokens for thinking mode
- `API_TIMEOUT_MS`: API timeout in milliseconds

**Usage**:
```bash
# After configuration, use Claude Code CLI directly
claude "Please analyze this project's code structure"
```

---

### Codex CLI Configuration

**Config file location**: `~/.codex/config.toml` (Windows: `C:\Users\username\.codex\config.toml`)

**Config content**:
```toml
model_provider = "code"
model = "gpt-5.1-codex"
model_reasoning_effort = "high"
model_verbosity = "high"
disable_response_storage = true
windows_wsl_setup_acknowledged = true

[http]
# Disable system proxy to avoid conflicts with custom HTTPS endpoint
proxy = "no_proxy"

[model_providers.code]
name = "code"
base_url = "http://localhost:5101/openai"
wire_api = "responses"
requires_openai_auth = true  # Important: enables model switching

[projects.'project_path']
trust_level = "trusted"

[notice]
hide_gpt5_1_migration_prompt = true
```

**Field descriptions**:
- `model`: Codex model name (gpt-5.1-codex or gpt-5-codex)
- `base_url`: Proxy service address (note the `/openai` path)
- `wire_api`: Use responses protocol
- `requires_openai_auth`: Must be true for model switching support

**Usage**:
```bash
# After configuration, use Codex CLI directly
codex "Please refactor this code"
```

---

### Python OpenAI SDK Configuration

#### Method 1: Using OpenAI SDK (Recommended)

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Use OpenAI SDK to call Claude API (via proxy service)
Supports non-streaming and streaming responses
"""

from openai import OpenAI
import sys
import io

# Windows console UTF-8 support
if sys.platform == 'win32':
    try:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')
    except AttributeError:
        pass

# Configuration
BASE_URL = "http://localhost:5101"
API_KEY = "123"  # User key (configure in proxy service)
MODEL = "claude-sonnet-4-5-20250929"  # Or use "gpt-4" for auto-conversion

# Create client
client = OpenAI(
    api_key=API_KEY,
    base_url=f"{BASE_URL}/v1"
)

# Example 1: Non-streaming response
print("=" * 60)
print("Test 1: Non-streaming response")
print("=" * 60)

response = client.chat.completions.create(
    model=MODEL,
    messages=[
        {"role": "system", "content": "You are a programming assistant"},
        {"role": "user", "content": "Hello, please say a sentence"}
    ],
    stream=False,
    max_tokens=100
)

print(f"\nResponse: {response.choices[0].message.content}")
print(f"Token usage: {response.usage.total_tokens}")


# Example 2: Streaming response
print("\n" + "=" * 60)
print("Test 2: Streaming response")
print("=" * 60)

stream = client.chat.completions.create(
    model=MODEL,
    messages=[
        {"role": "user", "content": "Please write a short poem about spring"}
    ],
    stream=True,
    max_tokens=500
)

print("\nStreaming response:")
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='', flush=True)

print("\n\n✅ Test complete!")
```

#### Method 2: Using requests library (for debugging)

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Use requests library for direct calls (for debugging streaming response issues)
"""

import requests
import json
import sys
import io

# Windows console UTF-8 support
if sys.platform == 'win32':
    try:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    except AttributeError:
        pass

# Configuration
BASE_URL = "http://localhost:5101"
API_KEY = "123"
MODEL = "claude-sonnet-4-5-20250929"

url = f"{BASE_URL}/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

data = {
    "model": MODEL,
    "messages": [
        {"role": "user", "content": "Please say a sentence"}
    ],
    "stream": True,
    "max_tokens": 100
}

print(f"Sending streaming request to: {url}")
print(f"Model: {MODEL}\n")

try:
    response = requests.post(url, headers=headers, json=data, stream=True, timeout=30)

    print(f"Response status: {response.status_code}")
    print(f"Reading streaming response:\n")
    print("-" * 60)

    # Read SSE streaming response line by line
    for line in response.iter_lines():
        if line:
            line_str = line.decode('utf-8')

            # Parse SSE format: data: {...}
            if line_str.startswith('data: '):
                data_str = line_str[6:]

                # Skip [DONE] marker
                if data_str == '[DONE]':
                    continue

                try:
                    # Parse JSON and extract content
                    chunk_obj = json.loads(data_str)
                    if 'choices' in chunk_obj and len(chunk_obj['choices']) > 0:
                        delta = chunk_obj['choices'][0].get('delta', {})
                        content = delta.get('content', '')
                        if content:
                            print(content, end='', flush=True)
                except json.JSONDecodeError:
                    pass

    print("\n" + "-" * 60)
    print("\n✅ Read complete")

except Exception as e:
    print(f"\n❌ Error: {e}")
```

**Configuration notes**:
- `BASE_URL`: Proxy service address `http://localhost:5101`
- `API_KEY`: User key, needs mapping in app.py's `USER_KEY_MAPPING`
- `MODEL`: Can use Claude model name or GPT model name (auto-converted)

**Supported model names**:
- `claude-sonnet-4-5-20250929` - Claude 4.5 Sonnet (direct)
- `gpt-4` - Auto-converted to Claude 4.0 Sonnet
- `gpt-4-turbo` - Auto-converted to Claude 4.0 Sonnet
- `gpt-3.5-turbo` - Auto-converted to Claude 4.0 Sonnet

**Thinking mode**:
```python
# Enable thinking mode - add -thinking to model name
MODEL = "claude-sonnet-4-5-20250929-thinking"
# Note: temperature must be 1 in thinking mode
```

---

## API Endpoints

- `POST /v1/messages` - Claude direct
- `POST /v1/chat/completions` - OpenAI to Claude
- `POST /openai/responses` - Codex direct
- `GET /` - Web admin home
- `GET /token-stats.html` - Token statistics page
- `GET /api/configs` - Get API configs
- `POST /api/reload` - Reload configs
- `GET /api/token-stats` - Get token statistics
- `POST /api/token-stats/reset` - Reset statistics

---

## Requirements

- Python 3.8+
- FastAPI 0.100+
- httpx 0.24+
- uvicorn 0.22+

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit Issues and Pull Requests.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

**Version**: 1.0
**Port**: 5101
**Repository**: https://github.com/cd555yong/codex_cc_switch

🚀 Generated with [Claude Code](https://claude.com/claude-code)
