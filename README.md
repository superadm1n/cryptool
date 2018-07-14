# CrypTool.sh

A little script I threw together to help streamline the process of
encrypting drives, mounting them, and un-mounting them. This is mainly
useful on servers that do not have a GUI because typically the GUI
will have an automated way of detecting and mounting the drive but
on a computer without a GUI you wont have those tools, thus I felt
the need for a more streamline process.

## Getting Started

All you need to do to use this script is have a Linux device with the cryptsetup package installed

### Prerequisites

cryptsetup

```
sudo apt-get update
sudo apt-get install cryptsetup
```

### Installing

You can download the cryptool.sh file, make it executable and run it
directly or you can use git to copy the entire package.

```
git clone https://github.com/superadm1n/cryptool
cd cryptool
sudo chmod 700 cryptool.sh
```

### Usage

Encrypting a drive
```
sudo ./cryptool.sh --encrypt
```

Mounting a drive
```
sudo ./cryptool.sh --mount
```

Un-mounting a drive
```
sudo ./cryptool.sh --unmount
```

## Author

* **Kyle Kowalczyk** - *Initial work* - [SmallGuysIT](https://smallguysit.com)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
