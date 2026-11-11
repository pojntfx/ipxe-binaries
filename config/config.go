package config

func Filename(
	ip string,
	macAddress string,
	arch string,
	archID int,
) string {
	switch arch {
	case "x86 BIOS":
		return "ipxe-i386.kpxe"
	case "x86 UEFI":
		return "ipxe-i386.efi"
	case "x64 UEFI":
		return "ipxe-x86_64.efi"
	case "ARM 32-bit UEFI":
		return "ipxe-arm32.efi"
	case "ARM 64-bit UEFI":
		return "ipxe-arm64.efi"
	default:
		return "ipxe-i386.kpxe"
	}
}

// SnpFilename returns the SNP-only iPXE binary for the given architecture.
// SNP binaries delegate to the UEFI network driver and are useful for NICs
// like the Broadcom BCM57508 where the native iPXE driver may not be needed.
func SnpFilename(arch string) string {
	switch arch {
	case "x64 UEFI":
		return "snponly-x86_64.efi"
	case "ARM 64-bit UEFI":
		return "snponly-arm64.efi"
	default:
		return ""
	}
}

func Configure() map[string]string {
	return map[string]string{
		"useStdlib": "false",
	}
}
