//
//  FileGenerator.swift
//  MarkedDown
//
//  Created by andrew madden on 10/6/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import Foundation
import Down

enum PageSize {
    case A4
    
    var width: Double {
        switch self {
        case .A4:
            return 595.2
        }
    }
    
    var height: Double {
        switch self {
        case .A4:
            return 841.8
        }
    }
}

class FileGenerator {
    
    // creates a pdf file from string and returns filepath
    static func generatePDFfromMarkdownString(fileKey: String, contents: String, pageSize: PageSize = .A4) -> URL? {
        let fm = FileManager()
        
        // create attribute string representing html
        let down = Down(markdownString: contents)
        guard let attributedHTML = try? down.toAttributedString() else { return nil }
        
        // create renderer
        let pageRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        // create data for pdf file
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            attributedHTML.draw(in: pageRect.insetBy(dx: 50, dy: 50))
        }
        
        // save pdf file to temp directory
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFilePath = tempDir.appendingPathComponent(fileKey).appendingPathExtension("pdf")
        fm.createFile(atPath: tempFilePath.relativePath, contents: data, attributes: nil)
        
        return tempFilePath
    }
    
    static func generatePDFfromMarkdownFile(filePath: String) {
        
    }
    
    static func generateHTMLfromMarkdownString(contents: String) {
//        let down = Down(markdownString: contents)
    }
    
    static func generateHTMLfromMarkdownFile(filePath: String) {
    
    }
}
