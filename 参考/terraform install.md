# tfenvのインストールは以下のように進行します。

xxxxxxx ~ % tfenv list
zsh: command not found: tfenv
xxxxxxx ~ % brew -v
Homebrew 4.2.5
xxxxxxx ~ % brew install tfenv
Running `brew update --auto-update`...
==> Auto-updated Homebrew!
Updated 2 taps (homebrew/core and homebrew/cask).
==> New Formulae
actions-batch             erlang_ls                 ktfmt                     mmdbinspect               pkl                       sshpass
appwrite                  ffmpeg@6                  kubecolor                 moon                      podman-tui                sui
asmfmt                    flowpipe                  kubeshark                 morpheus                  policy_sentry             sysaidmin
autobrr                   g-ls                      kubetui                   msieve                    prjtrellis                tartufo
bluez                     gimmecert                 lexido                    mtm                       proto                     taskopen
bpftop                    git-split-diffs           liblc3                    mubeng                    protoc-gen-js             typstfmt
c-blosc2                  gitu                      liborigin                 navidrome                 rage                      uni-algo
c4core                    glasskube                 libscfg                   neosync                   ratchet                   uv
cargo-fuzz                gnmic                     libsql                    netaddr                   rawdog                    valkey
cekit                     go@1.21                   llvm@17                   nmail                     redict                    vfox
cmake-language-server     gptscript                 logdy                     noseyparker               robin-map                 vrc-get
cotp                      greenmask                 lsusb-laniksj             npm-check-updates         rtabmap                   vulkan-profiles
deadfinder                helm-docs                 magic-wormhole.rs         oj                        rustcat                   whisperkit-cli
dhall-toml                ignite                    manim                     overarch                  scala@3.3                 wstunnel
dissent                   ingress2gateway           mantra                    overtls                   seam                      xcode-build-server
dotslash                  inlyne                    mariadb@11.2              parsedmarc                sigi                      yo
edbrowse                  jnv                       mdformat                  pass-import               sqlboiler
edgevpn                   jtbl                      mdsh                      pawk                      srgn
envio                     kin                       mlx                       phodav                    ssh3
==> New Casks
acreom                         dnsmonitor                     hancom-docs                    lunarbar                       segger-ozone
amneziavpn                     dosbox-staging                 hhkb-studio                    motion                         spatial
apidog-europe                  easydevo                       ia-markdown-dictionary         mumuplayer                     starnet2
arctic                         elecom-mouse-util              ibkr                           notesollama                    stashpad
arm-performance-libraries      endless-sky-high-dpi           instantview                    nperf                          steinberg-activation-manager
arturia-software-center        ente-auth                      ireal-pro                      nrfutil                        timelapze
automattic-texts               fixkey                         irpf2024                       ollamac                        toneprint
boltai                         flox                           jamie                          outfox                         upscayl
cahier                         freeshow                       jan                            overlayed                      viable
capcut                         fujifilm-x-raw-studio          jordanbaird-ice                phoenix-code                   wifiman
cleanclip                      galaxybudsclient               juxtacode                      posture-pal                    xcodepilot
clearvpn                       gitbutler                      kit                            proton-mail                    yandex-music
darkmodebuddy                  godspeed                       lookaway                       qdirstat                       yes24-ebook
deelay                         halloy                         loungy                         requestly                      youlean-loudness-meter

You have 15 outdated formulae installed.

