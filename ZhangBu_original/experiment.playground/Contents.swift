import UIKit
var args = ["bbb"]
var localizedStr = "aaaaa\(args)\\0aaaa"
args.enumerated().forEach {
    localizedStr = localizedStr.replacingOccurrences(of: "\\\($0)", with: $1) }
print(localizedStr)
