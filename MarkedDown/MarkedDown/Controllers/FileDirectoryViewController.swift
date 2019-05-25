//
//  FileDirectoryViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 22/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit

class FileDirectoryViewController: UIViewController {

    let fm = FileManager.default
    let path = Bundle.main.resourcePath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // add 'add file' icon in nav bar
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(newFile))
    }
    
    @objc func newFile() {
        print("new file selected")
        // dialog to get new filename
        let alert = UIAlertController(title: "New File", message: "Enter a file name", preferredStyle: .alert)
        
        // add text field for new file name
        alert.addTextField { (textField: UITextField) in
                textField.placeholder = "newFile"
        }
        
        // add action to create button
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            if let newFileName: String = alert?.textFields![0].text {
                // create file and trigger segue to editor
                print(newFileName)
            } else {
                // throw error that file could not be created
            }
        }))
        
        // add action to close dialog without doing anything to cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            print("Create File was cancelled")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func getFilesFromDocumentsDirectory() {
        let files = try? fm.contentsOfDirectory(atPath: getDocumentsDirectory().absoluteString)
        files?.forEach { print($0) }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
