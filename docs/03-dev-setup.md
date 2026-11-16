# 03 Dev setup

How to get from a fresh clone to a working editor. The setup is taken from akai-timetrack, where it has been in use; the parts that differ here are marked.

Status (2026-11-15): the developer has opened the container once. The Flutter project exists since the same day; analyze, test and a debug build work in the container. What was checked is listed in section 9.

```
Windows                                   WSL 2 Ubuntu → dev container
───────                                   ────────────────────────────
VS Code window  ───────────────────────►  Flutter SDK, Android SDK, Dart and
                                          Flutter extensions, Claude Code
adb server  (start-adb-server.cmd) ◄────  adb client (wrapper picks the server)
  ├─ phone via USB                        Android emulator (window via WSLg,
  └─ phone via wireless debugging           KVM via WSL 2), shared with akai-timetrack
```

Why adb runs on Windows: Docker cannot pass USB devices into the container. The adb client in the container talks to an adb server on Windows, which sees every phone connected to the PC.

## 1. Once per PC

Already present on the developer's PC:

- **Docker Engine** inside the WSL 2 Ubuntu. Docker Desktop with the WSL 2 backend works too, without the emulator (section 6).
- **VS Code** on Windows with the extensions **WSL** (`ms-vscode-remote.remote-wsl`) and **Dev Containers** (`ms-vscode-remote.remote-containers`). Nothing else is installed by hand: the Dart, Flutter and Claude Code extensions are installed inside the container by themselves.
- **Android platform-tools** (`adb`) on Windows: `winget install Google.PlatformTools`.

## 2. Clone and open

1. In an Ubuntu terminal: `git clone https://github.com/Kraechtshammer/friendsapp.git ~/Projects/friendsapp && cd ~/Projects/friendsapp && code .`
2. VS Code offers **Reopen in Container** (or Ctrl+Shift+P → *Dev Containers: Reopen in Container*).
3. The first time, the image is built: Flutter, the Android SDK and a warm-up build. This takes a while and several GB. Later starts take seconds.
4. When it is done, the extensions are installed, Flutter is set to Android only, and the commit hook is active.

The Dockerfile's instructions are kept identical to akai-timetrack's, so that both projects can use the same cached image layers. Whether Docker really reuses them depends on its build cache; on 2026-11-15 a plain `docker build` did not reuse them and built everything again.

## 3. Claude Code login for this project (optional)

1. On the first container start, `.devcontainer/.env` is created from `.env.example`. This file is git-ignored and never committed.
2. Run `claude setup-token` and sign in with the account you want for this project.
3. Put the token in `.devcontainer/.env` as `CLAUDE_CODE_OAUTH_TOKEN=...`.
4. Open a new terminal. For the Claude Code extension, run *Developer: Reload Window*.

Check that the file is not tracked: `git check-ignore -v .devcontainer/.env` prints the `.gitignore` rule.

## 4. Connect the phone

**On Windows:** double-click `scripts\windows\start-adb-server.cmd` and leave the window open while you work. If Windows Firewall asks, allow access on private networks only. Close it on public Wi-Fi.

**Phone, one time:** Settings → About phone → tap *Build number* seven times → Developer options → turn on **USB debugging**, and **Wireless debugging** to work without a cable.

- **USB:** plug in, accept "Allow USB debugging?", then run the task *Device: List devices*.
- **Wireless** (same Wi-Fi): task *Device: Pair wireless debugging* once, then *Device: Connect wireless debugging* each time.

If the Windows server is not running, adb uses its own server in the container. Wireless debugging still works then, USB does not.

## 5. Tasks

Ctrl+Shift+P → *Tasks: Run Task*.

| Task | Does |
|---|---|
| *Flutter: Get packages*, *Analyze*, *Test* | Work once the app project exists (M0) |
| *Device: List devices* | Shows phones and emulators adb can see |
| *Device: Pair / Connect wireless debugging* | See section 4 |
| *Device: Show app logs* | `flutter logs` |
| *Emulator: …* | See section 6 |

| *Build: Release APK* (Ctrl+Shift+B), *Build: Debug APK* | Builds and copies the APK to `dist/kept-<version>-<mode>.apk` |
| *Device: Build and install release APK*, *Install latest release APK* | Installs on the connected phone or emulator, keeps app data |

F5 runs the app on the selected device with hot reload (*Kept (debug)*).

Without a release key (section 8), a release APK is signed with the debug key. That is fine for trying things out, but such an APK cannot update an app that was installed with the release key.

## 6. Emulator

The emulator runs inside the container. Its window appears on the Windows desktop through WSLg, and it uses WSL 2's KVM. It is needed for README screenshots; day-to-day testing of contacts, messengers and notifications happens on the real phone.

**Shared with akai-timetrack (different from there):** this container mounts the same Docker volume, `timetrack-emulator`, and uses the same virtual device, `TimeTrack_Pixel`. So there is one emulator for all of the developer's app projects.

