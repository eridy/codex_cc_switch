# Claude/Codex API Smart Switch - Docker Image
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 创建必要的目录
RUN mkdir -p json_data logs

# 暴露端口
EXPOSE 5101

# 启动命令
CMD ["python", "app.py"]
