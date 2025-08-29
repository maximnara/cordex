#!/bin/bash

# Тестовый скрипт для функции reinstall
# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Тест функции reinstall${NC}\n"

# Симулируем что мы находимся в директории плагина
TEST_DIR="/Users/mad/Documents/work/demo-stand/plugins/cordova-plugin-rustore-pay"

if [ ! -d "$TEST_DIR" ]; then
    echo -e "${RED}❌ Тестовая директория не найдена: $TEST_DIR${NC}"
    exit 1
fi

cd "$TEST_DIR"
echo -e "${GREEN}📂 Переход в директорию плагина: $(pwd)${NC}"

# Проверяем что это Cordova плагин
if [ ! -f "plugin.xml" ]; then
    echo -e "${RED}❌ plugin.xml не найден${NC}"
    exit 1
fi

# Получаем ID плагина
PLUGIN_ID=$(grep -o 'id="[^"]*"' plugin.xml | head -1 | sed 's/id="//;s/"//')
echo -e "${YELLOW}Plugin ID: $PLUGIN_ID${NC}"

# Ищем Cordova проект
CURRENT_DIR=$(pwd)
CORDOVA_ROOT=""

while [ "$PWD" != "/" ]; do
    if [ -f "config.xml" ] && [ -d "platforms" ]; then
        CORDOVA_ROOT="$PWD"
        break
    fi
    cd ..
done

cd "$CURRENT_DIR"

if [ -z "$CORDOVA_ROOT" ]; then
    echo -e "${RED}❌ Cordova проект не найден${NC}"
    exit 1
fi

echo -e "${GREEN}Cordova проект найден: $CORDOVA_ROOT${NC}"

# Переходим в корень проекта
cd "$CORDOVA_ROOT"

# Вычисляем относительный путь
if command -v python3 &> /dev/null; then
    PLUGIN_PATH=$(python3 -c "import os.path; print(os.path.relpath('$CURRENT_DIR', '$CORDOVA_ROOT'))")
elif command -v python &> /dev/null; then
    PLUGIN_PATH=$(python -c "import os.path; print(os.path.relpath('$CURRENT_DIR', '$CORDOVA_ROOT'))")
else
    echo -e "${RED}❌ Python не найден для вычисления пути${NC}"
    exit 1
fi

echo -e "${BLUE}📝 Путь к плагину: $PLUGIN_PATH${NC}"

# Показываем статус до переустановки
echo -e "\n${BLUE}📋 Текущие плагины:${NC}"
cordova plugin list

echo -e "\n${YELLOW}🔄 Начинаем переустановку...${NC}"

# Удаляем плагин
echo -e "${YELLOW}🗑️  Удаление плагина...${NC}"
cordova plugin remove "$PLUGIN_ID"

# Проверяем что удалился
echo -e "\n${BLUE}📋 Плагины после удаления:${NC}"
cordova plugin list

# Устанавливаем заново
echo -e "\n${GREEN}📦 Установка плагина...${NC}"
if cordova plugin add "$PLUGIN_PATH"; then
    echo -e "\n${GREEN}✅ Плагин успешно переустановлен!${NC}"
    
    # Финальный статус
    echo -e "\n${BLUE}📋 Финальный список плагинов:${NC}"
    cordova plugin list
else
    echo -e "\n${RED}❌ Ошибка при установке плагина${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Тест завершен успешно!${NC}"