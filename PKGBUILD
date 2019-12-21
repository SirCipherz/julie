# Maintainer Sir Cipherz

pkgbase=pkgbase
pkgname=julie
pkgver=8e49dad4
pkgrel=1
pkgdesc="A small script used to send easly encrypted messages"
url="https://framagit.org/SirCipherz/julie"
license=('MIT')
_source=(
    "https://framagit.org/SirCipherz/julie"
)
arch=('x86_64')

depends=(
   zenity vim nano gnupg curl
)

package() {
    cd $srcdir/..
    bash install.sh
}

#vim: syntax=sh
