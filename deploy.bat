@echo off
REM Learning Log Django项目部署脚本
REM 适用于腾讯云Windows服务器

echo 开始部署Learning Log Django项目...

REM 1. 创建项目目录
set PROJECT_DIR=C:\inetpub\wwwroot\learning_log
echo 创建项目目录: %PROJECT_DIR%
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"

REM 2. 复制项目文件到目标目录
echo 复制项目文件...
xcopy /E /I /Y . "%PROJECT_DIR%"

REM 3. 创建并激活虚拟环境
echo 创建虚拟环境...
cd /d "%PROJECT_DIR%"
python -m venv venv
call venv\Scripts\activate

REM 4. 升级pip并安装依赖
echo 安装项目依赖...
pip install --upgrade pip
pip install -r requirements.txt

REM 5. 收集静态文件
echo 收集静态文件...
python manage.py collectstatic --noinput

REM 6. 迁移数据库
echo 执行数据库迁移...
python manage.py migrate --noinput

echo 部署完成!
echo 请手动配置IIS或使用其他WSGI服务器来运行Django应用
pause