import Foundation

struct DiskSpaceSnapshot {
    let freeBytes: Int64
    let totalBytes: Int64
    let updatedAt: Date

    private static let statusFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()

    private static let detailFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    var freePercentage: Double {
        guard totalBytes > 0 else { return 0 }
        return (Double(freeBytes) / Double(totalBytes)) * 100
    }

    var statusBarTitle: String {
        Self.statusFormatter.string(fromByteCount: freeBytes)
    }

    var detailLine: String {
        let gb = Double(freeBytes) / 1_000_000_000
        let mb = Double(freeBytes) / 1_000_000
        return String(
            format: "%@ | %.2f GB | %.2f MB",
            Self.detailFormatter.string(fromByteCount: freeBytes),
            gb,
            mb
        )
    }

    var percentageLine: String {
        String(format: "%.1f%%", freePercentage)
    }

    var totalSpaceLine: String {
        Self.detailFormatter.string(fromByteCount: totalBytes)
    }

    var updatedAtLine: String {
        Self.dateFormatter.string(from: updatedAt)
    }

    var tooltip: String {
        "Free disk space: \(detailLine)"
    }
}

final class DiskSpaceMonitor {
    var onUpdate: ((DiskSpaceSnapshot) -> Void)?

    private let rootURL = URL(fileURLWithPath: "/")
    private let callbackQueue = DispatchQueue(label: "com.diskwatcher.monitor", qos: .utility)
    private var timer: DispatchSourceTimer?
    private var lastSnapshot: DiskSpaceSnapshot?

    func start() {
        refresh()
        startTimer()
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func refresh() {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            guard let snapshot = self.makeSnapshot() else { return }
            guard self.shouldPublish(snapshot: snapshot) else { return }

            self.lastSnapshot = snapshot

            DispatchQueue.main.async {
                self.onUpdate?(snapshot)
            }
        }
    }

    private func startTimer() {
        guard timer == nil else { return }

        let timer = DispatchSource.makeTimerSource(queue: callbackQueue)
        timer.schedule(deadline: .now() + .seconds(1), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            self?.refresh()
        }
        self.timer = timer
        timer.resume()
    }

    private func makeSnapshot() -> DiskSpaceSnapshot? {
        do {
            let values = try rootURL.resourceValues(forKeys: [
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeAvailableCapacityKey,
                .volumeTotalCapacityKey
            ])

            let freeBytes = Int64(
                values.volumeAvailableCapacityForImportantUsage ??
                Int64(values.volumeAvailableCapacity ?? 0)
            )
            let totalBytes = Int64(values.volumeTotalCapacity ?? 0)

            guard totalBytes > 0 else { return nil }

            return DiskSpaceSnapshot(
                freeBytes: freeBytes,
                totalBytes: totalBytes,
                updatedAt: Date()
            )
        } catch {
            NSLog("Unable to read disk capacity: \(error.localizedDescription)")
            return nil
        }
    }

    private func shouldPublish(snapshot: DiskSpaceSnapshot) -> Bool {
        guard let lastSnapshot else { return true }

        return snapshot.freeBytes != lastSnapshot.freeBytes ||
            snapshot.totalBytes != lastSnapshot.totalBytes
    }
}
