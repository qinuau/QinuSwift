#if Mac
    import Foundation
#elseif Linux
    import GLibc
#endif

public class System {
    public init() {

    }

    public func execCommandAndPrint(command: String) {
        let result = execCommand(command)
        print("\(result)")
    }
    
    public func execCommand(command: String) -> String {
        let fp = popen(command, "r")
        var result = ""

        var linebuf = [CChar](count:256, repeatedValue:0)

        while fgets(&linebuf, 256, fp) != nil {
            result += String.fromCString(&linebuf)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) + "\n"
        }

        pclose(fp)

        return result
    }
}
