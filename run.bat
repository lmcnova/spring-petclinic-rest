@echo off
REM Run Spring PetClinic REST Application

echo Starting Spring PetClinic REST...
echo.
echo   Application URL : http://localhost:9966/petclinic/
echo   Swagger UI      : http://localhost:9966/petclinic/swagger-ui.html
echo   Health Check    : http://localhost:9966/petclinic/actuator/health
echo.
echo   Press Ctrl+C to stop.
echo.

java -jar target\spring-petclinic-rest-4.0.2.jar
