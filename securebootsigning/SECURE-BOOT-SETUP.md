# Secure Boot Setup Guide

This guide explains how to set up Secure Boot signing for iPXE binaries.

## Overview

Secure Boot requires that all UEFI binaries (`.efi` files) be cryptographically signed with a trusted certificate. This guide covers:

1. Generating signing keys (one-time setup)
2. Storing keys in GitHub Actions secrets
3. Automatic signing during CI/CD builds
4. Enrolling keys on target machines

## Step 1: Generate Signing Keys (One-Time Setup)

Run the key generation script on a Linux machine (or WSL):

```bash
# Navigate to the scripts directory
cd scripts

# Make the script executable
chmod +x generate-signing-keys.sh

# Run it
./generate-signing-keys.sh
```

This will create a timestamped directory (e.g., `secureboot-keys-20260112-160638/`) containing:
- PK (Platform Key), KEK (Key Exchange Key), and DB (Database) keys
- Base64-encoded secrets for GitHub Actions (in `github-secrets.txt`)
- A GUID for key identification
- All key files in PEM and DER formats

**⚠️ CRITICAL: Back up the key directory immediately!**

```bash
# Create a backup archive (run from scripts directory)
cd ..
tar czf secureboot-keys-backup-$(date +%Y%m%d).tar.gz scripts/secureboot-keys-*/

# Store this archive securely (encrypted storage, password manager, etc.)
```

## Step 2: Add Secrets to GitHub Actions

Go to your repository on GitHub:

1. Navigate to **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Add the following secrets (values are in the generated `github-secrets.txt` file):

| Secret Name | Description |
|-------------|-------------|
| `SECUREBOOT_DB_KEY` | Base64-encoded private key for signing |
| `SECUREBOOT_DB_CRT` | Base64-encoded certificate for signing |
| `SECUREBOOT_GUID` | GUID for key identification (optional, for reference) |

## Step 3: Automatic Signing

Once the secrets are configured in GitHub Actions, the build process automatically:

1. Builds all iPXE binaries using the Hydrunfile
2. Detects the presence of `SECUREBOOT_DB_KEY` and `SECUREBOOT_DB_CRT`
3. Signs all `.efi` files with your certificate
4. Creates `.unsigned` backup copies of all signed binaries
5. Publishes signed binaries in the GitHub release

**No manual signing step required!** The Hydrunfile handles everything.

### Local Testing

To test signing locally (requires the key files):

```bash
# Export the secrets from your key directory
export SECUREBOOT_DB_KEY=$(base64 -w 0 < securebootsigning/secureboot-keys-*/DB.key)
export SECUREBOOT_DB_CRT=$(base64 -w 0 < securebootsigning/secureboot-keys-*/DB.crt)

# Build with signing
hydrun -o debian:bookworm ./Hydrunfile c
```

## Step 4: Enroll Keys on Target Machines

To use your signed binaries, target machines need to trust your certificate. You have two options:

### Option A: Add Your Certificate Alongside Microsoft's (Recommended)

This allows both your iPXE binaries AND Windows to boot:

1. Enter UEFI firmware settings
2. Find Secure Boot settings
3. Add your `DB.cer` certificate to the signature database
4. Keep Microsoft's certificates in place

### Option B: Replace All Keys (Advanced)

This replaces Microsoft's keys entirely. **⚠️ WARNING: Windows will not boot after this!**

Follow the "Securing Multiple Computers" guide:
https://www.rodsbooks.com/efi-bootloaders/controlling-sb.html#multiple

This involves:
1. Creating a `LockDown.efi` binary with your keys
2. Putting Secure Boot into "Setup Mode"
3. Booting `LockDown.efi` to install your keys
4. All future boots must use your signed binaries

## What Gets Signed

All `.efi` binaries are automatically signed during the build process:

