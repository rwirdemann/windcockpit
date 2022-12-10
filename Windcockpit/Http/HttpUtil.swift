func extractIdFromLocationHeader(url: String) -> Int16? {
    guard let lastIndexOfChar = url.lastIndex(of: "/") else { return nil }
    let startIndex = url.index(lastIndexOfChar, offsetBy:1)
    let substring = url[startIndex..<url.endIndex]
    return Int16(substring)
}
