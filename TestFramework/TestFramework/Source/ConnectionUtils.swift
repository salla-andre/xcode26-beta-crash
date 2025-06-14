import Foundation
import SystemConfiguration

public struct ConnectionType {
    /// Network is unreachable.
    public static let none = "none"
    /// Network is a cellular or mobile network.
    public static let cell = "cell"
    /// Network is a WiFi network.
    public static let wifi = "wifi"
}

public final class ConnectionUtils {
    public class func connectionType() -> String {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard
            let reachability = withUnsafePointer(
                to: &zeroAddress,
                {
                    $0.withMemoryRebound(
                        to: sockaddr.self,
                        capacity: MemoryLayout<sockaddr>.size
                    ) { ptr in
                        SCNetworkReachabilityCreateWithAddress(nil, ptr)
                    }
                }
            )
        else {
            return ConnectionType.none
        }

        var flags = SCNetworkReachabilityFlags()
        let isSuccess = SCNetworkReachabilityGetFlags(reachability, &flags)

        var connectionType: String = ConnectionType.none

        guard isSuccess && flags.contains(.reachable) else {
            return ConnectionType.none
        }

        if !flags.contains(.connectionRequired) {
            connectionType = ConnectionType.wifi
        }

        if flags.contains(.connectionOnDemand)
            || flags.contains(.connectionOnTraffic)
        {
            if !flags.contains(.interventionRequired) {
                connectionType = ConnectionType.wifi
            }
        }

        if flags.contains(.isWWAN) {
            connectionType = ConnectionType.cell
        }

        return connectionType
    }
}
