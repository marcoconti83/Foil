//
//
// Copyright (c) 2018 Marco Conti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
    

import Foundation


extension String {
    
    func multilineWithMaxCharactersPerLine(characters: Int) -> String {
        guard !self.isEmpty, self.count > characters else { return self }
        var lastLine = self
        var previousLines = ""
        while !lastLine.isEmpty {
            let split = lastLine.splitByLastSpace(maximumCharacters: characters)
            if !previousLines.isEmpty {
                previousLines += "\n" + split.preSpace
            } else {
                previousLines = split.preSpace
            }
            lastLine = split.postSpace
        }
        return previousLines
    }
    
    private func splitByLastSpace(maximumCharacters: Int) -> (preSpace: String, postSpace: String) {
        guard self.count > maximumCharacters else {
            return (self, "")
        }
        let maxCharacterIndex = self.index(self.startIndex, offsetBy: maximumCharacters-1)
        let nextCharacter = self.index(after: maxCharacterIndex)
        let maximumString = String(self[...maxCharacterIndex])
        guard !self[nextCharacter].isWhitespace else {
            return (
                preSpace: maximumString.trimWhitespaces,
                postSpace: String(self[nextCharacter...]).trimWhitespaces
            )
        }
        
        let indexOfSpace = maximumString.lastIndex { $0.isWhitespace }
        guard let space = indexOfSpace, indexOfSpace != maximumString.startIndex else {
            return (
                preSpace: maximumString.trimWhitespaces,
                postSpace: String(self[nextCharacter...]).trimWhitespaces
            )
        }
        return (
            preSpace: String(maximumString[...space]).trimWhitespaces,
            postSpace: String(self[self.index(after: space)...]).trimWhitespaces
        )
    }
    
    private var trimWhitespaces: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension Character {
    
    var isWhitespace: Bool {
        return CharacterSet.whitespacesAndNewlines.contains(self.unicodeScalars.first!)
    }
}
