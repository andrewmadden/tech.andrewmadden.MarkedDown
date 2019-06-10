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
    
//    // creates a pdf file from string and returns filepath
//    static func generatePDFfromMarkdownString(fileKey: String, contents: String, pageSize: PageSize = .A4) -> URL? {
//        let fm = FileManager()
//
//        // create attribute string representing html
//        let down = Down(markdownString: contents)
//        guard let attributedHTML = try? down.toAttributedString() else { return nil }
//
//        // create renderer
//        let pageRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
//        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
//
//        // create data for pdf file
//        let data = renderer.pdfData { ctx in
//            ctx.beginPage()
//            attributedHTML.draw(in: pageRect.insetBy(dx: 50, dy: 50))
//        }
//
//        // save pdf file to temp directory
//        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        let tempFilePath = tempDir.appendingPathComponent(fileKey).appendingPathExtension("pdf")
//        fm.createFile(atPath: tempFilePath.relativePath, contents: data, attributes: nil)
//
//        return tempFilePath
//    }
    
    // creates a pdf file from string and returns data
    static func generatePDFData(fileKey: String, markdownString contents: String, pageSize: PageSize = .A4) -> Data? {
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
        
        return data
    }
    
    static func generateHTMLData(fileKey: String, markdownString contents: String) -> Data? {
        // create attribute string representing html
        let down = Down(markdownString: contents)
        guard let html = try? down.toHTML() else { return nil }
        
        // create data for pdf file
        return Data(html.utf8)
    }
    
    static func generateMarkdownData(fileKey: String, markdownString contents: String) -> Data? {
        // create data for pdf file
        let data = Data(contents.utf8)
        return data
    }
}
