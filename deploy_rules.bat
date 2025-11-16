@echo off
echo Aplicando regras de segurança do Firestore...
echo.

REM Verificar se o Firebase CLI está instalado
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Firebase CLI não está instalado!
    echo Por favor, instale o Firebase CLI:
    echo npm install -g firebase-tools
    pause
    exit /b 1
)

echo Firebase CLI encontrado!
echo.
echo Aplicando regras de segurança...
firebase firestore:rules deploy --project pleno-nexo

if %errorlevel% equ 0 (
    echo.
    echo Regras aplicadas com sucesso!
) else (
    echo.
    echo ERRO ao aplicar regras!
    echo Verifique se você está logado no Firebase: firebase login
)

pause