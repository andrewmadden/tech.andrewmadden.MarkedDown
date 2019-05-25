//
//  EditorViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 8/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit
import Marklight

class EditorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var editorTextView: UITextView!
    
    let textStorage = MarklightTextStorage()
    var fileEditing: MarkdownFile? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorTextView.delegate = self
        
        // load content from file model
        if let contents: String =  self.fileEditing?.contents {
            let attributedString = NSAttributedString(string: contents)
            self.editorTextView.attributedText = attributedString
//            self.editorTextView.textStorage.append(attributedString)
        }
        
        // Add markdown syntax highlighting to text view
//        textStorage.addLayoutManager(editorTextView.layoutManager)
        
        // set title with filename
        self.navigationItem.title = fileEditing?.fileName
    }
    
    // publishes notification with contents when editor changes
    func textViewDidChange(_ textView: UITextView) {
        if let text: String =  textView.layoutManager.textStorage?.string {
            fileEditing?.contents = text
            NotificationCenter.default.post(Notification(name: Notification.Name("EditorContentsUpdated"), object: nil))
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text: String =  textView.layoutManager.textStorage?.string {
            fileEditing?.contents = text
            NotificationCenter.default.post(Notification(name: Notification.Name("EditorDidEndEditing"), object: nil))
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
