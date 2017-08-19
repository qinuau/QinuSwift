#if Mac
    import Foundation
    let socketType = SOCK_STREAM
#elseif Linux
    import Glibc
    let socketType = Int32(SOCK_STREAM.rawValue)
#endif

public class Net {
    public init() {

    }

    func sockStream() -> Int32 {
        #if Mac
            let socketType = SOCK_STREAM
        #elseif Linux
            let socketType = Int32(SOCK_STREAM.rawValue)
        #endif

        return socketType
    }

    func getSocketBase(socketDomain: Int32, socketType: Int32, socketProtocol: Int32) -> Int32 {
        let s = socket(socketDomain, socketType, socketProtocol)

        return s
    }

    func getInetTcpStreamSocket() -> Int32 {
        let socketProtocol = Int32(IPPROTO_TCP)
        let s = getSocketBase(AF_INET, socketType: sockStream(), socketProtocol: socketProtocol)

        return s
    }

    func connectInetTcpStream(s: Int32, _ hostname: String) {
        var addr: UnsafeMutablePointer<addrinfo> = nil
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_socktype = sockStream()
        getaddrinfo(hostname, "http", &hints, &addr)
        connect(s, addr.memory.ai_addr, addr.memory.ai_addrlen)
    }

    func sendHTTP(s: Int32, _ hostname: String) {
        var headers = "GET / HTTP/1.1\n"
        //headers += "Accept: image/gif, image/jpeg, */*\n"
        //headers += "Accept-Language: ja\n"
        //headers += "Accept-Encoding: gzip, deflate\n"
        //headers += "User-Agent: Foo\n"
        //headers += "Connection: Keep-Alive\n"
        headers += "Connection: close\n"
        headers += "Host: " + hostname + "\n"
        headers += "\n"

        //print("headers are:\n\(headers)")

        send(s, headers, headers.lengthOfBytesUsingEncoding(NSUnicodeStringEncoding), 0)
    }

    func recvHTTPWithSocket(s: Int32) -> String {
        var response = ""
        let recvLength = 102400
        let buf = UnsafeMutablePointer<CChar>.alloc(recvLength)
        var result: Int

        while true {
            memset(buf, 0x0, recvLength);
            result = recv(s, buf, sizeof(UnsafeMutablePointer<CChar>), 0)

            if String.fromCString(buf) == nil {
                continue
            }
            else if result == 0 {
                break
            }
            else if result < 0 {
                break
            }
            else {
                response += String.fromCString(buf)!
            }
        }

        return response
    }

    public func sendAndRecvInetTcpStream(hostname: String) -> String {
        let s = getInetTcpStreamSocket()
        connectInetTcpStream(s, hostname)
        sendHTTP(s, hostname)
        let response = recvHTTPWithSocket(s)

        return response
    }
}
