set WORKDIR=%~dp0rustc_bootstrap\
set RUSTC_VERSION_NEXT=1.30.0
set MAKEFLAGS=-j8
set PREFIX=%~dp0\output-1.29.0\prefix\

@REM curl -O https://static.rust-lang.org/dist/rustc-%RUSTC_VERSION_NEXT%-src.tar.gz

echo --- Working in directory %WORKDIR%
echo === Cleaning up
rmdir /s/q %WORKDIR%build

echo === Building rustc bootstrap mrustc stage0
mkdir %WORKDIR%mrustc
@REM tar -xf rustc-%RUSTC_VERSION_NEXT%-src.tar.gz -C %WORKDIR%mrustc/

echo [build]> %WORKDIR%mrustc\rustc-%RUSTC_VERSION_NEXT%-src\config.toml
echo cargo = "%PREFIX%bin/cargo.exe">> %WORKDIR%mrustc\rustc-%RUSTC_VERSION_NEXT%-src\config.toml
echo rustc = "%PREFIX%bin/rustc_binary.exe">> %WORKDIR%mrustc\rustc-%RUSTC_VERSION_NEXT%-src\config.toml
echo full-bootstrap = true>> %WORKDIR%mrustc\rustc-%RUSTC_VERSION_NEXT%-src\config.toml
echo vendor = true>> %WORKDIR%mrustc\rustc-%RUSTC_VERSION_NEXT%-src\config.toml

echo "--- Running x.py, see %WORKDIR%mrustc.log for progress"
cd %WORKDIR%mrustc\rustc-%RUSTC_VERSION_NEXT%-src && python ./x.py build --stage 3 > %WORKDIR%mrustc.log 2>&1
