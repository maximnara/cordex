#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TEMPLATE_REPO="https://github.com/maximnara/cordova-plugin-template.git"
TEMP_DIR="cordova-plugin-temp-$$"

echo -e "${BLUE}🚀 Настройка Cordova Plugin Template${NC}\n"

# Проверяем наличие git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git не найден. Установите Git и попробуйте снова.${NC}"
    exit 1
fi

# Проверяем, что текущая директория пуста или содержит только cordex файлы
if [ -d ".git" ] || ([ "$(ls -A . 2>/dev/null | wc -l)" -gt 0 ] && ! ls -A . | grep -q "cordova-plugin-manager\|\.sh$\|package\.json$\|\.tgz$"); then
    echo -e "${YELLOW}⚠️  Текущая директория не пуста или уже является git репозиторием.${NC}"
    echo -e "${YELLOW}Создайте новую пустую директорию для плагина и запустите cordex setup там.${NC}"
    exit 1
fi

echo -e "${BLUE}📥 Скачивание шаблона из репозитория...${NC}"

# Клонируем шаблон во временную директорию
if ! git clone "$TEMPLATE_REPO" "$TEMP_DIR" --quiet; then
    echo -e "${RED}❌ Ошибка при скачивании шаблона из $TEMPLATE_REPO${NC}"
    exit 1
fi

# Перемещаем содержимое шаблона в текущую директорию
cd "$TEMP_DIR"
# Копируем все файлы включая скрытые, исключая .git
shopt -s dotglob  # Включаем скрытые файлы
for item in *; do
    if [ "$item" != ".git" ]; then
        cp -r "$item" ../
    fi
done
shopt -u dotglob  # Выключаем скрытые файлы
cd ..

# Удаляем временную директорию
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Шаблон успешно скачан${NC}\n"

# Функция для преобразования в camelCase
to_camel_case() {
    echo "$1" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' | sed 's/ //g'
}

# Функция для преобразования в kebab-case
to_kebab_case() {
    echo "$1" | sed 's/[A-Z]/-&/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-+/-/g' | sed 's/^-\|-$//g'
}

# Функция для преобразования в package path
to_package_path() {
    echo "$1" | tr '.' '/'
}

# Проверяем автоматический режим (из cordex init)
if [ "$CORDEX_AUTO_MODE" = "true" ]; then
    echo -e "${GREEN}📋 Используются данные из cordex init${NC}\n"
    PLUGIN_SIMPLE_NAME="$CORDEX_PLUGIN_SIMPLE_NAME"
    AUTHOR_NAME="$CORDEX_AUTHOR_NAME"
    GITHUB_USERNAME="$CORDEX_GITHUB_USERNAME"
else
    # Интерактивный режим
    echo -e "${YELLOW}Введите основные данные (остальные будут сгенерированы автоматически):${NC}\n"
    
    read -p "1. Название плагина (например: awesome camera): " PLUGIN_SIMPLE_NAME
    read -p "2. Ваше имя или компания: " AUTHOR_NAME
    read -p "3. GitHub username (для репозитория): " GITHUB_USERNAME
    
    # Проверка обязательных полей
    if [[ -z "$PLUGIN_SIMPLE_NAME" || -z "$AUTHOR_NAME" || -z "$GITHUB_USERNAME" ]]; then
        echo -e "${RED}❌ Все поля обязательны для заполнения!${NC}"
        exit 1
    fi
fi

echo -e "\n${BLUE}📝 Генерация плейсхолдеров...${NC}\n"

# Автоматическая генерация всех плейсхолдеров
PLUGIN_NAME_KEBAB=$(to_kebab_case "$PLUGIN_SIMPLE_NAME")
PLUGIN_NAME_CAMEL=$(to_camel_case "$PLUGIN_SIMPLE_NAME")

PLUGIN_ID="cordova-plugin-${PLUGIN_NAME_KEBAB}"
PLUGIN_NAME="${PLUGIN_NAME_CAMEL} Plugin"
PLUGIN_DESCRIPTION="Cordova plugin for ${PLUGIN_SIMPLE_NAME}"
PLUGIN_NPM_NAME="$PLUGIN_ID"
PLUGIN_AUTHOR="$AUTHOR_NAME"
PLUGIN_KEYWORD="$(echo $PLUGIN_SIMPLE_NAME | awk '{print $1}' | tr '[:upper:]' '[:lower:]')"
PLUGIN_REPOSITORY_URL="https://github.com/${GITHUB_USERNAME}/${PLUGIN_ID}"

