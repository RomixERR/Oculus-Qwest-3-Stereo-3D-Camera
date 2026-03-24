@echo off
chcp 65001 >nul
title Oculus Quest 3 Capture Mode Switch

echo ================================
echo Проверка подключения устройства
echo ================================
adb devices

echo.
echo Если статус "unauthorized":
echo - Наденьте шлем
echo - Подтвердите "Allow USB debugging"
echo.
pause

:wait_auth
for /f "tokens=2" %%i in ('adb devices ^| findstr /r /c:"device$"') do (
    set DEVICE_FOUND=1
)

if not defined DEVICE_FOUND (
    echo Ожидание авторизации устройства...
    timeout /t 3 >nul
    goto wait_auth
)

echo Устройство авторизовано!
timeout /t 1 >nul
pause

:mode_select
cls
echo ================================
echo Выбор режима записи
echo ================================
echo 1 - Стерео режим
echo 2 - Моно (по умолчанию)
echo.

choice /c 12 /m "Выберите режим:"

if errorlevel 2 goto mono
if errorlevel 1 goto stereo

:stereo
echo.
echo Установка СТЕРЕО режима...

adb shell setprop debug.oculus.screenCaptureEye 2
adb shell setprop debug.oculus.capture.width 3840
adb shell setprop debug.oculus.capture.height 1920
adb shell setprop debug.oculus.fullRateCapture 1
adb shell setprop debug.oculus.capture.bitrate 40000000
adb shell setprop debug.oculus.refreshRate 72
adb shell setprop debug.oculus.capture.fps 60

goto fs

:mono
echo.
echo Установка МОНО режима...

adb shell setprop debug.oculus.screenCaptureEye 1
adb shell setprop debug.oculus.capture.width 1920
adb shell setprop debug.oculus.capture.height 1080
adb shell setprop debug.oculus.fullRateCapture 0
adb shell setprop debug.oculus.capture.bitrate 15000000

goto fs

:fs
echo.
echo ================================
echo Force Stop media provider?
echo ================================
echo 1 - Да
echo 2 - Нет
echo.

choice /c 12 /m "Сделать Force-Stop?"

if errorlevel 2 goto end
if errorlevel 1 goto dofs

:dofs
echo Выполняется Force-Stop...
adb shell am force-stop com.android.providers.media.module
goto end

:end
echo.
echo ================================
echo СКРИПТ ЗАВЕРШЁН
echo ================================
pause