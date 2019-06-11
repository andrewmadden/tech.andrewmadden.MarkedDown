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
    var fileName: String
    var filePath: URL
    var contents: String?
    var fm = FileManager.default
    
    init(fileName: String) {
        self.fileName = fileName
        self.filePath = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        self.getContentsFromFile()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("EditorDidEndEditing"), object: nil, queue: nil) { (notification) in
            // update file
            do {
                try self.contents?.write(to: self.filePath, atomically: true, encoding: String.Encoding.utf8) // TODO what kind of encoding to use?
                print("saved file")
            } catch {
                // TODO: tell user failed to write to disk
                print("failed to save file")
            }
        }
    }
    
    // file name without extension
    var fileKey: String {
        return self.fileName.fileKey()
    }
    
    // get contents from file
    private func getContentsFromFile() {
        do {
            self.contents = try String(contentsOfFile: self.filePath.relativePath)
            print("Loaded content from file: " + self.fileName)
        } catch {
            print("Could not load content from file: " + self.fileName)
        }
    }
    
    // delete file
    func deleteFile() -> Bool {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        do {
            try fm.removeItem(at: path)
            contents = nil
            return true
        } catch {
            return false
        }
    }
    
    // checks if file exists
    func exists() -> Bool {
        return FileManager.default.fileExists(atPath: self.filePath.relativeString)
    }
}
