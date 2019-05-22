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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorTextView.delegate = self
        
        // Add markdown syntax highlighting to text view
        textStorage.addLayoutManager(editorTextView.layoutManager)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text: String =  textView.layoutManager.textStorage?.string {
                  NotificationCenter.default.post(Notification(name: Notification.Name("ContentsChanged"), object: nil, userInfo: ["newContents": text]))
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
