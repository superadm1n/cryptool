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

# Script needs to be run as root!
if [ $EUID -ne 0 ]
    then
        echo "This script must be run as root, try 'sudo ${0}' or login as root"
    exit 1
fi

mapperName="drive"

availableDrives=`sudo fdisk -l | grep "Disk" | grep -v "Disklabel\|identifier" | cut -d " " -f 2 | cut -d ":" -f1`

list_drives () {

    # Function that gathers the attached disks on the system and prints them out

    local availableDrives=`sudo fdisk -l | grep "Disk" | grep -v "Disklabel\|identifier" | cut -d " " -f 2 | cut -d ":" -f1`
    local counter=1

    for drive in ${availableDrives}
    do
        echo ${counter}. ${drive}
        counter=$((counter+1))
    done

}

check_if_mounted () {

    # Requires 2 arguments, first being the file system location,
    # the second being the drive

    if mount | grep ${1} > /dev/null
    then
        echo "Device '${2}' is Mounted at location '${1}'!"
    else
        echo "Device ${2} is NOT mounted"
    fi

}
mount_drive () {

    # function for mounting a drive

    list_drives

    echo "Enter the drive you wish to work on ex. 1 <Enter> "
    read drive
    selectedDrive=`list_drives | grep ${drive} | cut -d " " -f2`

    local mountLocation=""

    until [ -d "${mountLocation}" ]
    do
        echo "Enter the mount location: "
        read mountLocation
    done

    sudo cryptsetup luksOpen ${selectedDrive} ${mapperName}
    sudo mount /dev/mapper/${mapperName} ${mountLocation}

    check_if_mounted ${mountLocation} ${selectedDrive}

}

check_for_drive () {

    # function that will check to see if cryptsetup has a drive mapped under the
    # predefined mapperName variable and echo True or Falsed based on that result

    sudo cryptsetup -v status ${mapperName} &> /dev/null

    if [ $? != 0 ]
    then
        echo "False"
    else
        echo "True"
    fi

}

find_mount_location () {

    # finds the mount location of a drive that is currently under the cryptsetup
    # mapperName variable

    local mountLocation=`sudo cryptsetup -v status ${mapperName} | grep "device:" | cut -d : -f2 | xargs`

    echo ${mountLocation}

}


unmount_drive () {

    # function for un-mounting a drive
    local answer=""

    if [ `check_for_drive` == "True" ]
    then
        mountedDrive=`find_mount_location`
        echo "Found device ${mountedDrive} is an encrypted drive that is currently mounted, do you want to un mount that one or enter one manually?"
        echo "Y: Unmount ${mapperName}"
        echo "M: Enter device manually."
        read answer

        if [ `echo ${answer} | cut -c1 | tr [:upper:] [:lower:]` == "m" ]
        then
            echo "Enter the mount location: "
            read mountLocation
        elif  [ `echo ${answer} | cut -c1 | tr [:upper:] [:lower:]` == "y" ]
        then
            mountLocation=`sudo mount | grep /dev/mapper/${mapperName} | cut -d " " -f3`
        else
            echo "Invalid selection please try again!"
            exit 1
        fi
     else
        echo "Unable to detect an encrypted drive that is mounted!"
        exit 1

    fi



    sudo umount ${mountLocation}
    sudo cryptsetup luksClose ${mapperName}

}

encrypt_drive () {

    # function for encrypting a drive with a password

    list_drives

    echo "Enter the drive you wish to encrypt ex. 1 <enter> "
    read answer
    local drive=`list_drives | grep ${answer} | cut -d " " -f2`

    sudo cryptsetup -y -v luksFormat ${drive}

    echo "Now Decrypting the drive to finish the process and create file system."
    sudo cryptsetup luksOpen ${drive} ${mapperName}

    echo "Do you want to write all zeros to the drive for true security?"
    echo "NOTE! This will take a long time especially if the drive is large!"
    read confirmation

    # cleans up the answer from the user and checks to see if the first letter is a 'y'
    if [ `echo ${confirmation} | cut -c1 | tr [:upper:] [:lower:]` == "y" ]
    then
        sudo dd if=/dev/zero of=/dev/mapper/${mapperName} status=progress
    fi

    echo "Creating EXT4 file system"
    sudo mkfs.ext4 /dev/mapper/${mapperName}

    sudo cryptsetup luksClose ${mapperName}

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

