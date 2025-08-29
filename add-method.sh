#!/bin/bash

# Script to add empty methods to Android, iOS and JavaScript parts of Cordova plugin
# Usage: ./add-method-fixed.sh <methodName>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <methodName>"
    echo "Example: $0 myNewMethod"
    exit 1
fi

METHOD_NAME="$1"

# Load file paths from setup
if [ -f ".plugin-files" ]; then
    source .plugin-files
else
    echo "Error: .plugin-files not found. Please run ./setup.sh first."
    exit 1
fi

echo "Adding method '$METHOD_NAME' to all platforms..."

# Add to Android (Kotlin)
echo "Adding to Android..."

# Add case to when statement before the else clause
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "/else -> {/i\\
                \"$METHOD_NAME\" -> {\\
                    $METHOD_NAME(args, callbackContext)\\
                    true\\
                }\\
" "$ANDROID_FILE"
else
    # Linux
    sed -i "/else -> {/i\\
                \"$METHOD_NAME\" -> {\\
                    $METHOD_NAME(args, callbackContext)\\
                    true\\
                }\\
" "$ANDROID_FILE"
fi

# Add method implementation before the closing brace of the class
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "/^}$/i\\
\\
    private fun $METHOD_NAME(args: JSONArray, callbackContext: CallbackContext) {\\
        if (!helper.checkInitialized(isInitialized, callbackContext)) {\\
            return\\
        }\\
\\
        try {\\
            helper.log(\"$METHOD_NAME called\")\\
            \\
            // Add your method logic here\\
            \\
            helper.callbackSuccess(callbackContext, \"$METHOD_NAME executed successfully\")\\
            \\
        } catch (e: Exception) {\\
            helper.log(\"$METHOD_NAME error\", e.message)\\
            helper.callbackError(callbackContext, \"$METHOD_NAME error\", e.message)\\
        }\\
    }
" "$ANDROID_FILE"
else
    # Linux
    sed -i "/^}$/i\\
\\
    private fun $METHOD_NAME(args: JSONArray, callbackContext: CallbackContext) {\\
        if (!helper.checkInitialized(isInitialized, callbackContext)) {\\
            return\\
        }\\
\\
        try {\\
            helper.log(\"$METHOD_NAME called\")\\
            \\
            // Add your method logic here\\
            \\
            helper.callbackSuccess(callbackContext, \"$METHOD_NAME executed successfully\")\\
            \\
        } catch (e: Exception) {\\
            helper.log(\"$METHOD_NAME error\", e.message)\\
            helper.callbackError(callbackContext, \"$METHOD_NAME error\", e.message)\\
        }\\
    }
" "$ANDROID_FILE"
fi

# Add to iOS (Swift)
echo "Adding to iOS..."

# Add method implementation before the helper methods section
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "/\/\/ MARK: - Add your plugin methods here/a\\
\\
    @objc($METHOD_NAME:)\\
    func $METHOD_NAME(command: CDVInvokedUrlCommand) {\\
        guard checkInitialized(isInitialized, command: command) else {\\
            return\\
        }\\
        \\
        do {\\
            log(\"$METHOD_NAME called\")\\
            \\
            // Add your method logic here\\
            \\
            sendSuccess(command: command, message: \"$METHOD_NAME executed successfully\")\\
            \\
        } catch {\\
            logError(\"$METHOD_NAME error: \\\\(error.localizedDescription)\")\\
            sendError(command: command, message: \"$METHOD_NAME error: \\\\(error.localizedDescription)\")\\
        }\\
    }
" "$IOS_FILE"
else
    # Linux
    sed -i "/\/\/ MARK: - Add your plugin methods here/a\\
\\
    @objc($METHOD_NAME:)\\
    func $METHOD_NAME(command: CDVInvokedUrlCommand) {\\
        guard checkInitialized(isInitialized, command: command) else {\\
            return\\
        }\\
        \\
        do {\\
            log(\"$METHOD_NAME called\")\\
            \\
            // Add your method logic here\\
            \\
            sendSuccess(command: command, message: \"$METHOD_NAME executed successfully\")\\
            \\
        } catch {\\
            logError(\"$METHOD_NAME error: \\\\(error.localizedDescription)\")\\
            sendError(command: command, message: \"$METHOD_NAME error: \\\\(error.localizedDescription)\")\\
        }\\
    }
" "$IOS_FILE"
fi

# Add to iOS Header (Objective-C .h file)
echo "Adding to iOS Header..."

# Add method declaration before the @end directive
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "/@end/i\\
- (void)$METHOD_NAME:(CDVInvokedUrlCommand*)command;\\
" "$IOS_HEADER_FILE"
else
    # Linux
    sed -i "/@end/i\\
- (void)$METHOD_NAME:(CDVInvokedUrlCommand*)command;\\
" "$IOS_HEADER_FILE"
fi

# Add to JavaScript
echo "Adding to JavaScript..."

# Add method implementation before the closing brace of the return object
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "/\/\/ Add your plugin methods here/a\\
\\
        /**\\
         * $METHOD_NAME\\
         * @param {Object} params - method parameters\\
         * @param {Function} params.onSuccess - optional on success callback\\
         * @param {Function} params.onFailure - optional on failure callback\\
         */\\
        $METHOD_NAME: function $METHOD_NAME(params)\\
        {\\
            return new Promise((resolve, reject) => {\\
                params = defaults(params, {});\\
\\
                callPlugin('$METHOD_NAME', [params], resolve, reject);\\
            });\\
        },
" "$JS_FILE"
else
    # Linux
    sed -i "/\/\/ Add your plugin methods here/a\\
\\
        /**\\
         * $METHOD_NAME\\
         * @param {Object} params - method parameters\\
         * @param {Function} params.onSuccess - optional on success callback\\
         * @param {Function} params.onFailure - optional on failure callback\\
         */\\
        $METHOD_NAME: function $METHOD_NAME(params)\\
        {\\
            return new Promise((resolve, reject) => {\\
                params = defaults(params, {});\\
\\
                callPlugin('$METHOD_NAME', [params], resolve, reject);\\
            });\\
        },
" "$JS_FILE"
fi

echo "Method '$METHOD_NAME' successfully added to:"
echo "  - Android: $ANDROID_FILE"
echo "  - iOS: $IOS_FILE"
echo "  - iOS Header: $IOS_HEADER_FILE"
echo "  - JavaScript: $JS_FILE"
echo ""
echo "The method returns success by default. You can now implement the actual logic."