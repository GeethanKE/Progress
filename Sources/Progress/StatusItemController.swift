import AppKit
import SwiftUI
import Combine

/// Builds and maintains the native NSMenu-based status item:
///
///   [pie icon]
///        │ click
///        ▼
///   64 %
///   8 hrs 44 min until end of day
///   ─────────────
///   Settings…            ⌘,
///   More                 ▸
///   ─────────────
///   Quit Progress        ⌘Q
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let store = ProgressStore.shared
    private var settingsWindowController: SettingsWindowController?

    private let percentItem = NSMenuItem()
    private let remainingItem = NSMenuItem()
    private var modeItems: [DisplayMode: NSMenuItem] = [:]
    private var styleItems: [ProgressStyle: NSMenuItem] = [:]

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        statusItem.button?.image = IconRenderer.image(fraction: 0, style: store.style)
        statusItem.menu = buildMenu()

        store.$startDate.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)
        store.$endDate.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)
        store.$displayMode.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)
        store.$style.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)

        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    // MARK: - Menu construction

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self

        percentItem.isEnabled = false
        remainingItem.isEnabled = false
        menu.addItem(percentItem)
        menu.addItem(remainingItem)
        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let moreItem = NSMenuItem(title: "More", action: nil, keyEquivalent: "")
        moreItem.submenu = buildMoreMenu()
        menu.addItem(moreItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Progress", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func buildMoreMenu() -> NSMenu {
        let moreMenu = NSMenu()

        let showHeader = NSMenuItem(title: "Show", action: nil, keyEquivalent: "")
        showHeader.isEnabled = false
        moreMenu.addItem(showHeader)
        for mode in DisplayMode.allCases {
            let item = NSMenuItem(title: mode.rawValue, action: #selector(selectMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode
            modeItems[mode] = item
            moreMenu.addItem(item)
        }

        moreMenu.addItem(.separator())

        let styleHeader = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
        styleHeader.isEnabled = false
        moreMenu.addItem(styleHeader)
        for style in ProgressStyle.allCases {
            let item = NSMenuItem(title: style.rawValue, action: #selector(selectStyle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = style
            styleItems[style] = item
            moreMenu.addItem(item)
        }

        return moreMenu
    }

    // MARK: - Actions

    @objc private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(store: store)
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func selectMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? DisplayMode else { return }
        store.displayMode = mode
    }

    @objc private func selectStyle(_ sender: NSMenuItem) {
        guard let style = sender.representedObject as? ProgressStyle else { return }
        store.style = style
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        refresh()
    }

    // MARK: - Refresh

    private func refresh() {
        let fraction = store.fraction
        statusItem.button?.image = IconRenderer.image(fraction: fraction, style: store.style)

        if store.isBeforeStart {
            percentItem.attributedTitle = styledTitle("Not started", size: 15)
            remainingItem.attributedTitle = styledTitle(
                "Starts at \(store.startDate.formatted(date: .omitted, time: .shortened))"
            )
        } else if store.isComplete {
            percentItem.attributedTitle = styledTitle("Done", size: 15)
            remainingItem.attributedTitle = styledTitle(
                "Ended at \(store.endDate.formatted(date: .omitted, time: .shortened))"
            )
        } else {
            percentItem.attributedTitle = styledTitle(Formatters.percentString(fraction), size: 15)
            remainingItem.attributedTitle = styledTitle(
                "\(Formatters.remainingLongString(store.remainingSeconds)) until \(store.label)"
            )
        }

        for (mode, item) in modeItems {
            item.state = mode == store.displayMode ? .on : .off
        }
        for (style, item) in styleItems {
            item.state = style == store.style ? .on : .off
        }
    }

    private func styledTitle(_ text: String, size: CGFloat = 13) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: NSFont.systemFont(ofSize: size),
            .foregroundColor: NSColor.secondaryLabelColor
        ])
    }
}
