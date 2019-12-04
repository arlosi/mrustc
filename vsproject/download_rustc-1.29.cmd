curl -O https://static.rust-lang.org/dist/rustc-1.29.0-src.tar.gz
tar xzf rustc-1.29.0-src.tar.gz -C ../
patch -p0 -d ..\rustc-1.29.0-src < ..\rustc-1.29.0-src.patch