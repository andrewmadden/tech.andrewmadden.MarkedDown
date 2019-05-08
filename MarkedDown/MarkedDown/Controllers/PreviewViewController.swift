//
//  PreviewViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 8/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit
import WebKit

class PreviewViewController: UIViewController {
    @IBOutlet weak var webPreview: WKWebView!
    
    // test html
    let html = """
        <html>
        <body>
        <h1>Hello World</h1>
        </body>
        </html>
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webPreview.loadHTMLString(html, baseURL: nil)
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
