//
//  EditorViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 8/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit
import SideMenu
import Highlightr

enum CursorPosition {
    case start
    case middle
    case end
}

class EditorViewController: UIViewController, UITextViewDelegate {
    // main text view
    @IBOutlet weak var editorTextView: UITextView!

    var fileEditing: MarkdownFile? = nil
    let highlightr = Highlightr()!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorTextView.delegate = self
        
        // set up highlightr
        highlightr.setTheme(to: "tomorrow")
        
        // load content from file model
        if let contents: String =  self.fileEditing?.contents {
            updateHightlighting(text: contents)
        }
        
        // set title with filename
        self.tabBarController?.title = fileEditing?.fileName
        
        // get notified when the keyboard appears and disappears
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        setupSideMenu()
        
        // attach toolbar to keyboard when textview is editing
        setupToolbar()
        
    }
    
    private func setupSideMenu() {
        // setup side menu
        let menuRightNavigationController = UISideMenuNavigationController(rootViewController: self.tabBarController ?? self)
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        
        // add navigation menu buttons
        let menuButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(presentSideMenu))
        self.tabBarController?.navigationItem.rightBarButtonItems?.append(menuButton)
    }
    
    @objc func presentSideMenu() {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar()
        
        // setup buttons
//        let undoButton = UIBarButtonItem(title: "undo", style: .plain, target: self, action: #selector(undo))
//        let redoButton  = UIBarButtonItem(title: "redo", style: .plain, target: self, action: #selector(redo))
        let H1 = UIBarButtonItem(title: "H1", style: .plain, target: self, action: #selector(inputH1))
        let H2 = UIBarButtonItem(title: "H2", style: .plain, target: self, action: #selector(inputH2))
        let H3 = UIBarButtonItem(title: "H3", style: .plain, target: self, action: #selector(inputH3))
        let bold = UIBarButtonItem(image: #imageLiteral(resourceName: "BoldImage"), style: .plain, target: self, action: #selector(inputBold))
        let italic = UIBarButtonItem(image: #imageLiteral(resourceName: "ItalicImage"), style: .plain, target: self, action: #selector(inputItalic))
        let code = UIBarButtonItem(image: #imageLiteral(resourceName: "CodeImage"), style: .plain, target: self, action: #selector(inputCodeBlock))
        let quote = UIBarButtonItem(image: #imageLiteral(resourceName: "QuoteImage"), style: .plain, target: self, action: #selector(inputBlockQuote))
        let separator = UIBarButtonItem(image: #imageLiteral(resourceName: "SeparatorImage"), style: .plain, target: self, action: #selector(inputLineSeparator))
        
        // add buttons to toolbar
        toolbar.items = [H1, H2, H3, bold, italic, code, quote, separator]
        toolbar.sizeToFit()
        
        // add the toolbar to the keyboard
        editorTextView.inputAccessoryView = toolbar
        
        // add undo and redo buttons to toolbar
        let undoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.undo, target: self, action: #selector(undo))
        let redoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.redo, target: self, action: #selector(redo))
        self.tabBarController?.navigationItem.rightBarButtonItems = [undoButton, redoButton]
    }
    
    
    
    // toolbar button functions
    
    @objc private func undo() {
        if ( editorTextView.undoManager?.canUndo == true ) { editorTextView.undoManager?.undo() }
    }
    
    @objc private func redo() {
        if ( editorTextView.undoManager?.canRedo == true ) { editorTextView.undoManager?.redo() }
    }
    
    @objc private func inputH1() {
        insertSyntax("\n# ", setCursorTo: .end)
    }
    
    @objc private func inputH2() {
        insertSyntax("\n## ", setCursorTo: .end)
    }
    
    @objc private func inputH3() {
        insertSyntax("\n### ", setCursorTo: .end)
    }
    
    @objc private func inputBold() {
        insertSyntax("****", setCursorTo: .middle)
    }
    
    @objc private func inputItalic() {
        insertSyntax("**", setCursorTo: .middle)
    }
    
    @objc private func inputCodeBlock() {
        insertSyntax("\n```\n\n``` ", setCursorTo: .middle)
    }
    
    @objc private func inputBlockQuote() {
        insertSyntax("\n> ", setCursorTo: .end)
    }
    
    @objc private func inputLineSeparator() {
        insertSyntax("\n***\n", setCursorTo: .end)
    }
    
    private func insertSyntax(_ syntax: String, setCursorTo cursorPosition: CursorPosition) {
        // get cursor position
        let selectedRange: NSRange = editorTextView.selectedRange
        guard let selectedTextRange: UITextRange = editorTextView.selectedTextRange else { return }
        // add syntax
//        editorTextView.textStorage.replaceCharacters(in: selectedRange, with: syntax)
        editorTextView.replace(selectedTextRange, withText: syntax)
        updateHightlighting(text: editorTextView.textStorage.string)
        
        // set cursor
        var newPosition: NSRange?
        switch (cursorPosition) {
            case .end: newPosition = NSRange(location: selectedRange.lowerBound + syntax.count, length: 0)
            break
            case .middle: newPosition = NSRange(location: selectedRange.lowerBound + (syntax.count / 2), length: 0)
            break
            default: newPosition = selectedRange
            break
        }
        if let newPosition: NSRange = newPosition {
            editorTextView.selectedRange = newPosition
        }
    }
    
    func updateHightlighting(text: String) {
        if let highlightedCode = highlightr.highlight(text, as: "markdown") {
            editorTextView.textStorage.setAttributedString(highlightedCode)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text: String =  textView.layoutManager.textStorage?.string {
            updateHightlighting(text: text)
            // update file model
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
