@setlocal
@call build_std.cmd
@if %errorlevel% neq 0 exit /b %errorlevel%

set RUSTC_TARGET=%CFG_COMPILER_HOST_TRIPLE%
set RUST_SRC=%~dp0..\rustc-%RUSTC_VERSION%-src\src\
set PREFIX=%OUTDIR%prefix
set BINDIR=%PREFIX%\bin\
set LIBDIR=%PREFIX%\lib\rustlib\%RUSTC_TARGET%\lib\
set CARGO_HOME=%PREFIX%\cargo_home\
set PREFIX_S=%OUTDIR%prefix-s\
set LIBDIR_S=%PREFIX_S%lib\rustlib\%RUSTC_TARGET%\lib\
set BINDIR_S=%PREFIX_S%bin\

mkdir %BINDIR%
mkdir %LIBDIR%
mkdir %CARGO_HOME%
mkdir %BINDIR_S%
mkdir %LIBDIR_S%

@IF "%LLVM_CONFIG%"=="" echo LLVM_CONFIG not defined && exit /b 1

@REM Copy bootstrapping binaries
copy %OUTDIR%rustc-build\rustc_binary.exe %BINDIR_S%rustc.exe
copy %OUTDIR%rustc-build\rustc_binary.exe %BINDIR%rustc_m.exe
copy %OUTDIR%cargo-build\cargo.exe %BINDIR%\cargo.exe

@REM Hard-coded build of libstd
%BINDIR_S%rustc --crate-type rlib --crate-name core -L %LIBDIR_S% %RUST_SRC%libcore/lib.rs -o %LIBDIR_S%libcore.rlib
%BINDIR_S%rustc --crate-type rlib --crate-name compiler_builtins -L %LIBDIR_S% %RUST_SRC%libcompiler_builtins/src/lib.rs -o %LIBDIR_S%libcompiler_builtins.rlib --cfg feature=\"compiler-builtins\"
%BINDIR_S%rustc --crate-type rlib --crate-name libc -L %LIBDIR_S% %RUST_SRC%liblibc/src/lib.rs -o %LIBDIR_S%liblibc.rlib --cfg stdbuild
%BINDIR_S%rustc --crate-type rlib --crate-name unwind -L %LIBDIR_S% %RUST_SRC%libunwind/lib.rs -o %LIBDIR_S%libunwind.rlib
%BINDIR_S%rustc --crate-type rlib --crate-name alloc_system -L %LIBDIR_S% %RUST_SRC%liballoc_system/lib.rs -o %LIBDIR_S%liballoc_system.rlib
%BINDIR_S%rustc --crate-type rlib --crate-name alloc -L %LIBDIR_S% %RUST_SRC%liballoc/lib.rs -o %LIBDIR_S%liballoc.rlib
%BINDIR_S%rustc --crate-type rlib --crate-name panic_unwind -L %LIBDIR_S% %RUST_SRC%libpanic_unwind/lib.rs -o %LIBDIR_S%libpanic_unwind.rlib
%BINDIR_S%rustc --crate-type rlib --crate-name std -L %LIBDIR_S% %RUST_SRC%libstd/lib.rs -o %LIBDIR_S%libstd.rlib -l kernel32 -l shell32 -l msvcrt -l userenv -l ws2_32 -l advapi32
@if %errorlevel% neq 0 exit /b %errorlevel%

set CARGO_CONFIG=%CARGO_HOME%config
echo [source.crates-io] > %CARGO_CONFIG%
echo replace-with = "vendored-sources" >> %CARGO_CONFIG%
echo [source.vendored-sources] >> %CARGO_CONFIG%
echo directory = "%RUST_SRC:\=/%vendor" >> %CARGO_CONFIG%

@REM Real build of libstd
set CARGO_TARGET_DIR=%OUTDIR%build-std
set RUSTC=%BINDIR_S%rustc 
set RUSTC_BOOTSTRAP=1
set RUSTFLAGS=-Z force-unstable-if-unmarked
%BINDIR%cargo build --manifest-path %RUST_SRC%libstd\Cargo.toml -j 1 --release --features panic-unwind
@if %errorlevel% neq 0 exit /b %errorlevel%
copy /y %OUTDIR%build-std\release\deps\*.rlib %LIBDIR%
copy /y %OUTDIR%build-std\release\deps\*.dll* %LIBDIR%

mkdir %OUTDIR%build-test
set CARGO_TARGET_DIR=%OUTDIR%build-test
set RUSTC=%BINDIR%rustc_m 
%BINDIR%cargo build --manifest-path %RUST_SRC%libtest/Cargo.toml  -j 1 --release
@if %errorlevel% neq 0 exit /b %errorlevel%
copy /y %OUTDIR%build-test\release\deps\*.rlib %LIBDIR%
copy /y %OUTDIR%build-test\release\deps\*.dll* %LIBDIR%

set RUSTFLAGS=-Z force-unstable-if-unmarked
set RUSTC_BOOTSTRAP=1
set TMPDIR=%PREFIX%\tmp
set CARGO_TARGET_DIR=%OUTDIR%build-rustc
set RUSTC=%BINDIR%rustc_m
set RUSTC_ERROR_METADATA_DST=%PREFIX%
set CFG_RELEASE=
set CFG_RELEASE_CHANNEL=
set CFG_VERSION=%RUSTC_VERSION%-stable-mrustc
set CFG_PREFIX=mrustc
set CFG_LIBDIR_RELATIVE=lib
mkdir %TMPDIR%
mkdir %CARGO_TARGET_DIR%
%BINDIR%cargo build --manifest-path %RUST_SRC%rustc/Cargo.toml --release -j 1
@if %errorlevel% neq 0 exit /b %errorlevel%
copy /y %LIBDIR%*.dll %BINDIR%
copy /y %OUTDIR%build-rustc\release\deps\*.dll %BINDIR%
copy /y %OUTDIR%build-rustc\release\rustc_binary.exe %BINDIR%rustc_binary.exe
