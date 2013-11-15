video4ray
=========

Bash script for batch convertig videos for mobile devices

Version for Ubuntu 10.04
------------------------

video4ray_ub10.04.sh

Dependences:

* ffprobe
* ffmpeg
* sox

Version for Ubuntu 12.04
------------------------

video4ray_ub12.04.sh

Dependences:

* avprobe
* avconv
* sox

Notice
------

ffmpeg or avconv must be built with libx264 and libfaac support

For example:


    sudo apt-get install build-essential fakeroot dpkg-dev
    sudo apt-get build-dep ffmpeg
    sudo apt-get install libx264-dev libfaac-dev
    apt-get source ffmpeg
    cd ffmpeg-0.5.1/
    DEB_BUILD_OPTIONS="--enable-libx264 --enable-libfaac" fakeroot debian/rules binary
