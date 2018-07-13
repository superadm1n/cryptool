#!/bin/bash
#
#MIT License
#
#Copyright (c) 2018 Kyle Kowalczyk
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#



mapperName="drive"


mount_drive () {

    # function for mounting a drive

    echo "Enter the drive you wish to work on ex. /dev/sdb: "
    read drive

    echo "Enter the mount location: "
    read mountLocation

    sudo cryptsetup luksOpen ${drive} ${mapperName}
    sudo mount /dev/mapper/${mapperName} ${mountLocation}

}

unmount_drive () {

    # function for un-mounting a drive

    echo "Enter the mount location: "
    read mountLocation

    sudo umount ${mountLocation}
    sudo cryptsetup luksClose ${mapperName}

}

encrypt_drive () {

    # function for encrypting a drive with a password

    echo "Enter the drive you wish to encrypt ex. /dev/sdb: "
    read drive

    sudo cryptsetup -y -v luksFormat ${drive}

    sudo cryptsetup luksOpen ${drive} ${mapperName}

    echo "Do you want to write all zeros to the drive for true security?"
    echo "NOTE! This will take a long time especially if the drive is large!"
    read confirmation

    if [ "${confirmation}" == "y" ]
    then
        sudo dd if=/dev/zero of=/dev/mapper/${mapperName} status=progress
    fi

    echo "Creating EXT4 file system"
    sudo mkfs.ext4 /dev/mapper/${mapperName}

}


flag=0

if [ -n ${1} ]  # if an argument is detected
then
    flag=$((flag+1))
    for arg in ${1} ${2} ${3} ${4}
    do
        if [ "${arg}" == "--mount" ]
        then
            mount_drive
        elif [ "${arg}" == "--unmount" ]
        then
            unmount_drive
        elif [ "${arg}" == "--encrypt" ]
        then
            encrypt_drive
        else
            echo "${arg} is an invalid argument!"
        fi
    done


fi

