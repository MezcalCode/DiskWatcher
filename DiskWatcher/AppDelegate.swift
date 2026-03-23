import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let monitor = DiskSpaceMonitor()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    private var freeSpaceItem: NSMenuItem?
    private var freePercentageItem: NSMenuItem?
    private var totalSpaceItem: NSMenuItem?
    private var lastUpdatedItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureApplication()
        configureMenu()
        configureMonitor()
        configureLaunchAtLogin()
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
    }

    private func configureApplication() {
        NSApp.setActivationPolicy(.accessory)
        if let button = statusItem.button {
            button.title = "Disk --"
        }
    }

    private func configureMenu() {
        let menu = NSMenu()

        let headerItem = NSMenuItem(title: "Disk Space Monitor", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)
        menu.addItem(.separator())

        let freeSpaceItem = NSMenuItem(title: "Free: --", action: nil, keyEquivalent: "")
        freeSpaceItem.isEnabled = false
        menu.addItem(freeSpaceItem)
        self.freeSpaceItem = freeSpaceItem

        let freePercentageItem = NSMenuItem(title: "Free Percent: --", action: nil, keyEquivalent: "")
        freePercentageItem.isEnabled = false
        menu.addItem(freePercentageItem)
        self.freePercentageItem = freePercentageItem

        let totalSpaceItem = NSMenuItem(title: "Total: --", action: nil, keyEquivalent: "")
        totalSpaceItem.isEnabled = false
        menu.addItem(totalSpaceItem)
        self.totalSpaceItem = totalSpaceItem

        let lastUpdatedItem = NSMenuItem(title: "Updated: --", action: nil, keyEquivalent: "")
        lastUpdatedItem.isEnabled = false
        menu.addItem(lastUpdatedItem)
        self.lastUpdatedItem = lastUpdatedItem

        menu.addItem(.separator())

        let refreshItem = NSMenuItem(
            title: "Refresh Now",
            action: #selector(refreshDiskSpace),
            keyEquivalent: "r"
        )
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit DiskWatcher",
            action: #selector(quitApplication),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func configureMonitor() {
        monitor.onUpdate = { [weak self] snapshot in
            self?.apply(snapshot: snapshot)
        }
        monitor.start()
    }

    private func configureLaunchAtLogin() {
        guard #available(macOS 13.0, *) else { return }

        do {
            try SMAppService.mainApp.register()
        } catch {
            // Registration can fail during local development if the app is not
            // installed in a way macOS accepts for login items. The app should
            // remain fully functional even when startup registration is denied.
            NSLog("Launch at login registration failed: \(error.localizedDescription)")
        }
    }

    private func apply(snapshot: DiskSpaceSnapshot) {
        if let button = statusItem.button {
            button.title = snapshot.statusBarTitle
            button.toolTip = snapshot.tooltip
        }

        freeSpaceItem?.title = "Free: \(snapshot.detailLine)"
        freePercentageItem?.title = "Free Percent: \(snapshot.percentageLine)"
        totalSpaceItem?.title = "Total: \(snapshot.totalSpaceLine)"
        lastUpdatedItem?.title = "Updated: \(snapshot.updatedAtLine)"
    }

    @objc
    private func refreshDiskSpace() {
        monitor.refresh()
    }

    @objc
    private func quitApplication() {
        NSApp.terminate(nil)
    }
}
