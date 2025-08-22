@echo off
echo ========================================
echo  BUILD MINIMAL - PLAY VIAGENS PASSAGEIRO  
echo ========================================

REM Configuracoes minimas de memoria
set DART_VM_OPTIONS=--old_gen_heap_size=1024
set GRADLE_OPTS=-Xmx1024m -XX:MaxMetaspaceSize=256m
set JAVA_OPTS=-Xmx1024m
set FLUTTER_BUILD_MODE=release

echo Configuracao MINIMAL: Dart=1GB, Gradle=1GB

echo.
echo [1/8] Matando todos os processos Java/Gradle...
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM javaw.exe >nul 2>&1
taskkill /F /IM gradle.exe >nul 2>&1

echo [2/8] Limpando TUDO...
call flutter clean

echo [3/8] Removendo caches completos...
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "%USERPROFILE%\.gradle\daemon" rmdir /s /q "%USERPROFILE%\.gradle\daemon"

echo [4/8] Parando daemon forcadamente...
cd android
call gradlew --stop --no-daemon
cd ..

echo [5/8] Pub get minimo...
call flutter pub get

echo [6/8] Tentando build via gradlew direto...
cd android
echo Executando: gradlew assembleRelease --no-daemon --no-build-cache
call gradlew assembleRelease --no-daemon --no-build-cache --stacktrace
if %ERRORLEVEL% NEQ 0 goto :gradle_failed
cd ..
goto :success

:gradle_failed
cd ..
echo [7/8] Gradle falhou, tentando flutter build...
call flutter build apk --release --no-shrink --debug-info --verbose

:success
echo [8/8] Verificando APKs gerados...
if exist "build\app\outputs\flutter-apk\*.apk" (
    echo APKs encontrados:
    dir build\app\outputs\flutter-apk\*.apk /b
) else if exist "android\app\build\outputs\apk\release\*.apk" (
    echo APKs encontrados em outputs alternativos:
    dir android\app\build\outputs\apk\release\*.apk /b
) else (
    echo ERRO: Nenhum APK foi gerado!
)

echo.
echo Build concluido!
pause