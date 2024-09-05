# File: /Dockerfile
# Project: docker_tensorflow_spyder
# Created Date: Thursday September 5th 2024
# Author: Boris Bocquet
# Email : borisboc@free.fr
# -----
# Last Modified:
# Modified By:
# -----
# License: MIT License


#Strongly inspired by : https://github.com/spyder-ide/spyder/issues/17542#issue-1179763854

FROM tensorflow/tensorflow:latest-gpu-jupyter


RUN apt-get update


#<xcb error>

#To avoid this error : 
    #Could not load the Qt platform plugin "xcb" in "" even though it was found.
    #This application failed to start because no Qt platform plugin could be initialized.

#sources : 
    #https://github.com/spyder-ide/spyder/issues/17542#issuecomment-1077879080
    #https://github.com/spyder-ide/spyder/blob/master/external-deps/qtconsole/.github/workflows/linux-tests.yml

#x11-apps just to check that x forwarding works by running xcalc

RUN apt-get install -qq libxcb-xinerama0 xterm x11-apps -y --fix-missing
RUN apt-get install -y --no-install-recommends '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev libegl1

#</xcb error>

#<missing dependancies for PyQtWebEngine>

    #missing libsmime3, xdamage1, labasound

RUN apt-get install libnss3 libxdamage1 libasound2 -y --fix-missing

#</missing dependancies for PyQtWebEngine>

RUN pip install --upgrade pip

RUN pip install spyder 

WORKDIR /home



