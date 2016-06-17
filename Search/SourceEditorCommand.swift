//
//  SourceEditorCommand.swift
//  Search
//
//  Created by skyline on 16/6/17.
//  Copyright © 2016年 skyline. All rights reserved.
//

import Cocoa
import XcodeKit

enum SearchEngine {
    case Google, StackOverflow, Dash
    init(identifier:String) {
        let searchType = identifier.components(separatedBy: ".").last!
        switch searchType {
        case "Google":
            self = .Google
        case "StackOverflow":
            self = .StackOverflow
        case "Dash":
            self = .Dash
        default:
            self = .Google
        }
    }

    private func urlPrefix() -> String {
        switch self {
        case .Google:
            return "https://www.google.com/search?q="
        case .StackOverflow:
            return "https://stackoverflow.com/search?q="
        case .Dash:
            return "dash://"
        }
    }
    func url(with keyword:String) -> String {
        return urlPrefix() + keyword.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed())!
    }
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (NSError?) -> Void ) -> Void {
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: "Search", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Selection"]))
            return
        }

        let line = invocation.buffer.lines[selection.start.line]
        let range = NSRange(location: selection.start.column, length: selection.end.column - selection.start.column + 1)
        let keyword = line.substring(with: range)
        let engine = SearchEngine(identifier: invocation.commandIdentifier)
        openInBrowser(urlString: engine.url(with: keyword))
        completionHandler(nil)
    }

    private func openInBrowser(urlString:String) {
        NSWorkspace.shared().open(URL(string: urlString)!);
    }
}
