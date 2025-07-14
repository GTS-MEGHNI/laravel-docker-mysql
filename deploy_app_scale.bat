@echo off
SETLOCAL ENABLEEXTENSIONS

:: === Configuration ===
set SCALE_COUNT=1

echo.
echo =======================================
echo Building Laravel app image...
echo =======================================
docker compose build app
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to build Laravel app.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo =======================================
echo Building Nginx image...
echo =======================================
docker compose build nginx
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to build Nginx image.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo =======================================
echo Stopping existing Docker containers...
echo =======================================
docker compose down
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to stop Docker Compose setup.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo =======================================
echo Starting Docker containers with scaling
echo Project: laravel
echo Service: app (%SCALE_COUNT%x instances)
echo =======================================
docker compose -p laravel up --scale app=%SCALE_COUNT% -d
IF %ERRORLEVEL% NEQ 0 (
    echo Failed to start Docker Compose with scaling.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo =======================================
echo Deployment completed successfully.
echo Containers are now running.
echo =======================================
pause
