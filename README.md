# iPXE Binaries

Weekly builds of [https://ipxe.org/](ipxe.org), with an [embedded script that chainloads /config.ipxe](./config/init.ipxe).

[![hydrun CI](https://github.com/pojntfx/ipxe-binaries/actions/workflows/hydrun.yaml/badge.svg)](https://github.com/pojntfx/ipxe-binaries/actions/workflows/hydrun.yaml)

## Overview

**Tired of re-compiling iPXE just to change the embedded script?** This repository, which provides builds of iPXE with an embedded script that chainloads `/config.ipxe` relative to the TFTP server that iPXE was booted from, might be of help to you!

Binaries are build with HTTPS support enabled for the following [iPXE build targets](https://ipxe.org/appnote/buildtargets):

- `bin-i386-pcbios/ipxe.kpxe`
- `bin-i386-efi/ipxe.efi`
- `bin-x86_64-efi/ipxe.efi`
- `bin-arm32-efi/snp.efi`
- `bin-arm64-efi/snp.efi`

Also included is a [bofied](https://github.com/pojntfx/bofied) configuration file ([config.go](./config/config.go)) and an example iPXE script ([config.ipxe](./config/config.ipxe)) which chainloads [netboot.xyz](https://netboot.xyz/).

## Installation

A release `.tar.gz` archive with the latest iPXE release is built weekly and uploaded to [GitHub releases](https://github.com/pojntfx/ipxe-binaries/releases). [bofied](https://github.com/pojntfx/bofied) automatically fetches this archive on its first startup by default.

## Acknowledgements

- [ipxe/ipxe](https://github.com/ipxe/ipxe) provides the sources that the binaries are built from.

## Contributing

To contribute, please use the [GitHub flow](https://guides.github.com/introduction/flow/) and follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

To build the `.tar.gz` archive with the latest iPXE release locally, run the following:

```shell
$ git clone https://github.com/pojntfx/ipxe-binaries.git
$ cd ipxe-binaries
$ hydrun -o debian:bookworm -i ./Hydrunfile c
```

## License

iPXE Binaries (c) 2024 Felicitas Pojtinger and contributors

SPDX-License-Identifier: GPL-2.0
