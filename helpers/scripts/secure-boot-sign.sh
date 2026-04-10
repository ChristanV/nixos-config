#!/usr/bin/env sh
# Used to sign keys for secure boot when dual booting with windows - run as sudo

# 1. Create your own Secure Boot keys
sbctl create-keys

# 2. Put firmware in Setup Mode (clear existing keys)
sbctl enroll-keys --microsoft

# 3. Sign all
sbctl sign-all

# 4. Verify everything is signed
sbctl verify
