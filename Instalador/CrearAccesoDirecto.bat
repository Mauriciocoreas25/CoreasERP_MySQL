@echo off
title Instalador de Acceso Directo - Coreas ERP
echo ========================================================
echo   Configurando Coreas ERP en esta estacion de trabajo
echo ========================================================
echo.
echo Creando acceso directo en el Escritorio...
set SCRIPT="%TEMP%\crear_acceso_%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") > %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\Coreas ERP.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%~dp0CoreasERP.exe" >> %SCRIPT%
echo oLink.WorkingDirectory = "%~dp0" >> %SCRIPT%
echo oLink.Description = "Coreas ERP - Sistema de Facturacion Electronica DTE e Inventario" >> %SCRIPT%
if exist "%~dp0appicon.ico" (
    echo oLink.IconLocation = "%~dp0appicon.ico,0" >> %SCRIPT%
)
echo oLink.Save >> %SCRIPT%
cscript /nologo %SCRIPT%
del %SCRIPT%
echo.
echo ========================================================
echo  [OK] Acceso directo creado exitosamente en el Escritorio.
echo  Ya puedes iniciar "Coreas ERP" directamente.
echo ========================================================
echo.
pause