==> Downloading https://ghcr.io/v2/homebrew/core/tfenv/manifests/3.0.0
##################################################################################################################################################### 100.0%
==> Fetching dependencies for tfenv: pcre2 and grep
==> Downloading https://ghcr.io/v2/homebrew/core/pcre2/manifests/10.43
##################################################################################################################################################### 100.0%
==> Fetching pcre2
==> Downloading https://ghcr.io/v2/homebrew/core/pcre2/blobs/sha256:45c605d79f321f1afcab9192841fb6440f97693440ed6ccb8242edb3118303f3
##################################################################################################################################################### 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/grep/manifests/3.11
##################################################################################################################################################### 100.0%
==> Fetching grep
==> Downloading https://ghcr.io/v2/homebrew/core/grep/blobs/sha256:0c5a74551504781dec17477fd6a7ec21680c3b30be3f421d02e4f57593181ad2
##################################################################################################################################################### 100.0%
==> Fetching tfenv
==> Downloading https://ghcr.io/v2/homebrew/core/tfenv/blobs/sha256:4905c2390b0254348be44da1c4a05b3d8bf4d8704b94d16b739d64fd4709784b
##################################################################################################################################################### 100.0%
==> Installing dependencies for tfenv: pcre2 and grep
==> Installing tfenv dependency: pcre2
==> Downloading https://ghcr.io/v2/homebrew/core/pcre2/manifests/10.43
Already downloaded: /Users/xxxxxx/Library/Caches/Homebrew/downloads/4c12870adcfbf27eeeae4f44a420311ca3449f06a2fd8f6fcfe3d13db18087b4--pcre2-10.43.bottle_manifest.json
==> Pouring pcre2--10.43.arm64_sonoma.bottle.tar.gz
🍺  /opt/homebrew/Cellar/pcre2/10.43: 234 files, 6.3MB
==> Installing tfenv dependency: grep
==> Downloading https://ghcr.io/v2/homebrew/core/grep/manifests/3.11
Already downloaded: /Users/xxxxxx/Library/Caches/Homebrew/downloads/e0582271986bf91f2f8f4af389bbff336bb2e5cdcc91dd33fd2b4b3e42a37afe--grep-3.11.bottle_manifest.json
==> Pouring grep--3.11.arm64_sonoma.bottle.tar.gz
🍺  /opt/homebrew/Cellar/grep/3.11: 19 files, 1MB
==> Installing tfenv
==> Pouring tfenv--3.0.0.all.bottle.tar.gz
🍺  /opt/homebrew/Cellar/tfenv/3.0.0: 28 files, 98.8KB
==> Running `brew cleanup tfenv`...
Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
==> `brew cleanup` has not been run in the last 30 days, running now...
Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
Removing: /Users/xxxxxx/Library/Caches/Homebrew/autoconf_bottle_manifest--2.71... (14.1KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/c-ares--1.25.0... (296.2KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/ca-certificates_bottle_manifest--2023-12-12... (1.8KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/ca-certificates--2023-12-12... (127.7KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/icu4c--73.2... (29.3MB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/libcbor--0.10.2... (36.5KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/libfido2--1.14.0... (350.9KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/libnghttp2--1.58.0... (216.4KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/libuv--1.47.0... (353.2KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/m4_bottle_manifest--1.4.19... (10.5KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/m4--1.4.19... (253KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/mysql--8.2.0_1... (81.7MB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/node--21.6.0... (15.4MB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/openssl@3_bottle_manifest--3.2.0_1... (9.2KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/openssl@3--3.2.0_1... (9.4MB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/pkg-config_bottle_manifest--0.29.2_3... (11.0KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/pkg-config--0.29.2_3... (235.9KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/pyenv_bottle_manifest--2.3.35... (26KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/pyenv--2.3.35... (766KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/readline_bottle_manifest--8.2.7... (7.9KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/readline--8.2.7... (574.9KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/xz--5.4.5... (671.6KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/zstd--1.5.5... (721.7KB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/portable-ruby-3.1.4.arm64_big_sur.bottle.tar.gz... (12.4MB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/Cask/flutter--3.16.9.zip... (1GB)
Removing: /Users/xxxxxx/Library/Caches/Homebrew/api-source/Homebrew/homebrew-cask/7e1315d99766b274a76c8956262bfbe2d0b8e2ba/Cask/flutter.rb... (1KB)
Removing: /Users/xxxxxx/Library/Logs/Homebrew/mysql... (1.3KB)
Removing: /Users/xxxxxx/Library/Logs/Homebrew/node... (64B)
xxxxxxx ~ % tfenv list
No versions available. Please install one with: tfenv install
xxxxxxx ~ % tfenv install latest
Installing Terraform v1.8.1
Downloading release tarball from https://releases.hashicorp.com/terraform/1.8.1/terraform_1.8.1_darwin_arm64.zip
##################################################################################################################################################### 100.0%
Downloading SHA hash file from https://releases.hashicorp.com/terraform/1.8.1/terraform_1.8.1_SHA256SUMS
Not instructed to use Local PGP (/opt/homebrew/Cellar/tfenv/3.0.0/use-{gpgv,gnupg}) & No keybase install found, skipping OpenPGP signature verification
Archive:  /var/folders/l4/nbb6_3n51fdb1p9z743tgvzw0000gn/T/tfenv_download.XXXXXX.ZtRilWtCky/terraform_1.8.1_darwin_arm64.zip
  inflating: /opt/homebrew/Cellar/tfenv/3.0.0/versions/1.8.1/terraform  
Installation of terraform v1.8.1 successful. To make this your default version, run 'tfenv use 1.8.1'
xxxxxxx ~ % tfenv list
1.8.1
No default set. Set with 'tfenv use <version>'
xxxxxxx ~ % tfenv use 1.8.1
Switching default version to v1.8.1
Default version (when not overridden by .terraform-version or TFENV_TERRAFORM_VERSION) is now: 1.8.1
xxxxxxx ~ % terraform version
Terraform v1.8.1
on darwin_arm64
xxxxxxx ~ % aws configure 
AWS Access Key ID [****************test]: 
AWS Secret Access Key [****************test]: 
Default region name [ap-northeast-1]: 
Default output format [table]: 
