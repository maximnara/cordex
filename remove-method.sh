#!/bin/bash

# Script to remove methods from Android, iOS and JavaScript parts of Cordova plugin
# Usage: ./remove-method.sh <methodName>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <methodName>"
    echo "Example: $0 myOldMethod"
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

echo "Removing method '$METHOD_NAME' from all platforms..."

# Check if method exists in files before attempting removal
METHOD_EXISTS=false

if grep -q "\"$METHOD_NAME\"" "$ANDROID_FILE" 2>/dev/null; then
    METHOD_EXISTS=true
fi

if grep -q "@objc($METHOD_NAME:" "$IOS_FILE" 2>/dev/null; then
    METHOD_EXISTS=true
fi

if grep -q "- ($METHOD_NAME:" "$IOS_HEADER_FILE" 2>/dev/null; then
    METHOD_EXISTS=true
fi

if grep -q "$METHOD_NAME: function $METHOD_NAME" "$JS_FILE" 2>/dev/null; then
    METHOD_EXISTS=true
fi

if [ "$METHOD_EXISTS" = false ]; then
    echo "Method '$METHOD_NAME' not found in any platform files."
    exit 1
fi

# Create backup files
cp "$ANDROID_FILE" "$ANDROID_FILE.backup"
cp "$IOS_FILE" "$IOS_FILE.backup" 
cp "$IOS_HEADER_FILE" "$IOS_HEADER_FILE.backup"
cp "$JS_FILE" "$JS_FILE.backup"

# Remove from Android (Kotlin)
echo "Removing from Android..."

# Create a temporary file for processing
TEMP_FILE=$(mktemp)

# Remove case from when statement and method implementation
awk -v method="$METHOD_NAME" '
BEGIN { 
    skip_case = 0
    skip_method = 0
    brace_count = 0
}

# Skip case statement
/^[[:space:]]*"'"$METHOD_NAME"'" -> {/ {
    skip_case = 1
    brace_count = 1
    next
}

skip_case && /{/ { brace_count++ }
skip_case && /}/ { 
    brace_count--
    if (brace_count == 0) {
        skip_case = 0
    }
    next
}

skip_case { next }

# Skip method implementation
/^[[:space:]]*private fun '"$METHOD_NAME"'\(/ {
    skip_method = 1
    brace_count = 1
    next
}

skip_method && /{/ { brace_count++ }
skip_method && /}/ {
    brace_count--
    if (brace_count == 0) {
        skip_method = 0
    }
    next
}

skip_method { next }

# Print all other lines
{ print }
' "$ANDROID_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$ANDROID_FILE"

# Remove from iOS (Swift)
echo "Removing from iOS..."

TEMP_FILE=$(mktemp)

awk -v method="$METHOD_NAME" '
BEGIN { 
    skip_method = 0
    brace_count = 0
}

# Skip method implementation
/^[[:space:]]*@objc\('"$METHOD_NAME"':\)/ {
    skip_method = 1
    brace_count = 0
    next
}

skip_method && /{/ { brace_count++ }
skip_method && /}/ {
    brace_count--
    if (brace_count == 0) {
        skip_method = 0
    }
    next
}

skip_method { next }

# Print all other lines
{ print }
' "$IOS_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$IOS_FILE"

# Remove from iOS Header (Objective-C .h file)
echo "Removing from iOS Header..."

TEMP_FILE=$(mktemp)

awk -v method="$METHOD_NAME" '
BEGIN { 
    skip_method = 0
}

# Skip method declaration in header file
/^[[:space:]]*-[[:space:]]*\([^)]*\)[[:space:]]*'"$METHOD_NAME"'/ {
    skip_method = 1
    next
}

skip_method && /;/ {
    skip_method = 0
    next
}

skip_method { next }

# Print all other lines
{ print }
' "$IOS_HEADER_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$IOS_HEADER_FILE"

# Remove from JavaScript
echo "Removing from JavaScript..."

TEMP_FILE=$(mktemp)

awk -v method="$METHOD_NAME" '
BEGIN { 
    skip_jsdoc = 0
    skip_method = 0
    brace_count = 0
    in_method_jsdoc = 0
}

# Check for JSDoc comment that might be for our method
/^[[:space:]]*\/\*\*/ {
    # Look ahead to see if this JSDoc is for our method
    jsdoc_start = NR
    jsdoc_lines = $0
    while ((getline next_line) > 0) {
        jsdoc_lines = jsdoc_lines "\n" next_line
        if (next_line ~ /\*\//) {
            # End of JSDoc, check next non-empty line
            while ((getline check_line) > 0) {
                if (check_line ~ /^[[:space:]]*$/) continue  # skip empty lines
                if (check_line ~ "^[[:space:]]*" method ": function " method) {
                    # This JSDoc belongs to our method, skip it
                    skip_jsdoc = 1
                    skip_method = 1
                    brace_count = 0
                    next
                } else {
                    # This JSDoc is not for our method, print it
                    print jsdoc_lines
                    print check_line
                    break
                }
            }
            break
        }
    }
    if (!skip_jsdoc) next
}

skip_jsdoc { 
    skip_jsdoc = 0
    next 
}

# Skip method implementation
skip_method || /^[[:space:]]*'"$METHOD_NAME"': function '"$METHOD_NAME"'/ {
    if (!skip_method) {
        skip_method = 1
        brace_count = 0
    }
    next
}

skip_method && /{/ { brace_count++ }
skip_method && /}/ {
    brace_count--
    if (brace_count == 0) {
        skip_method = 0
        # Skip trailing comma if present
        if ((getline next_line) > 0) {
            if (next_line !~ /^[[:space:]]*,$/) {
                print next_line
            }
        }
    }
    next
}

skip_method { next }

# Print all other lines
{ print }
' "$JS_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$JS_FILE"

echo "Method '$METHOD_NAME' successfully removed from:"
echo "  - Android: $ANDROID_FILE"
echo "  - iOS: $IOS_FILE" 
echo "  - iOS Header: $IOS_HEADER_FILE"
echo "  - JavaScript: $JS_FILE"
echo ""
echo "Backup files created with .backup extension"