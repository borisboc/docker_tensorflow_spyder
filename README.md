# Docker container with tensorflow, jupyter and Spyder IDE 

How to build a Docker container with tensorflow, Spyder IDE, jupyter etc. With GPU support !

Based on docker image [tensorflow/tensorflow:latest-gpu-jupyter](https://hub.docker.com/r/tensorflow/tensorflow/tags?page=&page_size=&ordering=&name=latest-gpu-jupyter).

Strongly inspired by [caliari-italo and dalthviz on issue 17542](https://github.com/spyder-ide/spyder/issues/17542). And [spyder workflow for linux tests](https://github.com/spyder-ide/spyder/blob/master/external-deps/qtconsole/.github/workflows/linux-tests.yml).
Thank you guys !

## Requirements

This is for Linux only.
Tested on Ubuntu 22.04.

Follow [tensorflow docker requirements](https://www.tensorflow.org/install/docker#tensorflow_docker_requirements).

Since we want to use GPU, also follow the [NVIDIA container toolkit installation guide](https://docs.nvidia.com/datace.nter/cloud-native/container-toolkit/latest/install-guide.html).

To do so, you will have to follow the [CUDA installation guide for Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/).

To test the requirements, you should be able to run :

```
sudo docker run --runtime=nvidia --gpus all -it --rm tensorflow/tensorflow:latest-gpu-jupyter nvidia-smi
```

which should return something like : 

```
Sun Sep  1 08:44:19 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3060        Off |   00000000:07:00.0  On |                  N/A |
|  0%   50C    P8             19W /  170W |     512MiB /  12288MiB |      2%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

Where your GPU card is visible (`NVIDIA GeForce RTX 3060` in my case, please feel free to send me a newer one :wink:).
Remark : this may work currently but may fail after some hours / reboots. See troubleshooting section.


You should also be able to run : 

```
sudo docker run --runtime=nvidia --gpus all -it --rm tensorflow/tensorflow:latest-gpu-jupyter    python -c "from tensorflow.python.client import device_lib ; import tensorflow as tf ; print('devices found:\n',tf.config.list_physical_devices('GPU'))"
```

which should output something like :

```
devices found:
 [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
```

(with a lot of warnings in my case, such as `Unable to register cuDNN factor` etc.)

If so, you should have the requirements properly working.

NOTE : yes we need to sudo the docker commands. I have not configure rootless mode so far.


## Building the container

```
sudo docker build -t tensorflow_spyder .
```

## Running the container

First activate X forwarding between your local and the container

```
xhost +local:docker
```

Then start a container with all these arguments 

```
sudo docker run --runtime=nvidia --gpus all -it -e DISPLAY=$DISPLAY --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/home --rm tensorflow_spyder spyder
```

To start your container and Spyder IDE.

You can also start a bash (instead of spyder) and interact as you want within your container. But personnaly, I wasn't able to run `spyder &` (it stucks at "Loading Code Analysis...")

Since this container is based on docker image [tensorflow/tensorflow:latest-gpu-jupyter](https://hub.docker.com/r/tensorflow/tensorflow/tags?page=&page_size=&ordering=&name=latest-gpu-jupyter), you can also refere to [tensorflow documentation concerning docker](https://www.tensorflow.org/install/docker).

For instance, to start a container with jupyter running : 
```
sudo docker run --runtime=nvidia --gpus all -it -e DISPLAY=$DISPLAY --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/home -p 8888:8888 --rm tensorflow_spyder
```


## Troubleshooting

### Failed to initialize NVML: Unknown Error

Eventhough you maybe able to currently run nvidia-smi in you container, you may get error "Failed to initialize NVML: Unknown Error" after some hours / reboots.

I found the solution on [stackoverflow : Failed to initialize NVML: Unknown Error in Docker after Few hours](https://stackoverflow.com/a/78137688). I sudo edited `/etc/nvidia-container-runtime/config.toml`, to change `no-cgroups = false`