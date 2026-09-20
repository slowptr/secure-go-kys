#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BUILD="$ROOT/build"
API_CLASSES="$BUILD/api-classes"
MODULE_CLASSES="$BUILD/module-classes"
DEX="$BUILD/dex"
API_JAR="$BUILD/xposed-api-stubs.jar"
BASE_APK="$BUILD/base.apk"
SIGNED_APK="$BUILD/signed.apk"
OUTPUT_APK="$BUILD/secure-go-kys-0.1.apk"

ANDROID_HOME=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}
[ -n "$ANDROID_HOME" ] || { echo "error: set ANDROID_HOME to your Android SDK" >&2; exit 1; }
ANDROID_JAR="$ANDROID_HOME/platforms/android-33/android.jar"
BUILD_TOOLS="$ANDROID_HOME/build-tools/33.0.2"
KEYSTORE=${KEYSTORE:-$ROOT/signing/keystore.jks}
ALIAS=${ALIAS:-securegokys}
: "${STOREPASS:?set STOREPASS for the module key}"
: "${KEYPASS:?set KEYPASS for the module key}"

[ -f "$ANDROID_JAR" ] || { echo "error: missing $ANDROID_JAR" >&2; exit 1; }
[ -f "$KEYSTORE" ] || { echo "error: missing keystore $KEYSTORE" >&2; exit 1; }

rm -rf "$BUILD"
mkdir -p "$API_CLASSES" "$MODULE_CLASSES" "$DEX"

javac --release 8 -cp "$ANDROID_JAR" -d "$API_CLASSES" \
    $(find "$ROOT/src/de" -name '*.java' -type f)
jar cf "$API_JAR" -C "$API_CLASSES" .

javac --release 8 -cp "$API_JAR:$ANDROID_JAR" -d "$MODULE_CLASSES" \
    $(find "$ROOT/src/com" -name '*.java' -type f)

"$BUILD_TOOLS/d8" --min-api 26 --lib "$ANDROID_JAR" --lib "$API_JAR" \
    --output "$DEX" $(find "$MODULE_CLASSES" -name '*.class' -type f)

"$BUILD_TOOLS/aapt2" link -o "$BASE_APK" -I "$ANDROID_JAR" \
    --manifest "$ROOT/AndroidManifest.xml" -A "$ROOT/assets" \
    --min-sdk-version 26 --target-sdk-version 29
(cd "$DEX" && jar uf "$BASE_APK" classes.dex)

jarsigner -keystore "$KEYSTORE" -storepass "$STOREPASS" -keypass "$KEYPASS" \
    -signedjar "$SIGNED_APK" "$BASE_APK" "$ALIAS"
"$BUILD_TOOLS/zipalign" -f 4 "$SIGNED_APK" "$OUTPUT_APK"
jarsigner -verify "$OUTPUT_APK"

printf '%s\n' "$OUTPUT_APK"
sha256sum "$OUTPUT_APK"
