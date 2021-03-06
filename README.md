You can install GDS by through the release note below:
https://docs.nvidia.com/gpudirect-storage/release-notes/index.html
But it is a little complicated, the followings might be helpful for you.

# 0. Hardware
```
   (1) Optiplex 3050SFF  ... JPY 19,250
       Intel(R) Core(TM) i3-7100 CPU @ 3.90GHz
       DIMM slot1: DDR4 DIMM 4GB (Hynix)
       DIMM slot2: Empty
       HDD 500GB  ---> replace to SATA SSD(Windows10 pro)
       DVD DRIVE  ---> replace to SATA SSD(Ubuntu 20.04)
   (2) SATA SSD  ... JPY 2,500
       Transcend SSD 120GB
       P/N: TS120GSSD220S
   (3) Wifi 11n ... JPY 800
       P/N: WDC-150SU2MWH
   (4) DDR4 DIMM 4GB ... JPY 2,280
       Patriot Memory DDR4 2400MHz PC4-19200
       P/N: PSD44F24082
   (5) NVMe SSD ... JPY 3,980
       KLEVV SSD 256GB CRAS C710 M.2 Type2280 PCIe3x4 NVMe 3D TLC NAND Flash
       P/N: K256GM2SP0-C71
   (6) ETC
       -Sabrent 2.5in->3.5in ... JPY 599
       -Zheino 2nd 9.5mm Note PC drive mounter ... JPY 899
       -GLOTRENDS M.2 Heatsink ... JPY 650
   (7) NVIDIA Quadro P400 (GP107GL) ... JPY 5,948
   ----- Total JPY 36,906 -----
   
   (8) For Windows10pro
       -Crucial SSD P5 500GB M.2 NVMe (P/N: CT500P5SSD8JP) ... JPY 7,973
       -Xiwai low profile PCI-e3.0 x1 M.2 NGFF M-Key SSD NVMe AHCI PCI Express Adapter Card ... JPY 999
       -SanDisk 32GB USB3.1 Memory ... JPY 858
       -Transcend SSD 120GB (P/N: TS120GSSD220S) ... JPY 2,500
       -GLOTRENDS M.2 Heatsink ... JPY 650
   ----- Total JPY 49,886 -----
```
# 1. Install Ubuntu 
```
   Install Ubuntu 20.04 as "Minimal Install" and don't select "install third-party software for graphics and Wi-Fi hardware and additional media formats".
```
# 2. Check if the kernel version
```
   Check if the kernel versionis 5.4.0-42-generic with "uname -r". If it's true, Update all of softwares (200~400MB). 
```
# 3. Check iommu status
```
   $ dmesg | grep -i iommu
   See the release note above URL. You need reboot after making disable iommu.
```   
# 4. Install MOFED5.1
```
 Download MLNX_OFED_LINUX-5.1-2.5.8.0-ubuntu20.04-x86_64.tgz.
   $ sudo apt-get install python3-distutils
   $ cd MLNX_OFED_LINUX-5.1-2.5.8.0-ubuntu20.04-x86_64/
   $ sudo ./mlnxofedinstall --with-nfsrdma --with-nvmf --enable-gds --add-kernel-support
   $ sudo update-initramfs -u -k `uname -r`
   $ sudo reboot
```
# 5. Install nvidia driver and nvidia cuda tool kit.
```
   $ sudo apt update
   $ sudo apt upgrade
   $ ubuntu-drivers devices
     == /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
     modalias : pci:v000010DEd00001CB3sv000010DEsd000011BEbc03sc00i00
     vendor   : NVIDIA Corporation
     model    : GP107GL [Quadro P400]
     driver   : nvidia-driver-450-server - distro non-free
     driver   : nvidia-driver-418-server - distro non-free
     driver   : nvidia-driver-460 - distro non-free recommended
     driver   : nvidia-driver-450 - distro non-free
     driver   : nvidia-driver-390 - distro non-free
     driver   : xserver-xorg-video-nouveau - distro free builtin
   $ sudo apt install nvidia-cuda-toolkit nvidia-driver-460
   $ shutdown -r now
```
# 6. Check nvidia-smi
```
   You might see cuda-11.2 was already installed. But please note cuda is still 10.1 in the step.
```
# 7. Install CUDA-11.2
```
   $ wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
   $ sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
   $ wget https://developer.download.nvidia.com/compute/cuda/11.2.0/local_installers/cuda-repo-ubuntu2004-11-2-local_11.2.0-460.27.04-1_amd64.deb
   $ sudo dpkg -i cuda-repo-ubuntu2004-11-2-local_11.2.0-460.27.04-1_amd64.deb
   $ sudo apt-key add /var/cuda-repo-ubuntu2004-11-2-local/7fa2af80.pub
   $ sudo apt-get update
   $ sudo apt-get -y install cuda
```
# 8. Install GDS
```
   $ sudo dpkg -i gpudirect-storage-local-repo-ubuntu2004-cuda-11.2-0.9.1_0.9.1-1_amd64.deb 
   $ sudo apt-key add /var/gpudirect-storage-local-repo-*/7fa2af80.pub
   $ sudo apt-get update
   $ sudo apt install nvidia-gds
   $ sudo modprobe nvidia_fs
   $ dpkg -s nvidia-gds
   $ /usr/local/cuda/gds/tools/gdscheck -p
    GDS release version (beta): 0.9.1.5
    nvidia_fs version:  2.4 libcufile version: 2.3
    cuFile CONFIGURATION:
    NVMe           : Supported
    NVMeOF         : Unsupported
    SCSI           : Unsupported
    SCALEFLUX CSD  : Unsupported
    LUSTRE         : Unsupported
    NFS            : Unsupported
    WEKAFS         : Unsupported
    USERSPACE RDMA : Unsupported
    --MOFED peer direct  : enabled
    --rdma library       : Not Loaded (libcufile_rdma.so)
    --rdma devices       : Not configured
    --rdma_device_status : Up: 0 Down: 0
    properties.use_compat_mode : 0
    properties.use_poll_mode : 0
    properties.poll_mode_max_size_kb : 4
    properties.max_batch_io_timeout_msecs : 5
    properties.max_direct_io_size_kb : 16384
    properties.max_device_cache_size_kb : 131072
    properties.max_device_pinned_mem_size_kb : 33554432
    properties.posix_pool_slab_size_kb : 4096 1048576 16777216 
    properties.posix_pool_slab_count : 128 64 32 
    properties.rdma_peer_affinity_policy : RoundRobin
    fs.generic.posix_unaligned_writes : 0
    fs.lustre.posix_gds_min_kb: 0
    fs.weka.rdma_write_support: 0
    profile.nvtx : 0
    profile.cufile_stats : 0
    miscellaneous.api_check_aggressive : 0
    GPU INFO:
    GPU index 0 Quadro P400 bar:1 bar size (MiB):256 supports GDS
    IOMMU : disabled
    Platform verification succeeded
```

