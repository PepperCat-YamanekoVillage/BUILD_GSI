```
git clone https://github.com/PepperCat-YamanekoVillage/BUILD_GSI
cd BUILD_GSI
```

```
mkdir crdroid
cp ./build.sh ./crdroid/build-rom-y.sh
sudo chmod +x ./crdroid/build-rom-y.sh
curl -L -o ./crdroid/patches.zip https://github.com/TrebleDroid/treble_experimentations/releases/latest/download/patches-for-developers.zip
```
ビルドしたいAndroidのバージョンに合わせてください

```
sudo docker build -t treble-rom .
cd crdroid

sudo docker run -it --rm \
    -v $(pwd):/workspace \
    treble-rom bash
```

```
cd /workspace
git config --global user.name "builder"
git config --global user.email "builder@example.com"
./build-rom-y.sh android-16.0 crDroid https://github.com/crdroidandroid/android.git 16.0
```