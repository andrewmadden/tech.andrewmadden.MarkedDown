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
    var downView: DownView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title with filename
        self.navigationItem.title = fileEditing?.fileName
        
        // initialize view
        self.loadHTML(from: self.fileEditing?.contents)
        
    }
    
    private func loadHTML(from contents: String?) {
        if let contents = contents {
            downView = try? DownView(frame: self.view.bounds, markdownString: contents, templateBundle: Bundle.main) {
                self.view.addSubview(self.downView!)
            }
        }
    }
    
    // update web view with new content from file
    func setEditorObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("EditorContentsUpdated"), object: nil, queue: nil) { (notification) in
            self.loadHTML(from: self.fileEditing?.contents)
        }
    }
    

}
