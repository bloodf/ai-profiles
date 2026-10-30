# AI Profiles

A tiny macOS menu bar app for running several copies of the ChatGPT and Claude desktop apps side by side, each signed in to a different account.

## How it works

Both desktop apps are built on Chromium/Electron and accept `--user-data-dir`. AI Profiles launches a new instance of the app with its own data directory per profile, so cookies, logins and settings stay separate. Nothing is patched, copied or re-signed.

The ChatGPT app also embeds Codex, which stores its login in `CODEX_HOME` (default `~/.codex`). Each ChatGPT profile gets its own `CODEX_HOME` so logins don't leak between profiles.

Profiles live in:

```
~/Library/Application Support/ai-profiles/<App>-<profile>/
```

## Usage

Click the menu bar icon:

- **Profile name**: launch that profile. A checkmark means it's running.
- **New ChatGPT/Claude Profile…**: name a profile, then it launches so you can sign in.
- **Open Profiles Folder**: rename or delete profiles by renaming or deleting their folders.

Your normal copy of each app keeps using its default profile.

## Requirements

- macOS 14 or later
- ChatGPT and/or Claude installed in `/Applications`

## Build

Needs Xcode or the Command Line Tools.

```sh
./build.sh            # builds build/AI Profiles.app and build/AI-Profiles.zip
./build.sh --install  # also copies it to /Applications
```

The app is ad-hoc signed. If you download a prebuilt zip, macOS may block it on first launch; right-click the app and choose **Open**, or run:

```sh
xattr -dr com.apple.quarantine "/Applications/AI Profiles.app"
```

To start it at login, add it under System Settings › General › Login Items.

## Caveats

- Relies on how the apps behave today. An update to either app could break it.
- Each instance shows the same Dock icon; tell them apart by window.
- ChatGPT features that talk to system services (computer use, background agents) may conflict between instances.

## Disclaimer

Not affiliated with, endorsed by or sponsored by OpenAI or Anthropic. ChatGPT and Claude are trademarks of their respective owners. Check each service's terms before using multiple accounts.

## License

MIT
