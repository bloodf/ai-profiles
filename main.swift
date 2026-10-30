import AppKit

// Menu bar launcher: each profile = own Chromium --user-data-dir (+ CODEX_HOME for ChatGPT).
let apps = ["ChatGPT", "Claude"]
let root = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Application Support/ai-profiles")

func profiles() -> [(app: String, name: String)] {
    let dirs = (try? FileManager.default.contentsOfDirectory(atPath: root.path)) ?? []
    return dirs.sorted().compactMap { dir in
        guard let app = apps.first(where: { dir.hasPrefix("\($0)-") }) else { return nil }
        return (app, String(dir.dropFirst(app.count + 1)))
    }
}

func isRunning(_ dir: URL) -> Bool {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
    p.arguments = ["-f", "--", "--user-data-dir=\(dir.path)"]
    try? p.run()
    p.waitUntilExit()
    return p.terminationStatus == 0
}

func launch(app: String, name: String) {
    let dir = root.appendingPathComponent("\(app)-\(name)")
    let codex = dir.appendingPathComponent("codex")
    try? FileManager.default.createDirectory(at: codex, withIntermediateDirectories: true)
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    // ChatGPT app embeds Codex, which keeps auth in CODEX_HOME (default ~/.codex)
    p.arguments = ["-n", "--env", "CODEX_HOME=\(codex.path)", "-a", "/Applications/\(app).app",
                   "--args", "--user-data-dir=\(dir.path)"]
    do { try p.run() } catch { alert("Launch failed: \(error.localizedDescription)") }
}

func alert(_ text: String) {
    let a = NSAlert()
    a.messageText = text
    a.runModal()
}

func ask(_ title: String) -> String? {
    NSApp.activate(ignoringOtherApps: true)
    let a = NSAlert()
    a.messageText = title
    a.addButton(withTitle: "Create & Launch")
    a.addButton(withTitle: "Cancel")
    let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 24))
    field.placeholderString = "e.g. work"
    a.accessoryView = field
    a.window.initialFirstResponder = field
    // Accessory apps aren't always granted activation; keep dialog above other windows anyway.
    a.window.level = .floating
    guard a.runModal() == .alertFirstButtonReturn else { return nil }
    let name = field.stringValue.trimmingCharacters(in: .whitespaces)
    guard !name.isEmpty, name.range(of: "^[A-Za-z0-9 _.-]+$", options: .regularExpression) != nil else {
        alert("Use letters, numbers, space, _ . - only.")
        return nil
    }
    return name
}

final class Delegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ n: Notification) {
        item.button?.image = NSImage(systemSymbolName: "person.2.circle", accessibilityDescription: "AI Profiles")
        item.menu = NSMenu()
        item.menu?.delegate = self
    }

    // Rebuild on every open so new/removed profile folders and running state show up.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        for app in apps {
            menu.addItem(.sectionHeader(title: app))
            for p in profiles() where p.app == app {
                let mi = NSMenuItem(title: p.name, action: #selector(launchItem(_:)), keyEquivalent: "")
                mi.target = self
                mi.representedObject = [p.app, p.name]
                if isRunning(root.appendingPathComponent("\(p.app)-\(p.name)")) { mi.state = .on }
                menu.addItem(mi)
            }
            let add = NSMenuItem(title: "New \(app) Profile…", action: #selector(newProfile(_:)), keyEquivalent: "")
            add.target = self
            add.representedObject = app
            menu.addItem(add)
            menu.addItem(.separator())
        }
        let folder = NSMenuItem(title: "Open Profiles Folder", action: #selector(openFolder), keyEquivalent: "")
        folder.target = self
        menu.addItem(folder)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    @objc func launchItem(_ sender: NSMenuItem) {
        guard let v = sender.representedObject as? [String] else { return }
        launch(app: v[0], name: v[1])
    }

    @objc func newProfile(_ sender: NSMenuItem) {
        guard let app = sender.representedObject as? String, let name = ask("New \(app) profile name") else { return }
        launch(app: app, name: name)
    }

    @objc func openFolder() {
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        NSWorkspace.shared.open(root)
    }
}

let application = NSApplication.shared
let delegate = Delegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
