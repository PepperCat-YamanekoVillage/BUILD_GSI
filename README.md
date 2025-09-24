git clone https://github.com/PepperCat-YamanekoVillage/BUILD_GSI
cd BUILD_GSI

git clone https://github.com/TrebleDroid/treble_experimentations
cp ./build.sh ./treble_experimentations/build-rom-y.sh
cd treble_experimentations

docker build -t treble-rom .

docker run -it --rm \
    -v $(pwd):/workspace \
    treble-rom bash

cd /workspace
./build-rom-y.sh android-16.0 crDroid https://github.com/crdroidandroid/android.git 16.0
