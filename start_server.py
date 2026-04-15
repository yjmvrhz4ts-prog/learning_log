"""
启动服务器的脚本，用于在Railway上正确部署应用
"""
import os
import sys
from django.core.management import execute_from_command_line

def main():
    # 设置Django设置模块
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'learning_log.settings')
    
    try:
        import django
        from django.core.management import execute_from_command_line
        
        # 初始化Django
        django.setup()
        
        # 执行数据库迁移
        print("正在执行数据库迁移...")
        execute_from_command_line(['manage.py', 'migrate', '--no-input'])
        
        # 收集静态文件
        print("正在收集静态文件...")
        execute_from_command_line(['manage.py', 'collectstatic', '--no-input', '--clear'])
        
    except ImportError as exc:
        raise ImportError(
            "无法导入Django。请确保已正确安装Django，并且 "
            "已在PYTHONPATH环境变量中？你是否忘记激活 "
            "虚拟环境？"
        ) from exc

if __name__ == '__main__':
    main()