- ✅ `ipxe-i386.efi`
- ✅ `ipxe-x86_64.efi`
- ✅ `ipxe-arm32.efi`
- ✅ `ipxe-arm64.efi`
- ✅ `snp-i386.efi`
- ✅ `snp-x86_64.efi`
- ✅ `snponly-i386.efi`
- ✅ `snponly-x86_64.efi`
- ✅ `snponly-arm32.efi`
- ✅ `snponly-arm64.efi`
- ❌ `ipxe-i3downloaded binary is properly signed:

```bash
# Download the DB.crt from your key directory
sbverify --cert DB.crt ipxe-x86_64.efi
```

Expected output:
```
Signature verification OK
```

You can also check if a binary is signed using:

```bash
pesign -i ipxe-x86_64.efi -S
sbverify --cert DB.crt ipxe-x86_64.efi
```

Expected output:
```
Signature verification OK
```

## Key Expiration

The keys generated are valid for 100 years (36500 days). Before expiration:

1. Generate new keys
2. Sign binaries with new keys
3. Enroll new certificates on all target machines
4. Update GitHub Actions secrets

## What's Included in Each Release

### iPXE Binaries (Signed)
- `ipxe-*.efi` files for all architectures (i386, x86_64, arm32, arm64)
- `snp-*.efi` and `snponly-*.efi` variants
- `ipxe-i386.kpxe` (BIOS - unsigned)
- `.unsigned` backup files

### UEFI Management Tools (Signed)
- **KeyTool-signed.efi** - GUI for managing keys (easiest option)
- **LockDown-signed.efi** - Bulk key replacement (⚠️ breaks Windows!)
- **HashTool-signed.efi** - Manage hash allow/deny lists
- **ReadVars-signed.efi** - View enrolled keys

### Public Keys
Only the public halves, all prefixed with `publickey-`. The private keys (`*.key`) never leave the GitHub secrets: the
release job refuses to publish if any artifact is a `.key` file or contains a PEM private key.
- `publickey-DB.cer` - **the file to load in the BIOS**: append it to the `db` ("Authorized Signatures") database, next to
  Microsoft's keys (Option A). It's a DER X.509 certificate, the format most firmware key managers take (AMI Aptio calls it
  "Public Key Certificate → EFI_CERT_X509 (DER encoded)"). Rename it to `.der` if your firmware only lists `.der` files.
- `publickey-DB.esl` - the same key as an EFI signature list, for firmware that only accepts signature lists (some Dell
  models; AMI's "EFI_SIGNATURE_LIST") and for KeyTool
- `publickey-DB.crt` - PEM, for `sbverify --cert publickey-DB.crt ipxe-x86_64.efi`
- `publickey-PK.cer/.crt/.esl`, `publickey-KEK.cer/.crt/.esl` - the Platform Key and Key Exchange Key, only needed when
  replacing all keys (Option B)
- `publickey-KEK-with-microsoft.esl`, `publickey-DB-with-microsoft.esl` - our key plus the Microsoft keys from
  `securebootsigning/eslfiles`: the lists that `LockDown-signed.efi` installs

## Security Best Practices

1. **Never commit keys to version control** - Always use GitHub Actions secrets
2. **Back up keys securely** - Keep encrypted backups in multiple secure locations
3. **Restrict access** - Only authorized personnel should have access to the private key
4. **Monitor expiration** - Set reminders for key renewal
5. **Test thoroughly** - Always test signed binaries before deployment

## Troubleshooting

### "Signature verification failed"
- Keys might be corrupted during base64 encoding/decoding
- Ensure you're using the matching key and certificate pair

### "Security Violation" on boot
- Target machine doesn't trust your certificate
- Enroll your `DB.cer` certificate in the machine's firmware

### Windows won't boot after enrolling keys
- You replaced Microsoft's keys instead of adding alongside them
- Restore firmware defaults or re-enroll Microsoft's certificates

## References

- [Rod Smith's Guide to Secure Boot](https://www.rodsbooks.com/efi-bootloaders/controlling-sb.html)
- [FOG Project Secure Boot Thread](https://forums.fogproject.org/topic/16409/imaging-with-fog-and-secure-boot-poc)
- [sbsigntool Documentation](https://git.kernel.org/pub/scm/linux/kernel/git/jejb/sbsigntools.git/about/)
