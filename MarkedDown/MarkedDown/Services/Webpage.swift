//
//  Webpage.swift
//  MarkedDown
//
//  Created by andrew madden on 26/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import Foundation

class Webpage {
    var style: String
    var script: String
    
    init() {
        style = ""
        script = ""
        // load css and js
        guard let stylesheetPath = Bundle.main.path(forResource: "down.min", ofType: "css") else { return }
        guard let highlightjsPath = Bundle.main.path(forResource: "highlight.min", ofType: "js") else { return }
        do {
            style = try String(contentsOfFile: stylesheetPath)
            script = try String(contentsOfFile: highlightjsPath)
        } catch {
            print("Could not load html styling correctly")
        }
    }
    
    // TODO highlight js is not included properly
    func boilerplate(_ html: String) -> String {
        return """
        <html>
        <head>
        <style>\(self.style)</style>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        </head>
        <body>
        <article class="markdown-body">
        \(html)
        </article>
        <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.8/highlight.min.js"></script>
        </body>
        </html>
        """
    }
}
