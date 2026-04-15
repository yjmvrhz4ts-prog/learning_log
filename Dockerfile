# 使用官方Python运行时作为基础镜像
FROM python:3.11-slim

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 设置工作目录
WORKDIR /app

# 复制项目依赖文件
COPY requirements.txt /app/

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . /app/

# 创建静态文件目录
RUN mkdir -p staticfiles

# 给entrypoint脚本添加执行权限
RUN chmod +x /app/entrypoint.sh

# 指定端口（Railway提供的端口）
ENV PORT=8000
ENV HOST=0.0.0.0

# 暴露端口
EXPOSE $PORT

# 使用entrypoint脚本
ENTRYPOINT ["/app/entrypoint.sh"]