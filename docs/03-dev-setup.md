# 03 Dev setup

How to get from a fresh clone to a working editor. The setup is taken from akai-timetrack, where it has been in use; the parts that differ here are marked.

Status (2026-11-15): the developer has opened the container once. The Flutter project exists since the same day; analyze, test and a debug build work in the container. What was checked is listed in section 8.

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

Run and build tasks and the F5 launch configuration are added in M0 together with the app.

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

## 8. What was checked, and what was not

Checked on 2026-11-15:

- The shell scripts pass a syntax check.
- The Dockerfile's instructions are identical to akai-timetrack's (compared with comments removed).
- `.devcontainer/.env` is matched by `.gitignore`.
- A plain `docker build` of `.devcontainer` succeeds (10 minutes, image about 16 GB). In the image, `flutter --version` reports 3.47.9 and `adb version` runs.
- The Docker volume `timetrack-emulator` exists on this PC.
- The developer opened the folder in the container from VS Code.
- In that container: `flutter analyze`, `flutter test` and `flutter build apk --debug` succeed on the new project.

Not checked yet:

- That the shared emulator volume works from this container.
- Phone connection from this container.

The test build left an image named `friendsapp-devcontainer-check`. It keeps the layers cached for the real container build. Remove it with `docker rmi friendsapp-devcontainer-check` once the dev container has been opened.
