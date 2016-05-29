#!/usr/bin/env swift

import Foundation


extension String {
    var blue: String { return "\u{001B}[0;34m" + self + "\u{001B}[0;0m" }
    var green: String { return "\u{001B}[0;32m" + self + "\u{001B}[0;0m" }
    var red: String { return "\u{001B}[0;31m" + self + "\u{001B}[0;0m" }
}

extension String {
    var lines: [String] {
        return self.componentsSeparatedByString("\n")
    }
    
    func removeComments() -> String {
        let commentsRegex = try! NSRegularExpression(pattern: "\\/\\*.*?\\*\\/", options: .CaseInsensitive)
        return commentsRegex.stringByReplacingMatchesInString(self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: "")
    }
    
    func removeEmptyLines() -> String {
        return self.componentsSeparatedByString("\n").filter { $0 != "" }.joinWithSeparator("\n")
    }
}

guard Process.arguments.count > 1 else {
    print("No strings file provided")
    exit(0)
}

func openAndReadFile(fileName: String) -> String? {
    do {
        return try String(contentsOfFile: fileName, encoding: NSUTF16StringEncoding)
    }
    catch {
        print("✘ Error reading file: \(fileName)".red)
    }
    return nil
}

func validateFormat(line: String) -> Bool {
    let localizableStringsFormatRegex = try! NSRegularExpression(pattern: "\\\"(.*)?\\\"\\s=\\s\\\"(.*)?\";", options: .CaseInsensitive)
    
    if localizableStringsFormatRegex.numberOfMatchesInString(line, options: .ReportProgress, range: NSRange(0..<line.utf16.count)) == 0 {
        print("✘ Error, invalid format: \(line)".red)
        return false
    }
    
    return true
}

func validateTranslationLine(line: String) -> Bool {
    validateFormat(line)
    
    return false
}

func validateLocalizableStringsFile(fileName: String) -> Bool {
    
    guard let fileData = openAndReadFile(fileName) else {
        return false
    }
    
    let cleaned_strings = fileData.removeComments().removeEmptyLines()
    guard !cleaned_strings.isEmpty else {
        print("✘ Error, no translations found in file: \(fileName)".red)
        return false
    }
    
    for line in cleaned_strings.lines {
        validateTranslationLine(line)
        
        print ("---> \(line)")
    }
    
    return true
}



var error = false
for fileName in Process.arguments where fileName != Process.arguments.first {
    print("Processing file: \(fileName)".blue)
    
    if validateLocalizableStringsFile(fileName) {
        print("Result: ✓ Strings file validated succesfully".green)
    }
    else {
        print("Result: ✘ Some errors detected".red)
        error = true
    }
}

exit(error ? 1 : 0)


