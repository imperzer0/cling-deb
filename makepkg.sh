#!/bin/bash

pkgname="cling"
pkgver="0.0-git-latest-master"
makedepends=('git' 'g++' 'cmake')

pkgdir="$(pwd)/$pkgname"
srcdir="$(pwd)/src"

init_dirs() {
  echo "-> init_dirs($pkgname) in $(pwd)"

#  rm -rfv "$srcdir" && echo "Removed old source directory" || exit 1;
  rm -rfv "$pkgdir" && echo "Removed old package directory" || exit 1;
  mkdir -pv "$srcdir";
  mkdir -pv "$pkgdir";

  cd "$srcdir" || exit 1;
}

install_deps() {
  echo "-> install_deps(${makedepends[*]})"

  sudo apt install -y ${makedepends[*]} || exit 10;
  sudo apt-mark auto ${makedepends[*]};
}

run_install_script() {
  echo "-> run_install_script($pkgdir) in $(pwd)"

  mkdir -pv "$pkgdir/usr/share/$pkgname";

  curl -O 'https://raw.githubusercontent.com/Axel-Naumann/cling-all-in-one/master/clone.sh'
  sed -i 's|$INSTDIR|'"$pkgdir/usr/share/$pkgname"'|g' clone.sh
  bash clone.sh || exit 3
}

create_control_file() {
  mkdir -p "$pkgdir/DEBIAN"
  cat <<EOF > "$pkgdir/DEBIAN/control"
Package: $pkgname
Version: $pkgver
Priority: optional
Architecture: $(dpkg --print-architecture)
Depends:
Maintainer: Your Name <youremail@example.com>
Description: CLING a C++ interpreter

EOF
}



dpkg_build() {
  cd ..
  echo "-> dpkg_build($pkgname) in $(pwd)"

  dpkg-deb -v --build "./$pkgname" || exit 8;
}


init_dirs;
install_deps;
run_install_script;
create_control_file;
dpkg_build;


if [ $# -ge 1 ] && [ "$1" == "-i" ]; then
  echo "[Finishing up] Installing package {./$pkgname.deb}..."
  sudo dpkg -i "./$pkgname.deb"
fi

