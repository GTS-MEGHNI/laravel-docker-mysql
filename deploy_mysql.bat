@echo off
setlocal

REM Set variables
set "NETWORK_NAME=laravel_network"
set "MYSQL_CONTAINER_NAME=mysql_container"
set "MYSQL_ROOT_PASSWORD=66662c65-3606-41b8-8f18-dcf8c389af55"
set "MYSQL_HOST_PORT=3500"

echo Creating Docker network: %NETWORK_NAME%...

REM Check if the Docker network exists, if not create it
docker network inspect %NETWORK_NAME% >nul 2>&1
if errorlevel 1 (
    docker network create %NETWORK_NAME%
)

echo Running MySQL container on %NETWORK_NAME% network, host port %MYSQL_HOST_PORT%...

docker run -d ^
 --name %MYSQL_CONTAINER_NAME% ^
 --network %NETWORK_NAME% ^
 -e MYSQL_ROOT_PASSWORD=%MYSQL_ROOT_PASSWORD% ^
 -e MYSQL_DATABASE=your_database_name ^
 -e MYSQL_USER=your_db_user ^
 -e MYSQL_PASSWORD=your_db_password ^
 -p %MYSQL_HOST_PORT%:3306 ^
 mysql:latest

endlocal
pause