- If akai-timetrack has already set the emulator up, *Emulator: Start* works here right away.
- Otherwise run *Emulator: Set up* once (about 3 GB).
- Only one project can run the emulator at a time. Stop it in the other project first.
- *Emulator: Factory reset* wipes it for both projects.

With Docker Desktop the emulator is not available: remove `--device=/dev/kvm` and the two `/mnt/wslg` entries from `runArgs` in `devcontainer.json`.

Logs: `~/.android-emu/emulator.log` in the container.

## 7. Git

- Commit subjects need a prefix: Feature, Bugfix, Improvement, Docs, Dev or Release. The hook in `.githooks/commit-msg` checks it; the container's setup step turns it on.
- Small commits, short messages (see [CLAUDE.md](../CLAUDE.md)).
- GitHub login from WSL: this clone uses the Windows Git Credential Manager (`git config credential.helper`, set per repository on 2026-11-15). Inside the container, VS Code forwards the login by itself.
- `docs/papers/` is git-ignored. The papers stay local.

## 8. CI and releases

Taken from akai-timetrack.

**CI** (`.github/workflows/ci.yml`): every push to main and every pull request runs `flutter analyze` and `flutter test` with the same Flutter version as the dev container.

**Release** (`.github/workflows/release.yml`): pushing a tag `v<version>` builds the signed APK and creates a GitHub release "Kept <version>" with `kept-<version>.apk` attached. The release text is made by `scripts/release-notes.sh` from the commit subjects since the last tag, sorted by their prefix. The workflow fails on purpose if the signing secrets are missing.

### One-time setup by the developer: signing key and secrets

Done by the developer on 2026-11-15 with a key of its own for Kept (not akai-timetrack's). Checked: a local release APK is signed with a non-debug key. The steps stay here for another PC or a lost setup.

The key decides who may update the installed app. If it is lost, updates are no longer possible without uninstalling. Keep a backup outside the repository. The password never goes into git, chat or docs.

1. In the dev container terminal, create the key (it asks for a password and a few name fields):
   ```
   keytool -genkeypair -v -keystore android/kept-release.jks -alias kept -keyalg RSA -keysize 4096 -validity 10000
   ```
2. Create `android/key.properties` with four lines:
   ```
   storeFile=kept-release.jks
   storePassword=<the password>
   keyPassword=<the password>
   keyAlias=kept
   ```
   Both files are git-ignored. From now on local release builds are signed with this key.
3. Make the copy for GitHub: `base64 -w0 android/kept-release.jks > android/kept-release.jks.base64`
4. On GitHub: the repository → Settings → Secrets and variables → Actions → *New repository secret*, three times:
   - `ANDROID_KEYSTORE_BASE64`: the whole content of `android/kept-release.jks.base64`
   - `ANDROID_KEYSTORE_PASSWORD`: the password
   - `ANDROID_KEY_ALIAS`: `kept`
5. Delete `android/kept-release.jks.base64`.

### Make a release

1. In `pubspec.yaml` set `version:` to the new name and a higher build number, for example `0.1.0+2`. The build number must increase, or Android refuses the update.
2. Commit with the subject `Release: 0.1.0` and push.
3. `git tag v0.1.0 && git push origin v0.1.0`. The tag must match the pubspec version.

It can also be started by hand in the repository's Actions tab.

Not set up here, unlike akai-timetrack: an update check inside the app.

## 9. What was checked, and what was not

Checked on 2026-11-15:

- The shell scripts pass a syntax check.
- The Dockerfile's instructions are identical to akai-timetrack's (compared with comments removed).
- `.devcontainer/.env` is matched by `.gitignore`.
- A plain `docker build` of `.devcontainer` succeeds (10 minutes, image about 16 GB). In the image, `flutter --version` reports 3.47.9 and `adb version` runs.
- The Docker volume `timetrack-emulator` exists on this PC.
- The developer opened the folder in the container from VS Code.
- In that container: `flutter analyze`, `flutter test` and `flutter build apk --debug` succeed on the new project.
- `scripts/build-apk.sh release` builds and copies an APK (signed with the debug key, as no release key exists yet). `scripts/release-notes.sh` prints notes from the history. Both workflow files parse as YAML.

Not checked yet:

- That the shared emulator volume works from this container.
- Phone connection from this container. (Installs go from WSL through the Windows adb instead, by cable or by wireless debugging; see HANDOFF §7.)
- (Settled on 2026-11-16: the CI and release workflows run on GitHub; releases 0.1.0 to 0.6.0 were built, signed with the release key and published by the release workflow.)

The test build left an image named `friendsapp-devcontainer-check`. It keeps the layers cached for the real container build. Remove it with `docker rmi friendsapp-devcontainer-check` once the dev container has been opened.
