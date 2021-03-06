#!/bin/bash

cuda() {
  read -n1 -r -p "Install CUDA. press ENTER to continue!" ENTER
  if [[ -f installer/${CUDA} ]]; then
    echo "[CUDA-TSFLOW] Installing CUDA.."
    sudo sh installer/${CUDA} --override --silent --toolkit
    echo "[CUDA-TSFLOW] CUDA Installation done."
    echo " "

    read -p "Do you have CUDA update patch? [y/N]: " UPDATE
    UPDATE="${UPDATE:=N}"

    if [[ UPDATE -eq N ]] || [[ UPDATE -eq n ]]; then
      cudnn
    elif [[ UPDATE -eq Y ]] || [[ UPDATE -eq y ]]; then
      echo 'Here the content of "installer" directory:'
      ls installer/
      echo " "

      read -p "How many CUDA update patch do you have? " NO_PATCH

      for i in $NO_PATCH; do
        read -p "Please specify CUDA update patch no. $i: " CUPDATE
        sudo sh installer/${CUPDATE} --override --silent --toolkit
      done

      cudnn
    else
      echo "[CUDA-TSFLOW] Input invalid."
      echo "[CUDA-TSFLOW] Installation aborted."
      exit
    fi
  else
    echo "[CUDA-TSFLOW] CUDA installer not found."
    echo "[CUDA-TSFLOW] Installation aborted"
    exit
  fi
}

cudnn() {
  read -n1 -r -p "Install CUDNN. press ENTER to continue!" ENTER
  if [[ -f installer/${CUDNN} ]]; then
    echo "[CUDA-TSFLOW] Installing CUDNN.."

    mkdir installer/cudnn
    tar -xzvf installer/${CUDNN} -C installer/cudnn --strip-components=1
    sudo cp installer/cudnn/include/cudnn.h /usr/local/cuda/include
    sudo cp installer/cudnn/lib64/libcudnn* /usr/local/cuda/lib64
    sudo chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*

    echo "[CUDA-TSFLOW] Cofiguring cuda in linux enviroment.."
    echo " " >> ~/.bashrc
    echo "# CUDA Enviroment" >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"' >> ~/.bashrc
    echo 'export CUDA_HOME="/usr/local/cuda"' >> ~/.bashrc
  else
    echo "[CUDA-TSFLOW] CUDNN installer not found."
    echo "[CUDA-TSFLOW] CUDNN installation failed"
    exit
  fi
}

nccl() {
  read -n1 -r -p "Install NCCL. press ENTER to continue!" ENTER
  if [[ -f installer/${NCCL} ]]; then
    echo "[CUDA-TSFLOW] Installing NCCL.."
    mkdir installer/nccl
    tar Jxvf installer/${NCCL} -C installer/nccl/ --strip-components=1
    sudo cp installer/nccl/lib/libnccl* /usr/local/cuda/lib64/
    sudo cp installer/nccl/include/nccl.h /usr/local/cuda/include/
  else
    echo "[CUDA-TSFLOW] NCCL installer not found."
    echo "[CUDA-TSFLOW] NCCL installation failed"
    exit
  fi
}


echo "==============================================================================================="
echo "Welcome to Cuda Installer"
echo "==============================================================================================="
echo "This process will be install the latest cuda and tensorflow."
echo 'It require "installer file" and put it in "installer directory". Here is the installer list: '
echo " + Latest CUDA installer [ex: cuda_10.0.130_410.48_linux.run]."
echo " + Latest CUDNN library [ex: cudnn-10.0-linux-x64-v7.3.1.20.tgz]."
echo " + Latest NCCL installer [ex: nccl_2.3.5-2+cuda10.0_x86_64.txz]."
echo " "
echo 'If you have the "cuda toolkit update patch" put in "installer" directory too!'
echo " "

echo 'Have you put it all in "installer" and "installer/update-toolkit-patch" directory?'
read -n1 -r -p "Press ENTER to continue or CTRL + C to cancel!" ENTER
echo " "

echo 'Here the content of "installer" directory:'
ls installer/
echo " "

read -p "Please specify CUDA installer file. [Defaut: cuda_10.0.130_410.48_linux.run]:" CUDA
CUDA="${CUDA:=cuda_10.0.130_410.48_linux.run}"
read -p "Please specify CDNN installer file. [Defaut: cudnn-10.0-linux-x64-v7.3.1.20.tgz]:" CUDNN
CUDNN="${CUDNN:=cudnn-10.0-linux-x64-v7.3.1.20.tgz}"
read -p "Please specify NCCL installer file. [Defaut: nccl_2.3.5-2+cuda10.0_x86_64.txz]:" NCCL
NCCL="${NCCL:=nccl_2.3.5-2+cuda10.0_x86_64.txz}"
echo " "

read -n1 -r -p "Check nvidia driver is installed correctly. press ENTER to continue!" ENTER
ubuntu-drivers devices
lsmod | grep nvidia

echo "[CUDA-TSFLOW] Checking CUDA in your computer.."
if [[ -L /usr/local/cuda ]]; then
  echo "[CUDA-TSFLOW] CUDA has installed in your system."

  if [[ -f /usr/local/cuda/include/cudnn.h ]]; then
    echo "[CUDA-TSFLOW] CUDNN has installed in your system."
  fi

  echo "[CUDA-TSFLOW] Clean previous CUDA Installation if you want to re-install!"
  echo "[CUDA-TSFLOW] CUDA installation canceled."
  echo " "
  echo "==============================================================================================="
  echo "CUDA Post Installation Notes"
  echo "==============================================================================================="
  echo "Run this command to delete exisisting CUDA version."
  echo "$ sudo rm /usr/local/cuda*"
  echo " "
  echo "==============================================================================================="
  echo " "

  exit
fi

cuda
nccl

sudo ldconfig

echo "[CUDA-TSFLOW] CUDA Installation done."
echo " "
echo "==============================================================================================="
echo "CUDA Post Installation Notes"
echo "==============================================================================================="
echo "Load bash profile or bashrc configuration: "
echo " $ source ~/.bashrc"
echo " $ sudo ldconfig"
echo " "
echo "Verify CUDA in linux enviroment: "
echo ' $ echo $CUDA_HOME'
echo "==============================================================================================="
echo " "
