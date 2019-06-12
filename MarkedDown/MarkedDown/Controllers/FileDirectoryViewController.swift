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

class FileDirectoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
  
    let fm = FileManager.default
    var files: [String] = []
    var fileEditing: MarkdownFile?
    let validFileTypes = [MarkedDownFileType.md, MarkedDownFileType.markdown, MarkedDownFileType.txt]
    
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
        
        // add 'add file' icon in nav bar
        let addFileButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(newFile))
        let browseFilesButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(browse))
        
        self.navigationItem.rightBarButtonItems = [browseFilesButton, addFileButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // refresh list
        getFilesFromDocumentsDirectory()
    }
    
    /* CRUD methods for files */
    
    // open document picker to allow user to select external files
    @objc func browse() {
//        let docTypes = ["public.text", "public.plain-text", "net.daringfireball.markdown", "public.item"]
        // public.item allows all doc types - would be better to only use markdown UTI but haven't managed to figure it out
        let docTypes = ["public.item"]
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: docTypes, in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true)
    }
    
    // a user selects a document
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedURL = urls.first {
            // import file into app
            let fileName = selectedURL.lastPathComponent
            let destURL = getDocumentsDirectory().appendingPathComponent(fileName)
            do { try FileManager.default.copyItem(at: selectedURL, to: destURL) } catch {
                presentError(message: "Unable to get external file")
                return
            }
            self.fileEditing = MarkdownFile(fileName: fileName)
            // if failed to open content of file don't open editor
            if let _ = self.fileEditing!.contents {
                performSegue(withIdentifier: "openFileSegue", sender: nil)
            } else {
                presentError(message: "Could not load data from \(fileName)")
            }
        }
        print("completed picker")
    }
    
    // prompt new file name modally
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
            }
        }))
        
        // add action to close dialog without doing anything to cancel button
        alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert!, animated: true, completion: nil)
    }
    
    // validates the new file name
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
        } else {
            presentError(message: "File could not be created")
        }
    }
    
    // delete file by swiping row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // alert to confirm delete file request
            let alert = UIAlertController(title: "Delete File", message: "Are you sure you want to delete '" + files[indexPath.row] + "'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                let fileToDelete = MarkdownFile(fileName: self.files[indexPath.row])
                if ( fileToDelete.deleteFile() ) {
                    self.files.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    // refresh local data
                    tableView.reloadData()
                } else {
                    // tell user delete failed
                    self.presentError(message: "Could not delete file")
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // get all local files of correct type to display in list
    func getFilesFromDocumentsDirectory() {
        if let latestFiles: [String] = try? fm.contentsOfDirectory(atPath: getDocumentsDirectory().relativePath) {
            // filter and show only valid files
            self.files = latestFiles.filter { (fileName) in
                if let fileType = MarkedDownFileType(rawValue: fileName.fileExtension()) {
                    return validFileTypes.contains(fileType)
                }
                return false
            }
        }
        // refresh table view
        filesTableView.reloadData()
    }
    
    /* Setup Table View */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        // strip .md from filename
        cell.textLabel?.text = files[indexPath.row].fileKey()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set up model with selected file name
        let selectedFileName: String = self.files[indexPath.row]
        self.fileEditing = MarkdownFile(fileName: selectedFileName)
        
        performSegue(withIdentifier: "openFileSegue", sender: nil)
    }
    
    /* Setup segue to editor */
    
    // pass the file model to tab views
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
    
    /* Display errors for user */
    
    // presents an alert with an error message
    func presentError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // for displaying error in new file name alert
    private func setupErrorLabel() {
        errorLabel.text = "Error"
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        errorLabel.font = errorLabel.font.withSize(12)
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
 
}
