@call build_std.cmd
@if %errorlevel% neq 0 exit /b %errorlevel%

set RUSTC_SRC_DIR=%~dp0..\rustc-%RUSTC_VERSION%-src\src

@mkdir %OUTDIR%llvm-build

@pushd %OUTDIR%llvm-build
cmake -G Ninja -DLLVM_ENABLE_ASSERTIONS=OFF -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_DOCS=OFF -DLLVM_ENABLE_ZLIB=OFF -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_ENABLE_LIBEDIT=OFF -DWITH_POLLY=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo %RUSTC_SRC_DIR%\llvm
cmake --build
set LLVM_CONFIG=%~dp0%OUTDIR%llvm-build\bin\llvm-config.exe
@popd

@mkdir %OUTDIR%\rustc-build
set RUSTC_SRC_DIR=%~dp0..\rustc-%RUSTC_VERSION%-src\src
set CFG_RELEASE=%RUSTC_VERSION%
set CFG_VERSION=%RUSTC_VERSION%-stable-mrustc
x64\Release\minicargo.exe %RUSTC_SRC_DIR%\rustc -L %OUTDIR% --output-dir %OUTDIR%\rustc-build --vendor-dir %RUSTC_SRC_DIR%\vendor
@if %errorlevel% neq 0 exit /b %errorlevel%