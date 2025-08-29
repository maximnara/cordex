# Cordex - Cordova Plugin Manager

Мощный CLI инструмент для разработки Cordova плагинов с автоматической генерацией кода для Android, iOS и JavaScript.

## ☕ Поддержать проект
[![Поддержать на Boosty](https://img.shields.io/badge/Поддержать-Boosty-orange?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)](https://boosty.to/maximnara)

**💝 Если проект помог вам в разработке, рассмотрите возможность поддержки разработчика:** [**boosty.to/maximnara**](https://boosty.to/maximnara)

## 🚀 Установка

### Глобальная установка (рекомендуется)
```bash
npm install -g cordex
```

### Проверка установки
```bash
cordex help
```

### Обновление до последней версии
```bash
npm update -g cordex
```

### Удаление
```bash
npm uninstall -g cordex
```

## 📋 Команды

### `cordex init`
Создает новый Cordova плагин с интерактивной настройкой.

```bash
cordex init
```

**Что происходит:**
1. Интерактивный ввод данных о плагине
2. Автоматическое создание папки (`cordova-plugin-название`)
3. Скачивание актуального шаблона из [cordova-plugin-template](https://github.com/maximnara/cordova-plugin-template)
4. Извлечение готовой структуры файлов из шаблона
5. Замена плейсхолдеров на реальные данные
6. Переименование файлов согласно названию плагина

**Источник шаблона:**
Менеджер скачивает актуальную структуру из репозитория [cordova-plugin-template](https://github.com/maximnara/cordova-plugin-template), который содержит готовые файлы для Android, iOS и JavaScript платформ.

**Пример использования:**
```bash
$ cordex init
🚀 Инициализация нового Cordova плагина

Введите основные данные для плагина:

1. Название плагина (например: awesome camera): Camera Scanner
2. Ваше имя или компания: John Doe
3. GitHub username (для репозитория): johndoe

📁 Создается папка: cordova-plugin-camera-scanner
✅ Плагин готов к использованию!
```

### `cordex setup`
Настраивает Cordova плагин в текущей директории.

```bash
cordex setup
```

**Требования:**
- Пустая или содержащая только файлы cordex директория
- Наличие Git (для скачивания шаблона)

**Источник данных:**
Команда скачивает актуальную структуру плагина из репозитория [cordova-plugin-template](https://github.com/maximnara/cordova-plugin-template) и настраивает его под ваши данные.

**Использование:**
```bash
mkdir my-plugin && cd my-plugin
cordex setup
```

### `cordex method add <methodName>`
Добавляет новый метод в существующий плагин.

```bash
cordex method add scanQRCode
```

**Что создается:**
- JavaScript метод в `www/plugin-name.js`
- Android метод в `src/android/PluginClass.kt`
- iOS метод в `src/ios/PluginClass.swift`
- Обновление `plugin.xml`

### `cordex method remove <methodName>`
Удаляет метод из плагина.

```bash
cordex method remove oldMethod
```

**Что удаляется:**
- Метод из всех платформ
- Соответствующие записи в конфигурации

### `cordex plugin reinstall [pluginId]`
Переустанавливает Cordova плагин в проекте. Автоматически находит корень Cordova проекта и позволяет выбрать плагин для переустановки.

```bash
# Интерактивный выбор плагина
cordex plugin reinstall

# Переустановка конкретного плагина
cordex plugin reinstall cordova-plugin-camera
```

**Что происходит:**
1. Поиск корневой директории Cordova проекта (наличие config.xml и platforms/)
2. Получение списка установленных плагинов
3. Интерактивное меню выбора или использование указанного плагина
4. Принудительное удаление плагина (`--force`)
5. Очистка кеша платформ (Android/iOS)
6. Определение источника установки (локальный исходник или npm registry)
7. Повторная установка плагина

**Особенности:**
- Автоматически определяет источник плагина из `fetch.json`
- Поддерживает локальные плагины (разработка)
- Интерактивная навигация с помощью стрелок ↑↓
- Приоритет локальным исходникам над npm registry

### `cordex help`
Показывает справку по всем доступным командам.

## 🏗️ Структура создаваемого плагина

```
cordova-plugin-example/
├── plugin.xml              # Конфигурация плагина
├── package.json            # NPM конфигурация
├── www/
│   └── example.js          # JavaScript интерфейс
├── src/
│   ├── android/
│   │   ├── ExamplePlugin.kt    # Android реализация
│   │   └── example.gradle      # Android зависимости
│   └── ios/
│       ├── ExamplePlugin.swift # iOS реализация
│       └── ExamplePlugin.h     # iOS заголовок
└── README.md               # Документация плагина
```

## 🎯 Автоматическая генерация

### Из названия "Camera Scanner" генерируется:

| Параметр | Значение | Использование |
|----------|----------|---------------|
| Plugin ID | `cordova-plugin-camera-scanner` | Идентификатор пакета |
| Folder Name | `cordova-plugin-camera-scanner` | Имя директории |
| Plugin Name | `CameraScanner Plugin` | Отображаемое имя |
| JS Module | `CameraScanner` | JavaScript объект |
| Android Class | `CameraScannerPlugin` | Kotlin класс |
| Android Package | `com.username.camera.scanner` | Java пакет |
| iOS Class | `CameraScannerPlugin` | Swift класс |
| Repository | `https://github.com/username/cordova-plugin-camera-scanner` | Git репозиторий |

## 🔧 Особенности

### Поддерживаемые платформы
- ✅ **Android** - Kotlin
- ✅ **iOS** - Swift  
- ✅ **JavaScript** - ES6+

### Автоматические преобразования
- **camelCase** → `CameraScanner`
- **kebab-case** → `camera-scanner`
- **package.path** → `com/username/camera/scanner`

### Умная замена плейсхолдеров
Cordex автоматически заменяет все плейсхолдеры в:
- `plugin.xml`
- `package.json` 
- JavaScript файлах
- Android Kotlin файлах
- iOS Swift файлах
- Gradle конфигурации

## 📱 Пример использования плагина

После создания плагина:

### 1. Установка в проект
```bash
cordova plugin add ./cordova-plugin-camera-scanner
```

### 2. Использование в коде
```javascript
// Инициализация
CameraScanner.init({
    option1: 'value1',
    option2: 'value2'
}, function(success) {
    console.log('Plugin initialized:', success);
}, function(error) {
    console.error('Initialization failed:', error);
});

// Если добавили метод scanQRCode
CameraScanner.scanQRCode({}, function(result) {
    console.log('QR Code:', result);
}, function(error) {
    console.error('Scan failed:', error);
});
```

## 🛠️ Требования

- **Node.js** >= 12.0.0
- **Git** (для скачивания шаблонов)
- **Bash** shell
- Стандартные Unix утилиты (`sed`, `awk`, `grep`)

## 🔄 Workflow разработки

### Создание нового плагина
```bash
# 1. Создание плагина
cordex init

# 2. Добавление методов
cd cordova-plugin-your-name
cordex method add method1
cordex method add method2

# 3. Разработка логики в src/
# Редактируйте Android, iOS и JS файлы

# 4. Тестирование
cordova plugin add ./
```

### Обновление существующего
```bash
# Добавление нового метода
cordex method add newFeature

# Удаление старого метода
cordex method remove deprecatedMethod

# Переустановка плагина в Cordova проекте
cordex plugin reinstall
```

## 📁 Файловая система

### После setup
Создается `.plugin-files` с путями к основным файлам плагина для использования командами `method add` и `method remove`.

## ⚠️ Важные замечания

1. **Чистая директория**: `cordex setup` требует пустую директорию
2. **Git**: Необходим для скачивания актуальных шаблонов
3. **Резервные копии**: При операциях создаются бэкапы файлов
4. **Совместимость**: Работает на macOS и Linux

## 🐛 Устранение проблем

### "Setup script not found"
```bash
# Переустановите cordex
npm uninstall -g cordex
npm install -g cordex
```

### "Directory not empty"
```bash
# Для setup - используйте пустую директорию
mkdir new-plugin && cd new-plugin
cordex setup

# Для init - команда создаст директорию сама
cordex init
```

### "Git not found"
```bash
# Установите Git
# macOS: xcode-select --install
# Ubuntu: sudo apt install git
```

## 📄 Лицензия

MIT License

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch
3. Внесите изменения
4. Создайте Pull Request

## 📞 Поддержка

- GitHub Issues: [Сообщить о проблеме](https://github.com/maximnara/cordova-plugin-manager/issues)
- Шаблон плагина: [cordova-plugin-template](https://github.com/maximnara/cordova-plugin-template)

## ☕ Понравился проект?

**🎯 Поддержите разработку новых функций и исправление багов:**

[![Поддержать на Boosty](https://img.shields.io/badge/💝_Поддержать_разработчика-Boosty-ff6b35?style=for-the-badge&labelColor=2d2d2d)](https://boosty.to/maximnara)

**Ваша поддержка помогает:**
- 🚀 Добавлять новые функции
- 🐛 Исправлять ошибки быстрее  
- 📖 Улучшать документацию
- 🎨 Развивать экосистему инструментов

---

**Cordex** - делает разработку Cordova плагинов простой и быстрой! 🚀