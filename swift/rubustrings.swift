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

var error = false
for fileName in Process.arguments where fileName != Process.arguments.first {
    print("\nProcessing file: \(fileName)".blue)
    
    if system("./rubustrings.rb \(fileName)") == 0 {
        print("\nResult: ✓ Strings file validated succesfully".green)
    }
    else {
        print("\nResult: ✘ Some errors detected".red)
        error = true
    }
}

exit(error ? 1 : 0)


