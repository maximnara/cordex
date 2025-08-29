#!/bin/bash

# Cordova Plugin Manager - Standalone library for managing Cordova plugin development
# Version 1.0.0

# Определяем где находятся скрипты cordex
# Попробуем найти setup.sh рядом с основным скриптом
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Если не найден, проверяем структуру npm
if [ ! -f "$SCRIPT_DIR/setup.sh" ]; then
    # В npm пакете скрипты могут быть в node_modules
    NPM_SCRIPT_DIR="$(dirname "$(which cordex 2>/dev/null || echo "$0")")"
    if [ -f "$NPM_SCRIPT_DIR/setup.sh" ]; then
        SCRIPT_DIR="$NPM_SCRIPT_DIR"
    elif [ -f "$(dirname "$NPM_SCRIPT_DIR")/lib/node_modules/cordex/setup.sh" ]; then
        SCRIPT_DIR="$(dirname "$NPM_SCRIPT_DIR")/lib/node_modules/cordex"
    fi
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BLUE}Cordova Plugin Manager v1.0.0${NC}\n"
    echo "Usage: cordex <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  init                        Create new plugin with interactive setup"
    echo "  setup                       Setup new Cordova plugin from template in current directory"
    echo "  method add <methodName>     Add new method to existing plugin"
    echo "  method remove <methodName>  Remove method from existing plugin"
    echo "  plugin reinstall [pluginId] Reinstall plugin in Cordova project"
    echo "  help                        Show this help message"
    echo ""
    echo "Examples:"
    echo "  cordex init                        # Interactive setup with folder creation"
    echo "  cordex setup                       # Setup plugin in current directory"
    echo "  cordex method add myMethod         # Add new method to plugin"
    echo "  cordex method remove oldMethod     # Remove method from plugin"
    echo "  cordex plugin reinstall            # Interactive plugin selection"
    echo "  cordex plugin reinstall cordova-plugin-x  # Reinstall specific plugin"
    echo ""
    echo "Installation:"
    echo "  npm install -g cordex"
    echo "  npm update -g cordex  # Update to latest version"
}


init_plugin() {
    echo -e "${BLUE}🚀 Инициализация нового Cordova плагина${NC}\n"
    
    # Сохраняем изначальный SCRIPT_DIR до смены директории
    ORIGINAL_SCRIPT_DIR="$SCRIPT_DIR"
    
    # Функция для преобразования в kebab-case
    to_kebab_case() {
        echo "$1" | sed 's/[A-Z]/-&/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-+/-/g' | sed 's/^-\|-$//g'
    }
    
    # Интерактивный сбор данных
    echo -e "${YELLOW}Введите основные данные для плагина:${NC}\n"
    
    read -p "1. Название плагина (например: awesome camera): " PLUGIN_SIMPLE_NAME
    read -p "2. Ваше имя или компания: " AUTHOR_NAME
    read -p "3. GitHub username (для репозитория): " GITHUB_USERNAME
    
    # Проверка обязательных полей
    if [[ -z "$PLUGIN_SIMPLE_NAME" || -z "$AUTHOR_NAME" || -z "$GITHUB_USERNAME" ]]; then
        echo -e "${RED}❌ Все поля обязательны для заполнения!${NC}"
        exit 1
    fi
    
    # Генерируем название папки
    PLUGIN_NAME_KEBAB=$(to_kebab_case "$PLUGIN_SIMPLE_NAME")
    FOLDER_NAME="cordova-plugin-${PLUGIN_NAME_KEBAB}"
    
    echo -e "\n${GREEN}📁 Создается папка: ${FOLDER_NAME}${NC}"
    
    # Проверяем что директория не существует
    if [ -d "$FOLDER_NAME" ]; then
        echo -e "${RED}❌ Директория '$FOLDER_NAME' уже существует${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📁 Создание директории '$FOLDER_NAME'...${NC}"
    mkdir "$FOLDER_NAME"
    
    echo -e "${BLUE}📂 Переход в директорию '$FOLDER_NAME'...${NC}"
    cd "$FOLDER_NAME"
    
    # Передаем собранные данные в setup
    export CORDEX_PLUGIN_SIMPLE_NAME="$PLUGIN_SIMPLE_NAME"
    export CORDEX_AUTHOR_NAME="$AUTHOR_NAME"
    export CORDEX_GITHUB_USERNAME="$GITHUB_USERNAME"
    export CORDEX_AUTO_MODE="true"
    
    # Запускаем setup с правильным путем к скриптам
    if [ ! -f "$ORIGINAL_SCRIPT_DIR/setup.sh" ]; then
        echo -e "${RED}❌ Setup script not found.${NC}"
        echo -e "${YELLOW}Debug info:${NC}"
        echo "Looking for: $ORIGINAL_SCRIPT_DIR/setup.sh"
        echo "SCRIPT_DIR: $SCRIPT_DIR"
        echo "ORIGINAL_SCRIPT_DIR: $ORIGINAL_SCRIPT_DIR"
        echo "which cordex: $(which cordex 2>/dev/null || echo 'not found')"
        echo "Contents of SCRIPT_DIR:"
        ls -la "$ORIGINAL_SCRIPT_DIR" 2>/dev/null || echo "Directory not accessible"
        exit 1
    fi
    
    bash "$ORIGINAL_SCRIPT_DIR/setup.sh"
}

