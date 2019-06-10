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
    
    // creates a pdf file from string and returns data
    static func generatePDFData(markdownString contents: String, pageSize: PageSize = .A4) -> Data? {
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
    
    static func generateHTMLData(markdownString contents: String) -> Data? {
        // create attribute string representing html
        let down = Down(markdownString: contents)
        guard let html = try? down.toHTML() else { return nil }
        let webpageHtml = Webpage().boilerplate(html)
        
        // create data for pdf file
        return Data(webpageHtml.utf8)
    }
    
    static func generateMarkdownData(markdownString contents: String) -> Data? {
        // create data for pdf file
        let data = Data(contents.utf8)
        return data
    }
    
    static func generatePDFFile(fileKey: String, markdownString contents: String, pageSize: PageSize = .A4) -> URL? {
        guard let data = generatePDFData(markdownString: contents, pageSize: pageSize) else { return nil }
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileKey).appendingPathExtension("pdf")
        FileManager.default.createFile(atPath: tempFilePath.relativePath, contents: data, attributes: nil)
        
        return tempFilePath
    }
    
    static func generateHTMLFile(fileKey: String, markdownString contents: String) -> URL? {
        guard let data = generateHTMLData(markdownString: contents) else { return nil }
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileKey).appendingPathExtension("html")
        FileManager.default.createFile(atPath: tempFilePath.relativePath, contents: data, attributes: nil)
        
        return tempFilePath
    }
    
    static func generateMarkdownFile(fileKey: String, markdownString contents: String) -> URL? {
        guard let data = generateMarkdownData(markdownString: contents) else { return nil }
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileKey).appendingPathExtension("txt")
        FileManager.default.createFile(atPath: tempFilePath.relativePath, contents: data, attributes: nil)
        
        return tempFilePath
    }
}
