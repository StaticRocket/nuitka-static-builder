# Based on https://github.com/xxh/xxh/blob/master/xxh-portable-musl-alpine.Dockerfile

FROM alpine

ENV PYTHON_VER 3.10.4
ENV PYTHON_LIB_VER 3.10
ENV MUSL_VER 1.2.3
ENV GCC_VER 11.2.0

RUN apk update && apk add --update build-base python3-dev py3-pip chrpath git vim mc wget make openssh-client patchelf zlib-static zlib-dev libffi-dev mpc1-dev gmp-dev mpfr-dev file isl-dev

RUN pip3 install Nuitka --no-cache


RUN mkdir /build /package
WORKDIR /build
#ENV CFLAGS   "-static -static-libgcc -fPIC"
#ENV CPPFLAGS "-static -static-libgcc -fPIC"
#ENV LDFLAGS  "-static -static-libgcc -fPIC"

#RUN wget https://musl.libc.org/releases/musl-$MUSL_VER.tar.gz && tar -xzf musl-$MUSL_VER.tar.gz
#WORKDIR musl-$MUSL_VER
#RUN ./configure --disable-shared
#RUN make LINKFORSHARED=" "
#RUN apk del musl-dev gcc
#RUN make install

#RUN wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.gz && tar -xzf gcc-$GCC_VER.tar.gz
#WORKDIR gcc-$GCC_VER
#RUN ./configure --prefix=/usr/local --disable-shared --disable-multilib --enable-languages=c
#RUN make all-gcc -j10
#RUN make all-target-libgcc -j10
#RUN apk del gcc g++
#RUN make install-gcc
#RUN make install-target-libgcc

#Hack to get arround stubborn libraries
#RUN cp /usr/lib/gcc/$(uname -m)-alpine-linux-musl/11.2.1/crtbeginS.o /usr/lib/gcc/$(uname -m)-alpine-linux-musl/11.2.1/crtbeginT.o

RUN wget https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz && tar -xzf Python-$PYTHON_VER.tgz
WORKDIR Python-$PYTHON_VER
ADD Setup Modules/
RUN ./configure CPPFLAGS="-static -fPIC" --disable-shared
RUN make LINKFORSHARED=" " -j10
RUN cp libpython$PYTHON_LIB_VER.a /usr/lib

WORKDIR /build
ENV LDFLAGS "-l:libpython$PYTHON_LIB_VER.a"

ENV HOME=/tmp
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
