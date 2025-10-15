#!/bin/bash

# Проверяем, что передано новое название
if [ -z "$1" ]; then
    echo "Использование: ./create_copy.sh <новое_название>"
    echo "Пример: ./create_copy.sh 'Ош 996'"
    exit 1
fi

NEW_NAME="$1"
NEW_NAME_LOWER=$(echo "$NEW_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
NEW_DIR="../${NEW_NAME_LOWER}"

# Создаем новую директорию
mkdir -p "$NEW_DIR"

# Копируем все файлы
cp -r * "$NEW_DIR/"

# Переходим в новую директорию
cd "$NEW_DIR"

# Заменяем название в pubspec.yaml
sed -i "s/name: aimak996/name: ${NEW_NAME_LOWER}/" pubspec.yaml

# Заменяем название в main.dart
sed -i "s/title: 'Аймак 996'/title: '${NEW_NAME}'/" lib/main.dart

# Заменяем название в splash_screen.dart
sed -i "s/'Аймак 996'/'${NEW_NAME}'/" lib/screens/splash_screen.dart

# Заменяем название в about_screen.dart
sed -i "s/Аймак 996/${NEW_NAME}/g" lib/features/about/about_screen.dart

# Заменяем название в developer_screen.dart
sed -i "s/'Aimak 996'/'${NEW_NAME}'/" lib/features/about/developer_screen.dart

# Заменяем название в файлах переводов
sed -i "s/\"app_title\": \"Аймак 996\"/\"app_title\": \"${NEW_NAME}\"/" assets/translations/ru.json
sed -i "s/\"app_title\": \"Аймак 996\"/\"app_title\": \"${NEW_NAME}\"/" assets/translations/ky.json
sed -i "s/\"company_name\": \"Аймак 996\"/\"company_name\": \"${NEW_NAME}\"/" assets/translations/ru.json
sed -i "s/\"company_name\": \"Аймак 996\"/\"company_name\": \"${NEW_NAME}\"/" assets/translations/ky.json

echo "Копия проекта создана в директории: $NEW_DIR"
echo "Не забудьте:"
echo "1. Проверить все изменения в файлах"
echo "2. Обновить иконки и изображения"
echo "3. Обновить package name в Android и iOS настройках"
echo "4. Обновить bundle identifier в iOS настройках" 