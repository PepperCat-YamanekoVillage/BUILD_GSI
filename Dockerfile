FROM ubuntu:22.04

# 環境変数
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 必要パッケージをインストール
RUN apt-get update && apt-get install -y \
    git-core gnupg flex bison build-essential zip curl zlib1g-dev \
    gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip fontconfig ccache lzop pngcrush \
    schedtool python3 python-is-python3 openjdk-17-jdk \
    sudo wget rsync ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# repo ツールを導入
RUN mkdir -p /usr/local/bin && \
    curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

# ユーザー作成（root直でビルドしないため）
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER builder
WORKDIR /home/builder

RUN git config --global user.name "your username" \
    git config --global user.email yourmail@example.com

# キャッシュ領域
RUN mkdir -p /home/builder/.ccache
ENV USE_CCACHE=1
ENV CCACHE_MAXSIZE=50GB