run_setup() {
    # Используем setup.sh из той же директории что и основной скрипт
    if [ ! -f "$SCRIPT_DIR/setup.sh" ]; then
        echo -e "${RED}❌ Setup script not found.${NC}"
        exit 1
    fi
    
    bash "$SCRIPT_DIR/setup.sh"
}

add_method() {
    local method_name="$1"
    
    if [ -z "$method_name" ]; then
        echo -e "${RED}❌ Method name is required${NC}"
        echo "Usage: cordex method add <methodName>"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/add-method.sh" ]; then
        echo -e "${RED}❌ Add-method script not found.${NC}"
        exit 1
    fi
    
    if [ ! -f ".plugin-files" ]; then
        echo -e "${RED}❌ Plugin not initialized. Run 'setup' first.${NC}"
        exit 1
    fi
    
    bash "$SCRIPT_DIR/add-method.sh" "$method_name"
}

remove_method() {
    local method_name="$1"
    
    if [ -z "$method_name" ]; then
        echo -e "${RED}❌ Method name is required${NC}"
        echo "Usage: cordex method remove <methodName>"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/remove-method.sh" ]; then
        echo -e "${RED}❌ Remove-method script not found.${NC}"
        exit 1
    fi
    
    if [ ! -f ".plugin-files" ]; then
        echo -e "${RED}❌ Plugin not initialized. Run 'setup' first.${NC}"
        exit 1
    fi
    
    bash "$SCRIPT_DIR/remove-method.sh" "$method_name"
}

