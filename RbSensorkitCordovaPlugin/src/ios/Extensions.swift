extension Array {
    func chunked(into size: Int) -> [[Element]] {
//        let t = stride(from: 0, to: count, by: size)
//        print("stride:", t)
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension String {
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss")-> Date?{
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
//        dateFormatter.locale = Locale(identifier: "fa-IR")
//        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
}

extension Date {
    func toString(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "fa-IR")
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
//        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }
}
