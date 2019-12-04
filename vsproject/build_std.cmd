@set RUSTC_VERSION=1.29.0
@set OUTDIR=output-%RUSTC_VERSION%
@set CFG_COMPILER_HOST_TRIPLE=x86_64-pc-windows-msvc
@mkdir %OUTDIR%
x64\Release\minicargo.exe ..\rustc-%RUSTC_VERSION%-src\src\libstd --output-dir %OUTDIR% --script-overrides ..\script-overrides\stable-%RUSTC_VERSION%-windows
@if %errorlevel% neq 0 exit /b %errorlevel%
x64\Release\minicargo.exe ..\rustc-%RUSTC_VERSION%-src\src\libpanic_unwind --output-dir %OUTDIR% --script-overrides ..\script-overrides\stable-%RUSTC_VERSION%-windows
@if %errorlevel% neq 0 exit /b %errorlevel%
x64\Release\minicargo.exe ..\rustc-%RUSTC_VERSION%-src\src\libtest --vendor-dir ..\rustc-%RUSTC_VERSION%-src\src\vendor --output-dir %OUTDIR% --script-overrides ..\script-overrides\stable-%RUSTC_VERSION%-windows
@if %errorlevel% neq 0 exit /b %errorlevel%
x64\Release\minicargo.exe ..\lib\libproc_macro --output-dir %OUTDIR%
@if %errorlevel% neq 0 exit /b %errorlevel%