The following is K1200's result.
```
   $ /usr/local/cuda/gds/tools/gdscheck -p
    GDS release version (beta): 0.9.1.5
    nvidia_fs version:  2.4 libcufile version: 2.3
    cuFile CONFIGURATION:
    NVMe           : Supported
    NVMeOF         : Unsupported
    SCSI           : Unsupported
    SCALEFLUX CSD  : Unsupported
    LUSTRE         : Unsupported
    NFS            : Unsupported
    WEKAFS         : Unsupported
    USERSPACE RDMA : Unsupported
    --MOFED peer direct  : enabled
    --rdma library       : Not Loaded (libcufile_rdma.so)
    --rdma devices       : Not configured
    --rdma_device_status : Up: 0 Down: 0
    properties.use_compat_mode : 0
    properties.use_poll_mode : 0
    properties.poll_mode_max_size_kb : 4
    properties.max_batch_io_timeout_msecs : 5
    properties.max_direct_io_size_kb : 16384
    properties.max_device_cache_size_kb : 131072
    properties.max_device_pinned_mem_size_kb : 33554432
    properties.posix_pool_slab_size_kb : 4096 1048576 16777216 
    properties.posix_pool_slab_count : 128 64 32 
    properties.rdma_peer_affinity_policy : RoundRobin
    fs.generic.posix_unaligned_writes : 0
    fs.lustre.posix_gds_min_kb: 0
    fs.weka.rdma_write_support: 0
    profile.nvtx : 0
    profile.cufile_stats : 0
    miscellaneous.api_check_aggressive : 0
    GPU INFO:
    GPU 0 Quadro K1200 does not have supported architecture, has 5 requires >= 6
    Platform does not have any supported GPU!
    Platform verification failed
    platform is not supported by cufile
    cufile initialization failed
    Platform verification error :
    GPUDirect Storage not supported on current platform
```
# 9. Additional software
```
   $ sudo apt install net-tools 
   $ sudo apt install openssh-server
   $ sudo update-alternatives --config java
   There are 2 choices for the alternative java (providing /usr/bin/java).

     Selection    Path                                            Priority   Status
   ------------------------------------------------------------
     0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      auto mode
     1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      manual mode
   * 2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode
```

# 10. Build and Run
```
   $ nvcc -I /usr/local/cuda/include/  -I /usr/local/cuda/targets/x86_64-linux/lib/ strrev_gds.cu -o strrev_gds.co -L /usr/local/cuda/targets/x86_64-linux/lib/ -lcufile -L /usr/local/cuda/lib64/ -lcuda -L   -Bstatic -L /usr/local/cuda/lib64/ -lcudart_static -lrt -lpthread -ldl -lcrypto -lssl
   $ echo -n "Hello, GDS World!" > test.txt
   $ ./strrev_gds.co test.txt 
   sys_len : 17
   !dlroW SDG ,olleH
   See also test.txt
   $ cat test.txt 
   !dlroW SDG ,olleH
   $ ./strrev_gds.co test.txt 
   sys_len : 17
   Hello, GDS World!
   See also test.txt
   $ cat test.txt 
   Hello, GDS World!
```   
