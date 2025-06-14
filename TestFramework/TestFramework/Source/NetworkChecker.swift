import Network
import Combine

public enum ReachabilityStatus {
    case connected
    case disconnected
    case unknown
}

public final class NetworkChecker {
    private let pathMonitor: NWPathMonitor

    public let connectionUpdates: CurrentValueSubject<ReachabilityStatus, any Error> = CurrentValueSubject(.unknown)

    @MainActor public static let shared: NetworkChecker = NetworkChecker()

    public var isConnected: Bool {
        connectionUpdates.value == .connected
    }

    public init() {
        connectionUpdates.send(
            ConnectionUtils.connectionType() != ConnectionType.none ? .connected : .disconnected
        )

        let monitor = NWPathMonitor()
        self.pathMonitor = monitor

        monitor.pathUpdateHandler = { [isConnected, connectionUpdates] path in
            let connected = path.status == .satisfied
            if isConnected != connected {
                connectionUpdates.send(path.status == .satisfied ? .connected : .disconnected)
            }
        }

        monitor.start(queue: DispatchQueue.global(qos: .utility))
    }
}
