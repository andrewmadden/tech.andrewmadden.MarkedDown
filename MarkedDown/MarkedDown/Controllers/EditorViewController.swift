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

enum MarkedDownFileType {
    case pdf
    case md
    case html
}

class EditorViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
//        let menuRightNavigationController = UISideMenuNavigationController(rootViewController: self.tabBarController ?? self)
//        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        
        // add navigation menu buttons
//        let menuButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(presentSideMenu))
//        self.tabBarController?.navigationItem.rightBarButtonItems?.append(menuButton)
        
        // add undo and redo buttons to toolbar
        let undoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "UndoImage"), style: .plain, target: self, action: #selector(undo))
        let redoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "RedoImage"), style: .plain, target: self, action: #selector(redo))
        let exportButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ExportImage"), style: .plain, target: self, action: #selector(exportAlert))
        self.tabBarController?.navigationItem.rightBarButtonItems = [exportButton, redoButton, undoButton]
    }
    
    @objc func exportAlert() {
        let alert = UIAlertController(title: "Export File", message: "Choose a format", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Export as MarkDown", style: .default, handler: { (_) in
            self.shareData(fileType: .md)
        }))
        alert.addAction(UIAlertAction(title: "Export as HTML", style: .default, handler: { (_) in
            self.shareData(fileType: .html)
        }))
        alert.addAction(UIAlertAction(title: "Export as PDF", style: .default, handler: { (_) in
            self.shareData(fileType: .pdf)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func shareData(fileType: MarkedDownFileType) {
        guard let file = self.fileEditing else { return }
        let data: Data?
        switch (fileType) {
        case .md: data = FileGenerator.generateMarkdownData(markdownString: file.contents ?? "")
        break
        case .html: data = FileGenerator.generateHTMLData(markdownString: file.contents ?? "")
        break
        case .pdf: data = FileGenerator.generatePDFData(markdownString: file.contents ?? "")
        break
        }
        let activity = UIActivityViewController(
            activityItems: [data],
            applicationActivities: nil
        )
        self.present(activity, animated: true, completion: nil)
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
        let bold = UIBarButtonItem(image: #imageLiteral(resourceName: "BoldImage"), style: .plain, target: self, action: #selector(inputBold))
        let italic = UIBarButtonItem(image: #imageLiteral(resourceName: "ItalicImage"), style: .plain, target: self, action: #selector(inputItalic))
        let code = UIBarButtonItem(image: #imageLiteral(resourceName: "CodeImage"), style: .plain, target: self, action: #selector(inputCodeBlock))
        let quote = UIBarButtonItem(image: #imageLiteral(resourceName: "QuoteImage"), style: .plain, target: self, action: #selector(inputBlockQuote))
        let separator = UIBarButtonItem(image: #imageLiteral(resourceName: "SeparatorImage"), style: .plain, target: self, action: #selector(inputLineSeparator))
        let link = UIBarButtonItem(image: #imageLiteral(resourceName: "SeparatorImage"), style: .plain, target: self, action: #selector(inputLink))
        let image = UIBarButtonItem(image: #imageLiteral(resourceName: "PictureImage"), style: .plain, target: self, action: #selector(importImage))
        
        // add buttons to toolbar
        toolbar.items = [H1, H2, bold, italic, code, quote, separator, link, image]
        toolbar.sizeToFit()
        
        // add the toolbar to the keyboard
        editorTextView.inputAccessoryView = toolbar
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
    
    @objc private func inputLink() {
        insertSyntax("[]()  ", setCursorTo: .middle)
    }
    
    private func inputImage(location path: URL, fileName: String = "description") {
        insertSyntax("![\(fileName)](\(path.relativeString))", setCursorTo: .end)
    }
    
    @objc func importImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[.editedImage] as? UIImage else { return }
        if let sourcePath = info[.imageURL] as? URL  {
            // copy image to bundle and get link
            let fileName = sourcePath.lastPathComponent
            let bundlePath = Bundle.main.bundleURL
            var destPath = bundlePath.appendingPathComponent("resources")
            destPath = destPath.appendingPathComponent(fileName, isDirectory: false)
            // TODO handle error that file cannot be added to bundle
            try? FileManager.default.copyItem(at: sourcePath, to: destPath)
            
            inputImage(location: destPath, fileName: fileName)
            
        }
        dismiss(animated: true)
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
