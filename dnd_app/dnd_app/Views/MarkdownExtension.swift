import SwiftUI

// Расширение String для парсинга Markdown-подобного текста
extension String {
    func parseMarkdown() -> AttributedString {
        var attributedString = AttributedString(self)
        
        // Ищем ***жирный курсив*** (должен быть первым, чтобы не конфликтовать с другими)
        let boldItalicPattern = "\\*\\*\\*(.*?)\\*\\*\\*"
        let boldItalicRegex = try! NSRegularExpression(pattern: boldItalicPattern, options: [])
        let boldItalicMatches = boldItalicRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in boldItalicMatches.reversed() {
            if let range = Range(match.range(at: 1), in: self) {
                let boldItalicText = String(self[range])
                let fullMatch = String(self[Range(match.range, in: self)!])
                
                if let attributedRange = attributedString.range(of: fullMatch) {
                    attributedString[attributedRange].font = .boldSystemFont(ofSize: UIFont.systemFontSize)
                    attributedString[attributedRange].font = .italicSystemFont(ofSize: UIFont.systemFontSize)
                }
            }
        }
        
        // Ищем **жирный текст**
        let boldPattern = "\\*\\*(.*?)\\*\\*"
        let boldRegex = try! NSRegularExpression(pattern: boldPattern, options: [])
        let boldMatches = boldRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in boldMatches.reversed() {
            if let range = Range(match.range(at: 1), in: self) {
                let boldText = String(self[range])
                let fullMatch = String(self[Range(match.range, in: self)!])
                
                if let attributedRange = attributedString.range(of: fullMatch) {
                    attributedString[attributedRange].font = .boldSystemFont(ofSize: UIFont.systemFontSize)
                }
            }
        }
        
        // Ищем *курсив*
        let italicPattern = "\\*(.*?)\\*"
        let italicRegex = try! NSRegularExpression(pattern: italicPattern, options: [])
        let italicMatches = italicRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in italicMatches.reversed() {
            if let range = Range(match.range(at: 1), in: self) {
                let italicText = String(self[range])
                let fullMatch = String(self[Range(match.range, in: self)!])
                
                if let attributedRange = attributedString.range(of: fullMatch) {
                    attributedString[attributedRange].font = .italicSystemFont(ofSize: UIFont.systemFontSize)
                }
            }
        }
        
        // Ищем ~~зачеркнутый~~
        let strikethroughPattern = "~~(.*?)~~"
        let strikethroughRegex = try! NSRegularExpression(pattern: strikethroughPattern, options: [])
        let strikethroughMatches = strikethroughRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in strikethroughMatches.reversed() {
            if let range = Range(match.range(at: 1), in: self) {
                let strikethroughText = String(self[range])
                let fullMatch = String(self[Range(match.range, in: self)!])
                
                if let attributedRange = attributedString.range(of: fullMatch) {
                    attributedString[attributedRange].strikethroughStyle = .single
                }
            }
        }
        
        // Ищем ==выделенный==
        let highlightPattern = "==(.*?)=="
        let highlightRegex = try! NSRegularExpression(pattern: highlightPattern, options: [])
        let highlightMatches = highlightRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        for match in highlightMatches.reversed() {
            if let range = Range(match.range(at: 1), in: self) {
                let highlightText = String(self[range])
                let fullMatch = String(self[Range(match.range, in: self)!])
                
                if let attributedRange = attributedString.range(of: fullMatch) {
                    attributedString[attributedRange].backgroundColor = .yellow.opacity(0.3)
                }
            }
        }
        
        return attributedString
    }
}
