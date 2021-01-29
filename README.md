# AOSP utils
A set of utility scripts to help build the AOSP.

## Pre-requisites
Start by installing repo and initialise your repository with the latest sources available for the device you want to build the AOSP for. A list of official tags can be found here: https://source.android.com/setup/start/build-numbers
```bash
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
repo init -u https://android.googlesource.com/platform/manifest -b android-7.1.1_r58
repo sync
```
Be patient, the first checkout should take a while. Upon successful checkout of the source tree, checkout this repo at the root of your AOSP directory. You should then be able to setup your environment and select the target to build:
```bash
source build/envsetup.sh
lunch aosp_flounder-user
```

## Vendor files
The AOSP being open source, it therefore doesn't contain any proprietary low level driver source code. However, their binaries are still required in order to get a working build on a real device.

### Nexus 9 vendor files
Starting with the Nexus 9, Google has shifted towards the use of a dedicated vendor partition to store all those proprietary binary blobs. In theory that should prevent the need to have to include them into AOSP builds and the partition should just be flashed as is along with the other ones. In practice though this new approach introduces 2 major problems:
* The vendor partition provided by Google contains a property file which won't match the property of your build causing an error dialog to be displayed on system boot
* Starting from Android Marshmallow the dm-verity check made on the vendor partition will fail

As such, the following steps will extract the vendor files directly from the Nexus 9 Google factory images in order to get them integrated into an AOSP build.
 Start by building the tool that can unpack android image files:
```bash
make simg2img_host
```
Once that's done you should have the simg2img command available in your path. Running the following will download the factory image from a url and extract the vendor partition from it. Refer to the official download page: https://developers.google.com/android/drivers to know which url you will need to use based on the revision you have initialised repo with.
``` bash
python vendor/aevi/generate-nexus9-vendor.py ../ https://dl.google.com/dl/android/aosp/volantis-n9f27m-factory-a0d47736.zip --with-google-apps
```
This will extract and generate required files under the _vendor_ directory. To track new and modified files in your source tree you can use the following command:
```
repo status -o
```

## Building
Run the following command in order to build the base package which can then be used to generate factory images or OTA packages
```bash
m target-files-package
```

This should produce _aosp_flounder-target_files-xxxxxxx.zip_ which is not something you can use to directly flash your device but can rather be passed to a whole lot of AOSP build scripts in order to generate various different flash-able packages, for more details, see _build/tools/releasetools_. If you want to test what you have built works correctly though, you can easily do so by running the following command:
```bash
fastboot flashall -w
```

## Packaging
This repo contains two handy makefile targets in order to repectively build a flashable factory image, similar to the one you can download from the Google website:
```bash
m aosp_factory_distribution
```
and an OTA package which can be used to update a device running a lower OS version of the one you are building:
```bash
m aosp_ota_distribution
```

## Signing
Refer to https://source.android.com/devices/tech/ota/sign_builds in order to generate keys to sign your build if you don't already have them.   Signing keys can be placed in a folder called _security_ at the root of this repository, you'll then be able to use one of the signing targets:
```bash
m signed_factory_distribution
```
or:
```bash
m signed_ota_distribution
```

## Troubleshooting
* The AOSP build scripts expect to be run with python2, if python3 is the default one installed on your machine just create a python symlink pointing to python2 and add it at the beginning of your PATH, same goes for java
* Depending on your system you may have to apply some patches in order to compile the AOSP as you may run into build tool version compatibility issues. _generate-aevi-product.py_ will automatically try to apply patches based and the tag name you have checked out, see the _patch_ folder for more details. Also, export the following environment variable if you are experiencing locale related errors:
```
export LC_ALL=C
```
* When building marshmallow you may have to increase the Jack server memory heap:
```
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4096m"
```

## License
This software is licensed under the [MIT license](LICENSE)

Copyright &#169; 2020 All rights reserved. XdevL

