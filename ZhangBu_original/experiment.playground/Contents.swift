import Foundation

extension String {
    func match(_ pattern: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options()) else {
            return []
        }
        return regex.matches(in: self, range: NSMakeRange(0, self.count))
    }
}

let s = "こんにちは、今日の出費は¥2003円です、12、3、12312"
let r = s.match("\\d+")

r.forEach { print(s[$0.range]) }

