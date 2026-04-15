#!/bin/bash
set -e

# 执行数据库迁移
echo "正在执行数据库迁移..."
python manage.py migrate --no-input

# 收集静态文件
echo "正在收集静态文件..."
python manage.py collectstatic --no-input

# 启动应用
echo "正在启动应用..."
exec gunicorn --bind 0.0.0.0:"$PORT" learning_log.wsgi:application