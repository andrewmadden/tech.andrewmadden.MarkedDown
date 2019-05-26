//
//  FileDirectoryViewController.swift
//  MarkedDown
//
//  Created by andrew madden on 22/5/19.
//  Copyright © 2019 Andrew Madden. All rights reserved.
//

import UIKit

enum ErrorMessage: String {
    case empty = "File name cannot be empty"
    case exists = "File already exists"
}

class FileDirectoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    let fm = FileManager.default
    var files: [String] = []
    var fileEditing: MarkdownFile?
    
    // new file alert
    var alert: UIAlertController?
    var errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    
    @IBOutlet weak var filesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview datasource and delegate
        self.filesTableView.dataSource = self
        self.filesTableView.delegate = self
        
        // setup error label for create file alert popup
        setupErrorLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // add 'add file' icon in nav bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(newFile))
        
        // refresh list
        getFilesFromDocumentsDirectory()
    }
    
    private func setupErrorLabel() {
        errorLabel.text = "Error"
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        errorLabel.font = errorLabel.font.withSize(12)
    }
    
    @objc func newFile() {
        print("new file selected")
        // dialog to get new filename
        alert = UIAlertController(title: "New File", message: "Enter a file name", preferredStyle: .alert)
        
        // add text field for new file name
        alert!.addTextField { (textField: UITextField) in
            // add validate input listener
            textField.addTarget(self, action: #selector(self.newFileTextFieldDidChange(_:)), for: .editingChanged)
            textField.addTarget(self, action: #selector(self.newFileTextFieldDidChange(_:)), for: .editingDidBegin)
            textField.addSubview(self.errorLabel)
        }
        
        // add action to create button
        alert!.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            if let newFileName: String = alert?.textFields![0].text {
                // create file and trigger segue to editor
                self.createNewMarkDownFile(newFileName)
                print(newFileName)
            } else {
                // throw error that file could not be created
            }
        }))
        
        // add action to close dialog without doing anything to cancel button
        alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert!, animated: true, completion: nil)
    }
    
    @objc func newFileTextFieldDidChange(_ textField: UITextField) {
        // reset
        errorLabel.isHidden = true
        if let alert = self.alert { alert.actions[0].isEnabled = true }
        
        // check for validation
        // if not valid, disable create button and show error message
        if textField.text!.isEmpty {
            errorLabel.isHidden = false
            errorLabel.text = ErrorMessage.empty.rawValue
            if let alert = self.alert { alert.actions[0].isEnabled = false }
        } else if files.contains(textField.text! + ".md") {
            errorLabel.isHidden = false
            errorLabel.text = ErrorMessage.exists.rawValue
            if let alert = self.alert { alert.actions[0].isEnabled = false }
        }
    }
    
    // create new file in Documents directory and open editor if successful
    func createNewMarkDownFile(_ fileKey: String) {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileKey).appendingPathExtension("md")
        let isFileCreated = fm.createFile(atPath: filePath.relativePath, contents: Data(base64Encoded: ""), attributes: nil) // TODO what about errors?
        if (isFileCreated) {
            self.fileEditing = MarkdownFile(fileName: fileKey + ".md")
            performSegue(withIdentifier: "openFileSegue", sender: nil)
        }
    }
    
    func getFilesFromDocumentsDirectory() {
        if let latestFiles: [String] = try? fm.contentsOfDirectory(atPath: getDocumentsDirectory().relativePath) {
            self.files = latestFiles
            // filter and show only .md files
            // TODO extend for other markdown mime types
            self.files = self.files.filter { (fileName) in
                return fileName.suffix(3) == ".md"
            }
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
        // strip .md from filename
        cell.textLabel?.text = String(files[indexPath.row].prefix(files[indexPath.row].count - 3))
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
