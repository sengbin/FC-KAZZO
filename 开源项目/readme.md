# FC自制卡带  
本工程主要存放立创开源的FC卡带相关代码和Kazzo烧录脚本，以及制作好的cpld烧录文件  
  

****

## 准备工作
- 先有一盘卡带  
  开源工程地址: https://oshwhub.com/firseve/
- Kazzo烧录器  
  可以购买，也可以自行制作。目前我有2个版本  
  https://oshwhub.com/firseve/kazzo-smd  
  https://oshwhub.com/firseve/kazzo_smd  
  制作kazzo需要下载器  **（没基础的最好不要折腾了）**  
  一个人教1个小时，我什么都别做了    
  https://oshwhub.com/firseve/ch552-avr-isp  
    
- USB-Blaster 下载器  
  用来给 epm240 下载程序  
  可以淘宝购买，但是注意需要你自己用万用表找 vcc的3.3v电源口，他的vcc接口没有供电能力  
  NC的脚上测量可以找到 3.3v 当做 vcc使用  
  这个 USB-Blaster 仅供参考使用，我不负责教学!! 没空教  
  https://oshwhub.com/firseve/epm240-ax5205p-ch552  
  下载方式，看上面项目中的截图  
  网盘提供了 QuartusProgrammerSetup-13.0.0.156.exe 下载，用于下载 pof 到 epm240  
  https://pan.baidu.com/s/1Pz0iR-aDyq7d2q52lmJPTA?pwd=b25q  


  
## 1 ROM+RAM组合  

- 我的开源地址
  https://oshwhub.com/firseve/fc_rom-ram  
  文件夹功能：  
  - [kazzo](FC_ROM%2BRAM/kazzo)  kazzo烧录脚本  
  - [mapper](FC_ROM%2BRAM/mapper)  mapper源码  


## 2 ROM+ROM组合  

- 沐沐开源地址  
  https://oshwhub.com/hujie888/works  
  

## 3 FC_MIX卡带
  目录 FC_MIX
- 开源地址  
  https://oshwhub.com/firseve/fc_mapper_240_copy  



****  

# 关于 Kazzo 脚本  
### 放置在 Kazzo 目录下  [Kazzo](Kazzo)   
只能支持本项目中 mapper 对应的烧录脚本，有些卡带只能读取，无法正常使用 kazzo 进行烧录，因为切页地址和数据写入地址相同，写入数据的同时会触发切页导致数据写入到错误的地址中，导致无法正常运行，所以需要自己造特殊寄存器地址用来写入游戏文件。