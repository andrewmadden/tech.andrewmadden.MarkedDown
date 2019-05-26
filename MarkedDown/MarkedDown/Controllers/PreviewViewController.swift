//
//  PreviewViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 8/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit
import WebKit
import Down

class PreviewViewController: UIViewController {
    @IBOutlet weak var webPreview: WKWebView!
    
    var html = ""
    var fileEditing: MarkdownFile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title with filename
        self.navigationItem.title = fileEditing?.fileName
        
        // initialize view
        self.loadHTML(from: self.fileEditing?.contents)
        
    }
    
    private func loadHTML(from contents: String?) {
        if let contents = contents {
            // create HTML from file contents
            self.html = try! Down(markdownString: contents).toHTML()
            // boilerplate for webpage
            let webpageHTML: String = Webpage().boilerplate(self.html)
            self.webPreview?.loadHTMLString(webpageHTML, baseURL: nil)
        }
    }
    
    // update web view with new content from file
    func setEditorObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("EditorContentsUpdated"), object: nil, queue: nil) { (notification) in
            self.loadHTML(from: self.fileEditing?.contents)
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