JS_FILE_NAME="$PLUGIN_NAME_KEBAB"
JS_MODULE_NAME="$PLUGIN_NAME_CAMEL"
JS_TARGET="$PLUGIN_NAME_CAMEL"

ANDROID_PLUGIN_CLASS="${PLUGIN_NAME_CAMEL}Plugin"
ANDROID_PACKAGE="com.$(echo $GITHUB_USERNAME | tr '[:upper:]' '[:lower:]').$(echo $PLUGIN_NAME_KEBAB | tr '-' '.')"
ANDROID_PACKAGE_PATH=$(to_package_path "$ANDROID_PACKAGE")
GRADLE_FILE_NAME="$PLUGIN_NAME_KEBAB"

IOS_PLUGIN_CLASS="${PLUGIN_NAME_CAMEL}Plugin"

# Показываем сгенерированные значения
echo -e "${GREEN}Сгенерированные значения:${NC}"
echo "Plugin ID: $PLUGIN_ID"
echo "Plugin Name: $PLUGIN_NAME" 
echo "JavaScript Module: $JS_MODULE_NAME"
echo "Android Class: $ANDROID_PLUGIN_CLASS"
echo "Android Package: $ANDROID_PACKAGE"
echo "iOS Class: $IOS_PLUGIN_CLASS"
echo "Repository: $PLUGIN_REPOSITORY_URL"

echo -e "\n${BLUE}🔄 Замена плейсхолдеров...${NC}"

# Поиск и замена во всех файлах
find . -type f \( -name "*.xml" -o -name "*.json" -o -name "*.js" -o -name "*.kt" -o -name "*.swift" -o -name "*.h" -o -name "*.gradle" \) -not -path "./node_modules/*" -not -path "./.git/*" | while read file; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' \
            -e "s/{{PLUGIN_ID}}/${PLUGIN_ID}/g" \
            -e "s/{{PLUGIN_NAME}}/${PLUGIN_NAME}/g" \
            -e "s/{{PLUGIN_DESCRIPTION}}/${PLUGIN_DESCRIPTION}/g" \
            -e "s/{{PLUGIN_NPM_NAME}}/${PLUGIN_NPM_NAME}/g" \
            -e "s/{{PLUGIN_AUTHOR}}/${PLUGIN_AUTHOR}/g" \
            -e "s/{{PLUGIN_KEYWORD}}/${PLUGIN_KEYWORD}/g" \
            -e "s|{{PLUGIN_REPOSITORY_URL}}|${PLUGIN_REPOSITORY_URL}|g" \
            -e "s/{{JS_FILE_NAME}}/${JS_FILE_NAME}/g" \
            -e "s/{{JS_MODULE_NAME}}/${JS_MODULE_NAME}/g" \
            -e "s/{{JS_TARGET}}/${JS_TARGET}/g" \
            -e "s/{{ANDROID_PLUGIN_CLASS}}/${ANDROID_PLUGIN_CLASS}/g" \
            -e "s/{{ANDROID_PACKAGE}}/${ANDROID_PACKAGE}/g" \
            -e "s|{{ANDROID_PACKAGE_PATH}}|${ANDROID_PACKAGE_PATH}|g" \
            -e "s/{{GRADLE_FILE_NAME}}/${GRADLE_FILE_NAME}/g" \
            -e "s/{{IOS_PLUGIN_CLASS}}/${IOS_PLUGIN_CLASS}/g" \
            "$file"
    else
        # Linux
        sed -i \
            -e "s/{{PLUGIN_ID}}/${PLUGIN_ID}/g" \
            -e "s/{{PLUGIN_NAME}}/${PLUGIN_NAME}/g" \
            -e "s/{{PLUGIN_DESCRIPTION}}/${PLUGIN_DESCRIPTION}/g" \
            -e "s/{{PLUGIN_NPM_NAME}}/${PLUGIN_NPM_NAME}/g" \
            -e "s/{{PLUGIN_AUTHOR}}/${PLUGIN_AUTHOR}/g" \
            -e "s/{{PLUGIN_KEYWORD}}/${PLUGIN_KEYWORD}/g" \
            -e "s|{{PLUGIN_REPOSITORY_URL}}|${PLUGIN_REPOSITORY_URL}|g" \
            -e "s/{{JS_FILE_NAME}}/${JS_FILE_NAME}/g" \
            -e "s/{{JS_MODULE_NAME}}/${JS_MODULE_NAME}/g" \
            -e "s/{{JS_TARGET}}/${JS_TARGET}/g" \
            -e "s/{{ANDROID_PLUGIN_CLASS}}/${ANDROID_PLUGIN_CLASS}/g" \
            -e "s/{{ANDROID_PACKAGE}}/${ANDROID_PACKAGE}/g" \
            -e "s|{{ANDROID_PACKAGE_PATH}}|${ANDROID_PACKAGE_PATH}|g" \
            -e "s/{{GRADLE_FILE_NAME}}/${GRADLE_FILE_NAME}/g" \
            -e "s/{{IOS_PLUGIN_CLASS}}/${IOS_PLUGIN_CLASS}/g" \
            "$file"
    fi
