//
//  HighlightText.swift
//  Bordero
//
//  Created by Grande Variable on 06/06/2024.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let highlight: String
    let primaryColor: Color
    let secondaryColor: Color
    
    var body: some View {
        let parts = splitText(text: text, highlight: highlight)
        let text = parts.reduce(Text("")) { (result, part) in
            result + part
        }
        return text
    }
    
    private func splitText(text: String, highlight: String) -> [Text] {
        let lowercasedText = text.lowercased()
        let lowercasedHighlight = highlight.lowercased()
        
        guard !highlight.isEmpty, lowercasedText.contains(lowercasedHighlight) else {
            return [Text(text).foregroundColor(secondaryColor)]
        }
        
        var result = [Text]()
        var startIndex = text.startIndex
        
        while let range = lowercasedText.range(of: lowercasedHighlight, range: startIndex..<text.endIndex) {
            let prefix = String(text[startIndex..<range.lowerBound])
            let match = String(text[range])
            
            if !prefix.isEmpty {
                result.append(Text(prefix).foregroundColor(secondaryColor))
            }
            result.append(Text(match).foregroundColor(primaryColor))
            
            startIndex = range.upperBound
        }
        
        if startIndex < text.endIndex {
            let suffix = String(text[startIndex..<text.endIndex])
            result.append(Text(suffix).foregroundColor(secondaryColor))
        }
        
        return result
    }
}
