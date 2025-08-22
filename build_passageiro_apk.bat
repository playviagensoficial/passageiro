@echo off
echo ========================================
echo     BUILD APK - PLAY VIAGENS PASSAGEIRO
echo ========================================

REM Configurar variaveis de ambiente para otimizar memoria
set DART_VM_OPTIONS=--old_gen_heap_size=2048
set GRADLE_OPTS=-Xmx1536m -Dfile.encoding=UTF-8
set JAVA_OPTS=-Xmx1536m

echo Configurando memoria: Dart VM = 2GB, Gradle = 1.5GB

echo.
echo [1/6] Parando daemons do Gradle...
cd android
call gradlew --stop
cd ..

echo.
echo [2/6] Limpando projeto...
call flutter clean

echo.
echo [3/6] Removendo caches antigos...
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo.
echo [4/6] Obtendo dependencias...
call flutter pub get

echo.
echo [5/6] Construindo APK Release do Passageiro...
call flutter build apk --release --no-shrink --split-per-abi

echo.
echo [6/6] Build concluido!
echo.
echo APKs gerados em: build\app\outputs\flutter-apk\
echo - app-arm64-v8a-release.apk (dispositivos modernos)
echo - app-armeabi-v7a-release.apk (dispositivos antigos)
echo - app-x86_64-release.apk (emuladores)

echo.
dir build\app\outputs\flutter-apk\*.apk /b

echo.
pause