#!/bin/bash

# Функция для выбора версии Python
select_python_version() {
    echo "Выберите версию Python для установки (доступные версии: 3.8, 3.9, 3.10, 3.11, 3.12, 3.13):"
    read -r PYTHON_VERSION

    # Проверка корректности введенной версии
    if [[ ! "$PYTHON_VERSION" =~ ^3\.[8-9]|3\.1[0-3]$ ]]; then
        echo "Некорректная версия Python. Пожалуйста, выберите версию от 3.8 до 3.13."
        select_python_version
    fi
}

# Обновляем пакеты
sudo apt update

# Устанавливаем зависимости
sudo apt install -y build-essential libssl-dev libbz2-dev \
libreadline-dev libsqlite3-dev libffi-dev zlib1g-dev \
libgdbm-dev liblzma-dev wget curl

# Запускаем выбор версии Python
select_python_version

# Скачиваем исходный код выбранной версии Python
wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"

# Распаковываем архив
tar -xvf "Python-$PYTHON_VERSION.tgz"
cd "Python-$PYTHON_VERSION" || exit

# Сконфигурируем сборку
./configure --enable-optimizations

# Собираем и устанавливаем
make -j "$(nproc)"
sudo make altinstall

# Создаем символьную ссылку для python3
sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3."$PYTHON_VERSION" 1

# Устанавливаем выбранную версию python3 как глобальную
sudo update-alternatives --config python3 <<EOF
1
EOF

# Устанавливаем pip для выбранной версии Python
curl -sS https://bootstrap.pypa.io/get-pip.py | python3."$PYTHON_VERSION"

# Убираем временные файлы
cd ..
rm -rf "Python-$PYTHON_VERSION"
rm "Python-$PYTHON_VERSION.tgz"

echo "Python $PYTHON_VERSION установлен и настроен как глобальный Python 3."
