N = Native apps

N-W = Native vulkan wined3d translation from Wine.

E-W = Externally added custom modifications to prefix, most cases being DXVK, DXVK-NVAPI and VKD3D-Proton. The prefix is also relative to root path of script instead of a global path. We consider this method of running apps inferior to N-W logistically speaking.


For the start.e-w.sh script you will need to place a vulkan.tar.xz file inside the files/ directory.

This contains dxvk, dxvk-nvapi and vkd3d-proton.

The archive is included in this repository and you can download it.