reinstall_plugin() {
    local specified_plugin="$1"
    echo -e "${BLUE}🔄 Переустановка плагина...${NC}\n"
    
    # Ищем Cordova проект
    CURRENT_DIR=$(pwd)
    CORDOVA_ROOT=""
    
    # Сначала проверяем текущую директорию
    if [ -f "config.xml" ] && [ -d "platforms" ]; then
        CORDOVA_ROOT="$CURRENT_DIR"
    else
        # Ищем в родительских директориях
        while [ "$PWD" != "/" ]; do
            if [ -f "config.xml" ] && [ -d "platforms" ]; then
                CORDOVA_ROOT="$PWD"
                break
            fi
            cd ..
        done
        cd "$CURRENT_DIR"
    fi
    
    if [ -z "$CORDOVA_ROOT" ]; then
        echo -e "${RED}❌ Cordova проект не найден.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Cordova проект найден: $CORDOVA_ROOT${NC}"
    
    # Переходим в корень Cordova проекта
    cd "$CORDOVA_ROOT"
    
    # Получаем список всех установленных плагинов
    PLUGINS=$(cordova plugin list 2>/dev/null | cut -d' ' -f1)
    
    if [ -z "$PLUGINS" ]; then
        echo -e "${YELLOW}Плагины не найдены${NC}"
        exit 1
    fi
    
    # Если плагин указан в командной строке
    if [ -n "$specified_plugin" ]; then
        # Проверяем что указанный плагин установлен
        if echo "$PLUGINS" | grep -q "^$specified_plugin$"; then
            PLUGIN_ID="$specified_plugin"
            echo -e "${GREEN}Выбран плагин: $PLUGIN_ID${NC}"
        else
            echo -e "${RED}❌ Плагин '$specified_plugin' не найден среди установленных${NC}"
            echo -e "${BLUE}📋 Установленные плагины:${NC}"
            echo "$PLUGINS" | sed 's/^/  - /'
            exit 1
        fi
    else
        # Интерактивный выбор плагина
        echo -e "${BLUE}📋 Установленные плагины:${NC}"
        
        # Создаем массив плагинов
        PLUGIN_ARRAY=()
        i=1
        while IFS= read -r plugin; do
            if [ -n "$plugin" ]; then
                echo "  [$i] $plugin"
                PLUGIN_ARRAY[i]="$plugin"
                ((i++))
            fi
        done <<< "$PLUGINS"
        
        # Подсчитываем реальное количество плагинов
        plugin_count=0
        for i in "${!PLUGIN_ARRAY[@]}"; do
            if [ -n "${PLUGIN_ARRAY[i]}" ]; then
                ((plugin_count++))
            fi
        done
        
        # Если только один плагин, выбираем его автоматически
        if [ $plugin_count -eq 1 ]; then
            PLUGIN_ID="${PLUGIN_ARRAY[1]}"
            echo -e "\n${GREEN}Автоматически выбран единственный плагин: $PLUGIN_ID${NC}"
        else
            # Интерактивный выбор с стрелками
            echo -e "\n${YELLOW}Выберите плагин для переустановки (используйте ↑↓ и Enter):${NC}"
            
            selected=1
            max_option=$plugin_count
            
            # Функция отображения меню
            show_menu() {
                clear
                echo -e "${BLUE}🔄 Переустановка плагина...${NC}\n"
                echo -e "${GREEN}Cordova проект найден: $CORDOVA_ROOT${NC}"
                echo -e "${BLUE}📋 Установленные плагины:${NC}\n"
                
                for i in $(seq 1 $max_option); do
                    if [ $i -eq $selected ]; then
                        echo -e "  ${GREEN}► [$i] ${PLUGIN_ARRAY[i]}${NC}"
                    else
                        echo -e "    [$i] ${PLUGIN_ARRAY[i]}"
                    fi
                done
                
                echo -e "\n${YELLOW}Используйте ↑↓ для навигации, Enter для выбора, q для выхода${NC}"
            }
            
            # Главный цикл навигации
            while true; do
                show_menu
                
                # Читаем одну клавишу
                read -rsn1 key
                
                case "$key" in
                    $'\x1b')  # Escape sequence
                        read -rsn2 key
                        case "$key" in
                            '[A')  # Стрелка вверх
                                if [ $selected -gt 1 ]; then
                                    ((selected--))
                                fi
                                ;;
                            '[B')  # Стрелка вниз
                                if [ $selected -lt $max_option ]; then
                                    ((selected++))
                                fi
                                ;;
                        esac
                        ;;
                    '')  # Enter
                        PLUGIN_ID="${PLUGIN_ARRAY[$selected]}"
                        clear
                        break
                        ;;
                    'q'|'Q')  # Выход
                        echo -e "\n${YELLOW}Операция отменена${NC}"
                        exit 0
                        ;;
                esac
            done
        fi
    fi
    
    echo -e "\n${YELLOW}Переустанавливаем плагин: $PLUGIN_ID${NC}"
    
    # Пытаемся найти локальный путь к плагину
    PLUGIN_SOURCE_PATH=""
    LOCAL_PLUGIN_DIR=""
    
    # Сначала проверяем fetch.json чтобы узнать откуда изначально был установлен плагин
    if [ -f "plugins/fetch.json" ]; then
        ORIGINAL_SOURCE=$(grep -A 5 "\"$PLUGIN_ID\"" plugins/fetch.json | grep '"source"' | sed 's/.*"source": *"\([^"]*\)".*/\1/')
        if [ -n "$ORIGINAL_SOURCE" ] && [ "$ORIGINAL_SOURCE" != "$PLUGIN_ID" ]; then
            # Проверяем что исходный путь существует
            if [ -d "$ORIGINAL_SOURCE" ] && [ -f "$ORIGINAL_SOURCE/plugin.xml" ]; then
                PLUGIN_SOURCE_PATH="$ORIGINAL_SOURCE"
                echo -e "${GREEN}Найден исходный путь плагина: $PLUGIN_SOURCE_PATH${NC}"
            fi
        fi
    fi
    
    # Если исходный путь не найден, ищем локальные копии
    if [ -z "$PLUGIN_SOURCE_PATH" ]; then
        # Проверяем есть ли плагин как поддиректория проекта (не в plugins/)
        while IFS= read -r plugin_xml; do
            if [ -n "$plugin_xml" ]; then
                plugin_dir=$(dirname "$plugin_xml")
                # Пропускаем plugins/ директорию
                if [[ "$plugin_dir" != ./plugins/* ]]; then
                    plugin_id_found=$(grep -o 'id="[^"]*"' "$plugin_xml" | head -1 | sed 's/id="//;s/"//')
                    if [ "$plugin_id_found" = "$PLUGIN_ID" ]; then
                        PLUGIN_SOURCE_PATH="$plugin_dir"
                        echo -e "${GREEN}Найден локальный исходный код: $PLUGIN_SOURCE_PATH${NC}"
                        break
                    fi
                fi
            fi
        done < <(find . -name "plugin.xml" -not -path "./plugins/*" 2>/dev/null)
    fi
    
    # Проверяем есть ли плагин в plugins/ директории (это копия)
    if [ -d "plugins/$PLUGIN_ID" ]; then
        LOCAL_PLUGIN_DIR="plugins/$PLUGIN_ID"
        echo -e "${BLUE}Найдена установленная копия: $LOCAL_PLUGIN_DIR${NC}"
    fi
    
    # Принудительно удаляем плагин
    echo -e "\n${YELLOW}🗑️  Удаление плагина $PLUGIN_ID...${NC}"
    cordova plugin remove "$PLUGIN_ID" --force 2>/dev/null || cordova plugin remove "$PLUGIN_ID" 2>/dev/null || true
    
    # Очищаем кеш
    echo -e "${YELLOW}🧹 Очистка кеша...${NC}"
    rm -rf platforms/android/app/src/main/java/*/plugins/* 2>/dev/null || true
    rm -rf platforms/ios/*/Plugins/* 2>/dev/null || true
    rm -rf plugins/"$PLUGIN_ID" 2>/dev/null || true
    
    # Определяем откуда устанавливать плагин (приоритет локальным исходникам)
    if [ -n "$PLUGIN_SOURCE_PATH" ] && [ -d "$PLUGIN_SOURCE_PATH" ]; then
        INSTALL_FROM="$PLUGIN_SOURCE_PATH"
        echo -e "${GREEN}Будет установлен из локального исходника: $INSTALL_FROM${NC}"
    else
        # Устанавливаем из npm registry
        INSTALL_FROM="$PLUGIN_ID"
        echo -e "${BLUE}Будет установлен из npm registry${NC}"
    fi
    
    # Устанавливаем плагин заново
    echo -e "\n${GREEN}📦 Установка плагина из: $INSTALL_FROM${NC}"
    if cordova plugin add "$INSTALL_FROM"; then
        echo -e "\n${GREEN}✅ Плагин '$PLUGIN_ID' успешно переустановлен!${NC}"
        
        # Показываем финальный статус
        echo -e "\n${BLUE}📋 Результат:${NC}"
        cordova plugin list | grep "$PLUGIN_ID" || echo "Плагин не найден в списке"
        
    else
        echo -e "\n${RED}❌ Ошибка при установке плагина${NC}"
        exit 1
    fi
    
    # Возвращаемся в исходную директорию
    cd "$CURRENT_DIR"
}

handle_method_command() {
    local subcommand="$1"
    local method_name="$2"
    
    case "$subcommand" in
        "add")
            if [ -z "$method_name" ]; then
                echo -e "${RED}❌ Method name is required${NC}"
                echo "Usage: cordex method add <methodName>"
                exit 1
            fi
            add_method "$method_name"
            ;;
        "remove")
            if [ -z "$method_name" ]; then
                echo -e "${RED}❌ Method name is required${NC}"
                echo "Usage: cordex method remove <methodName>"
                exit 1
            fi
            remove_method "$method_name"
            ;;
        "")
            echo -e "${RED}❌ Subcommand required${NC}"
            echo "Usage: cordex method <add|remove> <methodName>"
            echo ""
            echo "Available subcommands:"
            echo "  add <methodName>     Add new method to plugin"
            echo "  remove <methodName>  Remove method from plugin"
            exit 1
            ;;
        *)
            echo -e "${RED}❌ Unknown method subcommand: $subcommand${NC}"
            echo "Usage: cordex method <add|remove> <methodName>"
            exit 1
            ;;
    esac
}

handle_plugin_command() {
    local subcommand="$1"
    local plugin_id="$2"
    
    case "$subcommand" in
        "reinstall")
            reinstall_plugin "$plugin_id"
            ;;
        "")
            echo -e "${RED}❌ Subcommand required${NC}"
            echo "Usage: cordex plugin <reinstall> [pluginId]"
            echo ""
            echo "Available subcommands:"
            echo "  reinstall [pluginId]  Reinstall plugin in Cordova project"
            exit 1
            ;;
        *)
            echo -e "${RED}❌ Unknown plugin subcommand: $subcommand${NC}"
            echo "Usage: cordex plugin <reinstall> [pluginId]"
            exit 1
            ;;
    esac
}

# Main command handling
case "$1" in
    "init")
        init_plugin
        ;;
    "setup")
        run_setup
        ;;
    "method")
        handle_method_command "$2" "$3"
        ;;
    "plugin")
        handle_plugin_command "$2" "$3"
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac