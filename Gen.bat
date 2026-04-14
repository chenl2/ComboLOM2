@echo off
setlocal enabledelayedexpansion

:: =====================================================================
:: 1. Execute Header Generation Tasks
:: =====================================================================

:: Task 1: Generate for MirBaseLib
call :GenerateMasterHeader "MirBaseLib" "MirBaseLib.h" "MIR_BASE_LIB_H_" "mir2base"

:: Task 2: Generate for CppLib
call :GenerateMasterHeader "CppLib" "CppLib.h" "CPP_LIB_H_" "cppx"

:: =====================================================================
:: 2. Scan for include directories and print /I paths
:: =====================================================================
set "SCRIPT_ROOT=%~dp0"

for /r "%SCRIPT_ROOT%" %%d in (.) do (
  set "dp=%%~fd"
  
  :: Rapid check for header files using internal 'if exist'
  if exist "%%d\*.h" (
    echo /I !dp!
  )
)

:: Terminate script execution before reaching functions
exit /b

:: =====================================================================
:: Function: GenerateMasterHeader
:: Purpose: Scans subdirectories and creates a master .h file
:: Arguments: %1: TargetDir, %2: OutFile, %3: Macro, %4: Namespace
:: =====================================================================
:GenerateMasterHeader
set "T_DIR=%~f1"
set "T_FILE=%~2"
set "T_MACRO=%~3"
set "T_NS=%~4"

:: Validate target directory existence
if not exist "%T_DIR%" (
  echo [ERROR] Directory not found: "%T_DIR%"
  goto :eof
)

(
  echo #ifndef %T_MACRO%
  echo #define %T_MACRO%
  echo.

  :: Recursively scan subdirectories, skipping the root directory itself
  for /f "delims=" %%D in ('dir /s /b /ad "%T_DIR%" 2^>nul') do (
    if /i not "%%D"=="%T_DIR%" (
      
      :: Check if the subdirectory contains header files
      if exist "%%D\*.h" (
        echo ///
        echo /// Directory: %%D
        echo ///
        
        :: Output include statements (0 indent for #include)
        for %%F in ("%%D\*.h") do (
          echo #include ^<%%~nxF^>
        )
        echo.
      )
    )
  )

  echo using namespace %T_NS%;
  echo.
  echo #endif // %T_MACRO%
) > "%T_FILE%"

goto :eof