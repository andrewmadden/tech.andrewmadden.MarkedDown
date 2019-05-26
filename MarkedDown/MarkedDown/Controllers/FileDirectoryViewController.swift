//
//  FileDirectoryViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 22/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit

class FileDirectoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    let fm = FileManager.default
    var files: [String] = []
    var fileEditing: MarkdownFile?
    
    @IBOutlet weak var filesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview datasource and delegate
        self.filesTableView.dataSource = self
        self.filesTableView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // add 'add file' icon in nav bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(newFile))
        
        // refresh list
        getFilesFromDocumentsDirectory()
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
                self.createNewMarkDownFile(newFileName)
                print(newFileName)
            } else {
                // throw error that file could not be created
            }
        }))
        
        // add action to close dialog without doing anything to cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // create new file in Documents directory and open editor if successful
    func createNewMarkDownFile(_ fileKey: String) {
        let fileName = fileKey + ".md"
        let filePath: String = getDocumentsDirectory().relativePath + "/" + fileName
        let isFileCreated = fm.createFile(atPath: filePath, contents: Data(base64Encoded: ""), attributes: nil) // TODO what about errors?
        if (isFileCreated) {
            self.fileEditing = MarkdownFile(fileName: fileName)
            performSegue(withIdentifier: "openFileSegue", sender: nil)
        }
    }
    
    func getFilesFromDocumentsDirectory() {
        if let latestFiles: [String] = try? fm.contentsOfDirectory(atPath: getDocumentsDirectory().relativePath) {
            self.files = latestFiles
        }
        
        // refresh table view
        filesTableView.reloadData()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        cell.textLabel?.text = files[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set up model with selected file name
        let selectedFileName: String = self.files[indexPath.row]
        self.fileEditing = MarkdownFile(fileName: selectedFileName)
        
        performSegue(withIdentifier: "openFileSegue", sender: nil)
    }
    
    // delete file by swiping row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // alert to confirm delete file request
            let alert = UIAlertController(title: "Delete File", message: "Are you sure you want to delete '" + files[indexPath.row] + "'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                if self.deleteFile(self.files[indexPath.row]) {
                    self.files.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    // refresh local data
                    tableView.reloadData()
                } else {
                    // tell user delete failed
                    let alert = UIAlertController(title: "Error", message: "Could not delete file", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabViewController = segue.destination as? UITabBarController {
            // set the file model in the editor and preview views
            if let viewController = tabViewController.viewControllers?[0] as? EditorViewController {
                viewController.fileEditing = self.fileEditing
            }
            if let viewController = tabViewController.viewControllers?[1] as? PreviewViewController {
                viewController.fileEditing = self.fileEditing
                viewController.setEditorObserver()
            }
        }
    }
    
    func deleteFile(_ fileName: String) -> Bool {
        let path = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try fm.removeItem(at: path)
            return true
        } catch {
            return false
        }
    }
 
}
