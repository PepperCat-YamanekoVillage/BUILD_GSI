#!/bin/bash

rom_fp="$(date +%y%m%d)"
originFolder="$(dirname "$0")"
mkdir -p release/$rom_fp/
set -e

if [ "$#" -le 1 ];then
    echo "Usage: $0 <android-16.0> <LineageOS> <https://github.com/LineageOS/android.git> <lineage-16.0> [jobs]"
	exit 0
fi
localManifestBranch=$1
rom=$2
repoURL=$3
repoBranch=$4

if [ "$release" == true ];then
    [ -z "$version" ] && exit 1
    [ ! -f "$originFolder/release/config.ini" ] && exit 1
fi

if [ -z "$USER" ];then
	export USER="$(id -un)"
fi
export LC_ALL=C

if [[ -n "$5" ]];then
	jobs=$5
else
    if [[ $(uname -s) = "Darwin" ]];then
        jobs=$(sysctl -n hw.ncpu)
    elif [[ $(uname -s) = "Linux" ]];then
        jobs=$(nproc)
    fi
fi

repo init --no-repo-verify -u "$repoURL" -b "$repoBranch" --git-lfs

git clone https://github.com/TrebleDroid/treble_manifest.git .repo/local_manifests -b $localManifestBranch
rm -f .repo/local_manifests/replace.xml
rm -f .repo/local_manifests/remove.xml
sed -i '/remote.*name="github"/d' .repo/local_manifests/*.xml
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune

if [ -f "patches.zip" ]; then
    echo "Using local patches.zip..."
    rm -Rf patches
    unzip -q patches.zip
else
    echo "patches.zip not found. Please provide it in the current directory."
    exit 1
fi

bash apply-patches.sh ./

cd device/phh/treble
bash generate.sh $rom

. build/envsetup.sh

buildVariant() {
	lunch $1
	make WITHOUT_CHECK_API=true BUILD_NUMBER=$rom_fp installclean
	make WITHOUT_CHECK_API=true BUILD_NUMBER=$rom_fp -j$jobs systemimage
	make WITHOUT_CHECK_API=true BUILD_NUMBER=$rom_fp vndk-test-sepolicy
	xz -c $OUT/system.img -T$jobs > release/$rom_fp/system-${2}.img.xz
}

repo manifest -r > release/$rom_fp/manifest.xml
buildVariant treble_arm64_bgN-userdebug arm64-ab-gapps-nosu

if [ "$release" == true ];then
    (
        rm -Rf venv
        pip install virtualenv
        export PATH=$PATH:~/.local/bin/
        virtualenv -p /usr/bin/python3 venv
        source venv/bin/activate
        pip install -r $originFolder/release/requirements.txt

        python $originFolder/release/push.py "${rom^}" "$version" release/$rom_fp/
        rm -Rf venv
    )
fi