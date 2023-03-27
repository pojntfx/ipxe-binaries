# iPXE Binaries

Weekly builds of [https://ipxe.org/](https://ipxe.org/), with an [embedded script that chainloads /config.ipxe](./downstream/init.ipxe).

## Overview

**Tired of re-compiling iPXE just to change the embedded script?** This repository, which provides builds of iPXE with an embedded script that chainloads `/config.ipxe` hosted on the same next-server configured in your DHCP settings, might be of help to you!

A release `.tar.gz` archive with the latest iPXE release is built weekly and uploaded to [GitHub releases](https://github.com/andrew-stclair/ipxe-binaries/releases).

Binaries are compiled with HTTPS support enabled and are being built for the following [iPXE build targets](https://ipxe.org/appnote/buildtargets):

- `bin-i386-pcbios/ipxe.kpxe`
- `bin-i386-efi/ipxe.efi`
- `bin-x86_64-efi/ipxe.efi`
- `bin-arm32-efi/snp.efi`
- `bin-arm64-efi/snp.efi`

Also included is a [bofied](https://github.com/andrew-stclair/bofied) configuration file ([config.go](./downstream/config.go)) and an example iPXE script ([config.ipxe](./downstream/config.ipxe)) which chainloads [netboot.xyz](https://netboot.xyz/).

## License

ipxe-binaries (c) 2021 Felicitas Pojtinger and contributors

SPDX-License-Identifier: GPL-2.0
