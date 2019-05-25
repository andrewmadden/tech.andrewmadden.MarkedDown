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
//            self.editorTextView.attributedText = attributedString
            self.textStorage.setAttributedString(attributedString)
        }
        
        // Add markdown syntax highlighting to text view
        textStorage.addLayoutManager(editorTextView.layoutManager)
        
        // set title with filename
        self.navigationItem.title = fileEditing?.fileName
        
        // get notified when the keyboard appears and disappears
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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

    
    // resize textview when keyboard is shown and hidden.
    // code from https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            editorTextView.contentInset = .zero
        } else {
            editorTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        editorTextView.scrollIndicatorInsets = editorTextView.contentInset
        
        let selectedRange = editorTextView.selectedRange
        editorTextView.scrollRangeToVisible(selectedRange)
    }
}
