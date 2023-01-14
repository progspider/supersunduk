:: Для проверки SHA-256 хеша, достаточно ввести следующую команду:
:: certutil -hashfile C:\Users\Admin\Downloads\HashTab_v6.0.0.34_Setup.exe SHA256

certutil -hashfile "%~dp0archlinux-2023.01.01-x86_64.iso" SHA256