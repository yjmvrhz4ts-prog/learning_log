# Learning Log 项目部署指南

本文档详细介绍了如何将 Learning Log Django 项目部署到腾讯云服务器上。

## 部署前准备

1. 在腾讯云购买一台云服务器（CVM），推荐配置：
   - 操作系统：Ubuntu 20.04 LTS 或更高版本
   - CPU：至少1核
   - 内存：至少2GB
   - 硬盘：至少20GB
   - 带宽：按需选择

2. 确保服务器安全组规则允许以下端口访问：
   - 22 (SSH)
   - 80 (HTTP)
   - 443 (HTTPS，如果使用SSL)

## 部署方式选择

您可以选择以下三种方式之一进行部署：

### 方式一：传统部署（推荐）

1. 登录到腾讯云服务器：
   ```bash
   ssh ubuntu@<您的服务器IP>
   ```

2. 克隆项目代码：
   ```bash
   git clone <您的代码仓库地址>
   cd learning_log
   ```

3. 给部署脚本添加执行权限并运行：
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

4. 配置环境变量（推荐使用supervisor或systemd配置文件）：
   ```bash
   export DEBUG=False
   export SERVER_IP=<您的服务器IP>
   export DOMAIN_NAME=<您的域名，如果没有则不设置>
   export DB_ENGINE=django.db.backends.postgresql
   export DB_NAME=learning_log_db
   export DB_USER=learning_log_user
   export DB_PASSWORD=<数据库密码>
   export DB_HOST=localhost
   export DB_PORT=5432
   export LEARNING_LOG_SECRET_KEY=<您的密钥>
   ```

### 方式二：Docker 部署

1. 在服务器上安装 Docker 和 Docker Compose：
   ```bash
   # 安装 Docker
   sudo apt update
   sudo apt install -y docker.io docker-compose
   
   # 启动 Docker 服务
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

2. 克隆项目代码：
   ```bash
   git clone <您的代码仓库地址>
   cd learning_log
   ```

3. 创建 .env 文件配置环境变量：
   ```bash
   cat > .env << EOF
   DB_PASSWORD=your_secure_password_here
   SECRET_KEY=your_secret_key_here
   EOF
   ```

4. 构建并启动容器：
   ```bash
   docker-compose up -d
   ```

### 方式三：手动部署

1. 手动安装 Python 3 和 pip：
   ```bash
   sudo apt update
   sudo apt install -y python3 python3-pip python3-venv
   ```

2. 安装并配置 PostgreSQL（可选，也可以继续使用 SQLite）：
   ```bash
   sudo apt install -y postgresql postgresql-contrib
   sudo -u postgres psql -c "CREATE DATABASE learning_log_db;"
   sudo -u postgres psql -c "CREATE USER learning_log_user WITH PASSWORD 'your_password';"
   sudo -u postgres psql -c "ALTER ROLE learning_log_user SET client_encoding TO 'utf8';"
   sudo -u postgres psql -c "ALTER ROLE learning_log_user SET default_transaction_isolation TO 'read committed';"
   sudo -u postgres psql -c "ALTER ROLE learning_log_user SET timezone TO 'Asia/Shanghai';"
   sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE learning_log_db TO learning_log_user;"
   ```

3. 下载项目代码并配置：
   ```bash
   # 克隆代码
   git clone <您的代码仓库地址>
   cd learning_log
   
   # 创建虚拟环境
   python3 -m venv venv
   source venv/bin/activate
   
   # 安装依赖
   pip install -r requirements.txt
   
   # 收集静态文件
   python manage.py collectstatic --noinput
   
   # 执行数据库迁移
   python manage.py migrate
   ```

4. 配置 Gunicorn：
   ```bash
   pip install gunicorn
   ```

5. 配置 Nginx 反向代理：
   ```bash
   sudo apt install -y nginx
   
   # 创建 Nginx 配置文件
   sudo nano /etc/nginx/sites-available/learning_log
   
   # 启用站点
   sudo ln -s /etc/nginx/sites-available/learning_log /etc/nginx/sites-enabled/
   
   # 测试配置
   sudo nginx -t
   
   # 重启 Nginx
   sudo systemctl restart nginx
   ```

6. 使用 Supervisor 管理 Gunicorn 进程：
   ```bash
   sudo apt install -y supervisor
   
   # 创建 Supervisor 配置文件
   sudo nano /etc/supervisor/conf.d/learning_log.conf
   ```

## 安全注意事项

1. **更改默认密钥**：在生产环境中，务必将 [SECRET_KEY](file:///g:/学习/项目3/learning_log/learning_log/settings.py#L19-L19) 替换为强随机密钥
2. **禁用调试模式**：确保 [DEBUG](file:///g:/学习/项目3/learning_log/learning_log/settings.py#L22-L22) 设置为 `False`
3. **配置正确的 ALLOWED_HOSTS**：只包含实际使用的域名/IP
4. **定期备份数据**：对数据库进行定期备份
5. **使用 HTTPS**：通过 Let's Encrypt 获取 SSL 证书并启用 HTTPS

## 故障排除

1. **检查日志**：
   - 应用日志：`sudo tail -f /var/log/gunicorn/app.log`
   - Nginx 错误日志：`sudo tail -f /var/log/nginx/error.log`
   - Supervisor 日志：`sudo supervisorctl status`

2. **常见问题**：
   - 静态文件无法访问：确认已执行 `collectstatic` 命令
   - 数据库连接失败：检查数据库服务是否运行及配置是否正确
   - 权限错误：确保 Web 服务器有适当的文件访问权限

## 维护与更新

1. **备份**：定期备份数据库和静态文件
2. **更新**：通过 Git 拉取最新代码后，重新安装依赖并执行迁移
3. **监控**：设置系统和应用监控以及时发现性能问题

## SSL 证书配置（可选）

如果您想启用 HTTPS，可以使用 Certbot 自动获取和配置 Let's Encrypt 证书：

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

这将自动修改 Nginx 配置以启用 HTTPS 并设置自动续期。