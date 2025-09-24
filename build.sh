#!/bin/bash
set -e

#----------------------------------------
# Build crDroid overlay GSI on phhusson/treble_device
#----------------------------------------

rom_fp="$(date +%y%m%d)"
originFolder="$(dirname "$0")"
mkdir -p release/$rom_fp/

if [ "$#" -le 1 ]; then
    echo "Usage: $0 <android-16.0> <crDroid> <https://github.com/crdroidandroid/android.git> <16.0> [jobs]"
    exit 0
fi

localManifestBranch=$1
rom=$2
repoURL=$3
repoBranch=$4

# 並列ジョブ数
if [[ -n "$5" ]]; then
    jobs=$5
else
    jobs=$(nproc)
fi

# 環境変数設定
export LC_ALL=C
[ -z "$USER" ] && export USER="$(id -un)"

#----------------------------------------
# Android source 初期化
#----------------------------------------
repo init --no-repo-verify -u "$repoURL" -b "$repoBranch" --git-lfs

# phhusson/treble_device master を local_manifest に追加
mkdir -p .repo/local_manifests
cat <<EOF > .repo/local_manifests/roomservice.xml
<manifest>
    <project name="phhusson/treble_device" path="device/phh/treble" remote="github" revision="master"/>
</manifest>
EOF

# repo sync
repo sync -c -j"$jobs" --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune

#----------------------------------------
# crDroid overlay 適用
#----------------------------------------
echo "Applying crDroid overlay..."
# vendor/crdroid/config と overlay を phhusson repo にコピー
cp -r vendor/crdroid/config device/phh/treble/vendor_crdroid_config
cp -r device/phh/treble/overlay ./device/phh/treble/overlay_crdroid || true

# generate.sh で PRODUCT_NAME を作成
(cd device/phh/treble; bash generate.sh vendor_crdroid_config/common_full_phone.mk)

#----------------------------------------
# パッチ適用
#----------------------------------------
if [ -f "patches.zip" ]; then
    echo "Using local patches.zip..."
    rm -Rf patches
    unzip -q patches.zip
    bash apply-patches.sh ./
else
    echo "patches.zip not found. Please provide it in the current directory."
    exit 1
fi

#----------------------------------------
# ビルド環境設定
#----------------------------------------
source build/envsetup.sh

# overlay 適用後に lunch
lunch treble_arm64_bgN-userdebug

# ビルド
m -j"$jobs" systemimage vendorimage

#----------------------------------------
echo "Build finished. Output: out/target/product/treble_arm64_bgN/"
echo "Release manifest stored in release/$rom_fp/"
