```
git clone https://github.com/PepperCat-YamanekoVillage/BUILD_GSI
cd BUILD_GSI
```

```
curl -L -o https://github.com/TrebleDroid/treble_experimentations/releases/download/ci-20250617/patches-for-developers.zip
```

```
git clone https://github.com/TrebleDroid/treble_experimentations
cp ./build.sh ./treble_experimentations/build-rom-y.sh
cp ./patches-for-developers.zip ./treble_experimentations/patches.zip
sudo chmod +x ./treble_experimentations/build-rom-y.sh
```

```
sudo docker build -t treble-rom .
cd treble_experimentations

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