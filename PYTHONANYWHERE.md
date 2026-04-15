# 在 PythonAnywhere 上部署 Learning Log

这是一个将 Learning Log 项目部署到 PythonAnywhere 的指南，替换《Python编程从入门到实践 第2版》中提到的 Heroku 部署方式。

## 什么是 PythonAnywhere？

PythonAnywhere 是一个基于云的 Python 开发和托管环境，允许你在浏览器中编写、运行和托管 Python 应用程序，无需进行任何本地安装。

## 部署步骤

### 1. 在 PythonAnywhere 上创建账户

1. 访问 [www.pythonanywhere.com](https://www.pythonanywhere.com/)
2. 点击 "Start Coding for Free" 按钮注册免费账户
3. 登录到你的 PythonAnywhere 账户

### 2. 上传代码到 PythonAnywhere

有两种方式上传代码：

#### 方式一：使用 Git（推荐）

1. 将你的代码提交到 GitHub 或其他 Git 托管服务
2. 在 PythonAnywhere 终端中克隆你的仓库

#### 方式二：直接上传文件

1. 在本地压缩整个项目文件夹
2. 在 PythonAnywhere 的 Files 标签页中上传压缩文件
3. 解压到适当位置

### 3. 在 PythonAnywhere 终端中配置项目

1. 打开 PythonAnywhere 的 Bash 终端
2. 导航到你的项目目录
3. 安装项目依赖：

```bash
pip3 install --user -r requirements.txt
```

4. 进行数据库迁移：

```bash
python3 manage.py migrate
```

5. 收集静态文件（如果需要）：

```bash
python3 manage.py collectstatic --noinput
```

6. 创建超级用户（可选）：

```bash
python3 manage.py createsuperuser
```

### 4. 配置 Web 应用

1. 在 PythonAnywhere 仪表板上点击 "Web" 选项卡
2. 点击 "Add a new web app"
3. 选择 "Manual configuration"（底部选项）
4. 选择适当的 Python 版本（如 Python 3.9）
5. 记住你的虚拟环境路径，例如：`/home/你的用户名/mysite/venv`

### 5. 配置 WSGI 文件

编辑位于 `/var/www/你的域名_wsgi.py` 的 WSGI 文件：

```python
import sys
import os

# 添加你的项目路径到 sys.path
path = '/home/你的用户名/mysite'  # 替换为你的实际路径
if path not in sys.path:
    sys.path.insert(0, path)

# 设置 Django 设置模块
os.environ['DJANGO_SETTINGS_MODULE'] = 'learning_log.settings'

# 从 Django 加载和导入 WSGI
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
```

### 6. 设置虚拟环境（可选但推荐）

1. 在终端中创建虚拟环境：

```bash
mkvirtualenv --python=python3.9 mysite  # 根据你的 Python 版本调整
```

2. 安装依赖到虚拟环境：

```bash
pip install -r requirements.txt
```

3. 在 Web 选项卡中配置虚拟环境路径（如果使用）

### 7. 配置静态文件

在 Web 选项卡中设置静态文件路径：

- 静态文件 URL: `/static/`
- 静态文件目录: `/home/你的用户名/mysite/staticfiles`

### 8. 重启 Web 应用

完成配置后，点击 Web 选项卡中的 "Reload" 按钮重启应用。

## 故障排除

### 1. 检查错误日志

如果遇到问题，检查 PythonAnywhere 提供的日志文件：

- Error log: `/var/log/apache_error.log`
- Access log: 通常在 Web 选项卡中提供

### 2. 常见问题

- 确保 ALLOWED_HOSTS 包含你的 pythonanywhere.com 域名
- 确保已运行数据库迁移
- 检查静态文件路径是否正确设置

## 更新项目

当更新项目代码时：

1. 将更改上传到 PythonAnywhere
2. 在终端中运行新的迁移（如果有）：`python3 manage.py migrate`
3. 重新收集静态文件（如果需要）：`python3 manage.py collectstatic`
4. 重启 Web 应用

现在你应该能够通过 `你的用户名.pythonanywhere.com` 访问你的学习笔记应用！