#!/usr/bin/env python2.7


from PIL import Image
from os import listdir, makedirs
from os.path import isfile, join, exists
from shutil import move

srcpath="/home/username/Desktop/wps"
dstpath="/home/username/Desktop/bigwps"

if not exists(dstpath):
    makedirs(dstpath)

for i in listdir(srcpath):
    if isfile(join(srcpath,i)):
        fullsrc = join(srcpath,i)
        try:
            im=Image.open(fullsrc)
            if im.size[0] < 1920:
                continue
            if im.size[1] < 1080:
                continue
            move(fullsrc, join(dstpath,i))
        except:
            continue

