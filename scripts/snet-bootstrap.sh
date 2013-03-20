#/bin/bash

PREFIX=$SNET_DIR
LPELA='lpel-1.x.tar.gz'
SNETRTSA='snet-1.x.tar.gz'
SNETCA='snetc-1.x.tar.gz'

itgz() {
  AR=${1/*\/}
  wget "$1"
  tar -xvzf $AR
  cd ${AR%.tar.gz}
  ./configure $2
  make 
  make install
  cd ..
}

ilpel() {
  git clone https://github.com/snetdev/lpel.git
  wget -O $LPELA $REPO/$LPELA
  mv lpel ${LPELA%.tar.gz}
  tar -xvzf ${LPELA}
  mv ${LPELA%.tar.gz} lpel
  cd lpel
  ./configure --with-pcl=${PREFIX} --with-mctx=pcl --prefix=${PREFIX}
  make
  make install
  cd ..
}

isnet() {
  local SDIR=snet-rts
  git clone https://github.com/rcefala/snet-rts.git $SDIR
  wget -O $SNETRTSA  $REPO/$SNETRTSA
  mv $SDIR ${SNETRTSA%.tar.gz}
  tar -xvzf ${SNETRTSA}
  mv ${SNETRTSA%.tar.gz} $SDIR
  cd $SDIR
  ./configure --with-lpel-includes=${PREFIX}/include \
  --with-lpel-libs=${PREFIX}/lib --prefix=${PREFIX} --enable-dist-mpi=yes \
  --enable-dist-zmq=yes CPPFLAGS=-I${PREFIX}/include
  make -j9 install
  cd ..
}

isnetc() {
  wget $REPO/$SNETCA
  tar -xvzf $SNETCA
  cd ${SNETCA%.tar.gz}
  ./configure --prefix=${PREFIX}
  make
  cp snetc $PREFIX/bin
}

dsnetc() {
  wget $REPO
  chmod +x snetc
  mv snetc $PREFIX/bin
}


stty -echo 
read -p "Password: " PASSW; echo 
stty echo

REPO="http://snet:${PASSW}@riccardo.cefala.net/files/snet/"


#itgz 'http://xmailserver.org/pcl-1.12.tar.gz' --prefix=${PREFIX}
#itgz 'http://download.zeromq.org/zeromq-3.2.2.tar.gz' --prefix=${PREFIX}
#itgz 'http://download.zeromq.org/czmq-1.3.2.tar.gz' "--prefix=${PREFIX} --with-libzmq=${PREFIX}"


#ilpel
isnet
isnetc
#dsnetc
