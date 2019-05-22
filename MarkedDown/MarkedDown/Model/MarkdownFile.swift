//
//  MarkdownFile.swift
//  MarkedDown
//
//  Created by andrew madden on 22/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import Foundation
//import Down

class MarkdownFile {
    let fileName: String
    var contents: String?
//    var markdown: Down?
    
    init(fileName: String, contents: String? = nil) {
        self.fileName = fileName
        if let contents: String = contents { updateContents(text: contents) }
//        self.prepareMarkdown()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("EditorContentsUpdated"), object: nil, queue: nil) { (notification) in
            if let userInfo = notification.userInfo {
                if let newContents = userInfo["newContents"] as? String {
                    self.updateContents(text: newContents)
                }
            }
        }
    }
    
    // create a markdown object from file contents
//    private func prepareMarkdown() {
//        if let contents = self.contents {
//            markdown = Down(markdownString: contents)
//        }
//    }
    
    // builds a html string from the markdown object
//    var html: String? {
//        if let markdown = self.markdown {
//            return try? markdown.toHTML()
//        } else {
//            return nil
//        }
//    }
    
    private func updateContents(text: String) {
        self.contents = text
        NotificationCenter.default.post(name: NSNotification.Name("FileContentsUpdated"), object: nil, userInfo: ["contents" : self.contents ?? ""])
    }
}
