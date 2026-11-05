#!/bin/bash

set -e

echo "==================================="
echo "Secure Boot Key Generation Script"
echo "==================================="
echo ""
echo "This script generates Secure Boot signing keys and outputs them"
echo "in base64 format suitable for GitHub Actions secrets."
echo ""

# Create subfolder for all signing keys and secrets
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
KEY_DIR="secureboot-keys-${TIMESTAMP}"
mkdir -p "$KEY_DIR"
cd "$KEY_DIR"

echo "Generating keys in: $(pwd)"
echo ""

# Generate a GUID for owner identification
GUID=$(uuidgen --random)
echo "Generated GUID: $GUID"
echo ""

# 1. Generate Platform Key (PK)
echo "[1/6] Generating Platform Key (PK)..."
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=iPXE Platform Key/" -keyout PK.key -out PK.crt -days 36500 -nodes -sha256

# 2. Generate Key Exchange Key (KEK)
echo "[2/6] Generating Key Exchange Key (KEK)..."
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=iPXE Key Exchange Key/" -keyout KEK.key -out KEK.crt -days 36500 -nodes -sha256

# 3. Generate Signature Database key (DB)
echo "[3/6] Generating Signature Database key (DB)..."
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=iPXE Signature Database key/" -keyout DB.key -out DB.crt -days 36500 -nodes -sha256

# 4. Generate the DER format certificates
echo "[4/6] Converting to DER format..."
openssl x509 -outform DER -in PK.crt -out PK.cer
openssl x509 -outform DER -in KEK.crt -out KEK.cer
openssl x509 -outform DER -in DB.crt -out DB.cer

# 5. Generate EFI Signature Lists (.esl files)
echo "[5/6] Generating EFI Signature Lists (.esl)..."
cert-to-efi-sig-list -g "$GUID" PK.crt PK.esl
cert-to-efi-sig-list -g "$GUID" KEK.crt KEK.esl
cert-to-efi-sig-list -g "$GUID" DB.crt DB.esl

# Create empty noPK.esl for Setup Mode recovery
rm -f noPK.esl
touch noPK.esl

# 6. Generate authenticated variables (.auth files)
echo "[6/6] Generating authenticated variables (.auth)..."
sign-efi-sig-list -g "$GUID" -k PK.key -c PK.crt PK PK.esl PK.auth
sign-efi-sig-list -g "$GUID" -k PK.key -c PK.crt PK noPK.esl noPK.auth
sign-efi-sig-list -g "$GUID" -k PK.key -c PK.crt KEK KEK.esl KEK.auth
sign-efi-sig-list -g "$GUID" -k KEK.key -c KEK.crt db DB.esl DB.auth

echo ""
echo "✓ Keys generated successfully!"
echo ""

# Save secrets to file
SECRETS_FILE="github-secrets.txt"
echo "==================================="  > "$SECRETS_FILE"
echo "GitHub Actions Secrets"              >> "$SECRETS_FILE"
echo "===================================" >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "Add the following secrets to your GitHub repository:" >> "$SECRETS_FILE"
echo "(Settings → Secrets and variables → Actions → New repository secret)" >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_DB_KEY"     >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
base64 -w 0 DB.key                         >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_DB_CRT"     >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
base64 -w 0 DB.crt                         >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_KEK_KEY"    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
base64 -w 0 KEK.key                        >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_KEK_CRT"    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
base64 -w 0 KEK.crt                        >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_PK_KEY"     >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
base64 -w 0 PK.key                         >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_PK_CRT"     >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
base64 -w 0 PK.crt                         >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "Secret Name: SECUREBOOT_GUID"       >> "$SECRETS_FILE"
echo "-----------------------------------" >> "$SECRETS_FILE"
echo "$GUID"                               >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"
echo ""                                    >> "$SECRETS_FILE"

echo "==================================="
echo "GitHub Actions Secrets"
echo "==================================="
echo ""
echo "Add the following secrets to your GitHub repository:"
echo "(Settings → Secrets and variables → Actions → New repository secret)"
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_DB_KEY"
echo "-----------------------------------"
base64 -w 0 DB.key
echo ""
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_DB_CRT"
echo "-----------------------------------"
base64 -w 0 DB.crt
echo ""
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_KEK_KEY"
echo "-----------------------------------"
base64 -w 0 KEK.key
echo ""
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_KEK_CRT"
echo "-----------------------------------"
base64 -w 0 KEK.crt
echo ""
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_PK_KEY"
echo "-----------------------------------"
base64 -w 0 PK.key
echo ""
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_PK_CRT"
echo "-----------------------------------"
base64 -w 0 PK.crt
echo ""
echo ""

echo "-----------------------------------"
echo "Secret Name: SECUREBOOT_GUID"
echo "-----------------------------------"
echo "$GUID"
echo ""
echo ""

echo "✓ Secrets saved to: $SECRETS_FILE"
echo ""

echo "==================================="
echo "Key Files Location"
echo "==================================="
echo ""
echo "All key files have been saved to: $KEY_DIR"
echo ""
echo "Files generated:"
echo "All key files have been saved to: $(pwd)"
echo ""
echo "Files generated:"
echo "  - DB.key, DB.crt (for signing binaries)"
echo "  - KEK.key, KEK.crt (Key Exchange Key)"
echo "  - PK.key, PK.crt (Platform Key)"
echo "  - *.cer (DER format certificates for firmware)"
echo "  - *.esl (EFI Signature Lists for KeyTool)"
echo "  - *.auth (Authenticated variables for KeyTool/firmware)"
echo "  - noPK.auth (for returning to Setup Mode)"
echo "  - myGUID.txt (GUID used in all files: $GUID)"
echo "  - github-secrets.txt (secrets for GitHub Actions)"
echo ""
echo "⚠️  SECURITY WARNING:"
echo "  1. NEVER share .key files (private keys)"
echo "  2. Never commit these files to version control"
echo "  3. The DB.key/DB.crt will be used for signing binaries"
echo "  4. The .cer/.esl/.auth files are used for key enrollment"
echo ""
echo "==================================="
echo "Next Steps"
echo "==================================="
echo ""
echo "1. Add the secrets shown above to your GitHub repository"
echo "   (Settings → Secrets and variables → Actions → New repository secret)"
echo ""
echo "2. Store the entire directory securely (encrypted backup):"
echo "   cd .."
echo "   tar czf ${KEY_DIR}.tar.gz ${KEY_DIR}"
echo "   gpg -c ${KEY_DIR}.tar.gz  # Encrypt with password"
echo ""
echo "3. For client PC enrollment, copy these files to TFTP/USB:"
echo "   - DB.cer, KEK.cer, PK.cer (for firmware key managers)"
echo "   - DB.esl, KEK.esl, PK.esl (for KeyTool)"
echo "   - DB.auth, KEK.auth, PK.auth (for KeyTool in User Mode)"
echo "   - noPK.auth (to reset to Setup Mode if needed)"
echo ""
echo "4. Your CI/CD pipeline will use SECUREBOOT_DB_KEY/CRT for signing"
echo ""
echo "5. To add Microsoft keys to LockDown, see:"
echo "   ../tftp/CLIENT-PC-SETUP-SUMMARY.txt"
echo ""