done

echo -e "\n${BLUE}📁 Переименование файлов...${NC}"

# Переименование файлов
mv "www/plugin-template.js" "www/${JS_FILE_NAME}.js" 2>/dev/null
mv "src/android/PluginTemplate.kt" "src/android/${ANDROID_PLUGIN_CLASS}.kt" 2>/dev/null
mv "src/android/build-template.gradle" "src/android/${GRADLE_FILE_NAME}.gradle" 2>/dev/null
mv "src/ios/PluginTemplate.h" "src/ios/${IOS_PLUGIN_CLASS}.h" 2>/dev/null  
mv "src/ios/PluginTemplate.swift" "src/ios/${IOS_PLUGIN_CLASS}.swift" 2>/dev/null

# Сохраняем новые имена файлов для использования в add-method.sh
echo "ANDROID_FILE=src/android/${ANDROID_PLUGIN_CLASS}.kt" > .plugin-files
echo "IOS_FILE=src/ios/${IOS_PLUGIN_CLASS}.swift" >> .plugin-files
echo "IOS_HEADER_FILE=src/ios/${IOS_PLUGIN_CLASS}.h" >> .plugin-files
echo "JS_FILE=www/${JS_FILE_NAME}.js" >> .plugin-files

# Проверка остались ли плейсхолдеры в основных файлах плагина
REMAINING=$(grep -r "{{" plugin.xml package.json www/ src/ 2>/dev/null | wc -l)

if [ "$REMAINING" -eq 0 ]; then
    echo -e "\n${GREEN}✅ Успешно! Все плейсхолдеры заменены.${NC}"
    
    echo -e "\n${BLUE}📋 Итоговая информация:${NC}"
    echo "Plugin ID: $PLUGIN_ID"
    echo "JavaScript файл: www/${JS_FILE_NAME}.js"
    echo "Android класс: src/android/${ANDROID_PLUGIN_CLASS}.kt"
    echo "iOS класс: src/ios/${IOS_PLUGIN_CLASS}.swift"
    
    echo -e "\n${GREEN}🚀 Плагин готов к использованию!${NC}"
    echo -e "${YELLOW}Следующие шаги:${NC}"
    echo "1. Добавьте свою логику в файлы src/"
    echo "2. Установите плагин: cordova plugin add $(pwd)"
    echo "3. Используйте в коде: ${JS_MODULE_NAME}.init({})"
    
    # Удаляем файлы шаблона и документацию
    echo -e "\n${BLUE}🧹 Очистка шаблонных файлов...${NC}"
    rm -f setup.sh PLACEHOLDERS.md 2>/dev/null
    
    # Удаляем оригинальные файлы шаблона, которые были переименованы
    rm -f www/plugin-template.js 2>/dev/null
    rm -f src/android/PluginTemplate.kt 2>/dev/null
    rm -f src/android/build-template.gradle 2>/dev/null
    rm -f src/ios/PluginTemplate.h 2>/dev/null
    rm -f src/ios/PluginTemplate.swift 2>/dev/null
    
    # Удаляем вспомогательные файлы шаблона
    rm -f BaseHelper.kt Common.swift 2>/dev/null
    
else
    echo -e "\n${YELLOW}⚠️  Найдены незамененные плейсхолдеры: $REMAINING${NC}"
    echo "Проверьте файлы командой: grep -r '{{' plugin.xml package.json www/ src/"
fi