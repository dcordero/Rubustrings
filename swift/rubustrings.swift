#!/usr/bin/env swift

import Foundation


extension String {
    var blue: String { return "\u{001B}[0;34m" + self + "\u{001B}[0;0m" }
    var green: String { return "\u{001B}[0;32m" + self + "\u{001B}[0;0m" }
    var red: String { return "\u{001B}[0;31m" + self + "\u{001B}[0;0m" }
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
        print("\n✘ Error reading file: \(fileName)".red)
    }
    return nil
}

func removeComments(fileData: String) -> String {
    let multilineCommentsRegex = try! NSRegularExpression(pattern: "\\/\\*.*?\\*\\/", options: .CaseInsensitive)
    return multilineCommentsRegex.stringByReplacingMatchesInString(fileData, options: [], range: NSRange(0..<fileData.utf16.count), withTemplate: "")
    
}

func removeEmptyLines(fileData: String) -> String {
    return fileData.componentsSeparatedByString("\n").filter { $0 != "" }.joinWithSeparator("\n")
}

func validateLocalizableStringFile(fileName: String) -> Bool {
    
    if let fileData = openAndReadFile(fileName) {
        
        let noComments = removeComments(fileData)
        let noEmptyLinex = removeEmptyLines(noComments)
        
        print(noEmptyLinex)
    }
    
    return false
}



var error = false
for fileName in Process.arguments where fileName != Process.arguments.first {
    print("\nProcessing file: \(fileName)".blue)
    
    if validateLocalizableStringFile(fileName) {
        print("\nResult: ✓ Strings file validated succesfully".green)
    }
    else {
        print("\nResult: ✘ Some errors detected".red)
        error = true
    }
}

exit(error ? 1 : 0)


