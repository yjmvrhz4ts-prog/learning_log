#!/bin/bash

# Learning Log Django项目部署脚本
# 适用于腾讯云Ubuntu服务器

set -e  # 遇到错误时停止执行

echo "开始部署Learning Log Django项目..."

# 1. 更新系统包列表
echo "更新系统包..."
sudo apt update

# 2. 安装Python和必要组件
echo "安装Python3和pip..."
sudo apt install -y python3 python3-pip python3-venv nginx supervisor

# 3. 创建项目目录
PROJECT_DIR="/var/www/learning_log"
echo "创建项目目录: $PROJECT_DIR"
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

# 4. 复制项目文件到目标目录
echo "复制项目文件..."
rsync -av --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' . $PROJECT_DIR/

# 5. 创建并激活虚拟环境
echo "创建虚拟环境..."
cd $PROJECT_DIR
python3 -m venv venv
source venv/bin/activate

# 6. 升级pip并安装依赖
echo "安装项目依赖..."
pip install --upgrade pip
pip install -r requirements.txt

# 7. 收集静态文件
echo "收集静态文件..."
python manage.py collectstatic --noinput

# 8. 迁移数据库
echo "执行数据库迁移..."
python manage.py migrate --noinput

# 9. 创建超级用户（如果不存在）
echo "检查并创建超级用户..."
python manage.py shell << EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(is_superuser=True).exists():
    username = input("输入管理员用户名: ")
    email = input("输入管理员邮箱: ")
    password = input("输入管理员密码: ")
    User.objects.create_superuser(username, email, password)
    print(f"超级用户 {username} 已创建")
else:
    print("已存在超级用户，跳过创建")
EOF

# 10. 配置Gunicorn
echo "配置Gunicorn..."
cat > /var/www/learning_log/gunicorn_config.py << 'GUNICORN_EOF'
bind = "127.0.0.1:8000"
workers = 3
timeout = 120
keepalive = 2
max_requests = 1000
max_requests_jitter = 100
preload_app = True
worker_class = 'sync'
worker_connections = 1000
user = 'www-data'
group = 'www-data'
tmp_upload_dir = None
errorlog = '/var/log/gunicorn/error.log'
accesslog = '/var/log/gunicorn/access.log'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
loglevel = 'info'
GUNICORN_EOF

# 11. 创建日志目录
sudo mkdir -p /var/log/gunicorn
sudo chown www-data:www-data /var/log/gunicorn

# 12. 配置Supervisor
echo "配置Supervisor..."
sudo tee /etc/supervisor/conf.d/learning_log.conf > /dev/null << SUPER_EOF
[program:learning_log]
command=/var/www/learning_log/venv/bin/gunicorn --config /var/www/learning_log/gunicorn_config.py learning_log.wsgi:application
directory=/var/www/learning_log
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/gunicorn/app.log
environment=PATH="/var/www/learning_log/venv/bin"
SUPER_EOF

# 13. 配置Nginx
echo "配置Nginx..."
sudo tee /etc/nginx/sites-available/learning_log > /dev/null << NGINX_EOF
server {
    listen 80;
    server_name _;

    client_max_body_size 100M;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        alias /var/www/learning_log/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /var/www/learning_log/media/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX_EOF

# 14. 启用Nginx站点
sudo ln -sf /etc/nginx/sites-available/learning_log /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 15. 测试Nginx配置
sudo nginx -t

# 16. 重启服务
echo "重启服务..."
sudo systemctl restart nginx
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart learning_log

echo "部署完成!"
echo "请确保在腾讯云控制台的安全组中开放80端口"
echo "访问您的服务器IP地址即可看到网站"