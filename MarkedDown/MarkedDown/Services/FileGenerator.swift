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
        
        // create data for html file
        return Data(webpageHtml.utf8)
    }
    
    static func generateMarkdownData(markdownString contents: String) -> Data? {
        // create data for markdown file
        let data = Data(contents.utf8)
        return data
    }
    
    static func generateTempFile(fileKey: String, markdownString contents: String, fileType: MarkedDownFileType) -> URL? {
        let data: Data?
        switch (fileType) {
        case .md: data = FileGenerator.generateMarkdownData(markdownString: contents)
            break
        case .html: data = FileGenerator.generateHTMLData(markdownString: contents)
            break
        case .pdf: data = FileGenerator.generatePDFData(markdownString: contents)
            break
        default: data = nil
            break
        }
        let tempFilePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileKey).appendingPathExtension(fileType.rawValue)
        do {
            try data?.write(to: tempFilePath, options: .atomic)
        } catch {
            return nil
        }
        return tempFilePath
    }
    
    static func generateTempData(fileKey: String, markdownString contents: String, fileType: MarkedDownFileType) -> Data? {
        let data: Data?
        switch (fileType) {
        case .md: data = FileGenerator.generateMarkdownData(markdownString: contents)
            break
        case .html: data = FileGenerator.generateHTMLData(markdownString: contents)
            break
        case .pdf: data = FileGenerator.generatePDFData(markdownString: contents)
            break
        default: data = nil
            break
        }
        return data
    }
}
