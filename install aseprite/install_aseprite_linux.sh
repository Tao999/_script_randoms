rm -rf $HOME/deps
rm -rf $HOME/aseprite

sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel openssl-devel gn fedora-packager fedora-review
cd $HOME

mkdir $HOME/deps
cd $HOME/deps
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
git clone -b aseprite-m102 https://github.com/aseprite/skia.git
export PATH="${PWD}/depot_tools:${PATH}"
cd skia
python tools/git-sync-deps
gn gen out/Release-x64 --args='is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false cc="clang" cxx="clang++" extra_cflags_cc=["-stdlib=libc++"] extra_ldflags=["-stdlib=libc++"]'

ninja -C out/Release-x64 skia modules


cd $HOME
rm -rf aseprite
git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite
git pull
git submodule update --init --recursive
cd aseprite
mkdir build
cd build
export CC=clang
export CXX=clang++
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$HOME/deps/skia \
  -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-x64 \
  -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-x64/libskia.a \
  -G Ninja \
  ..
ninja aseprite

cd bin
tar -cvf ~/aseprite.tar ./

cd ~
rm -rf $HOME/deps
rm -rf $HOME/aseprite

echo ""
echo "==================================="
echo "FINI, aseprite dispo à ~/aseprite.tar"
