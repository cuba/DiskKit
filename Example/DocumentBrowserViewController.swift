//
//  DocumentBrowserViewController.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-17.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import UIKit
import DiskKit

@available(iOS 11.0, *)
class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        browserUserInterfaceStyle = .dark
        view.tintColor = .white
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let filename = "\(UUID().uuidString).package"
        let url = Disk.Directory.documents.makeUrl(filename: filename)
        let article = Article()
        
        do {
            try article.save(to: url, from: nil)
            importHandler(url, .move)
        } catch {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        do {
            guard let article = try Article.load(from: documentURL) else { return }
            
            let viewController = ArticleViewController(article: article, url: documentURL)
            let navigationController = UINavigationController(rootViewController: viewController)
            viewController.delegate = self
            present(navigationController, animated: true, completion: nil)
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
}

extension DocumentBrowserViewController: ArticleModuleDelegate {
    
    func articleModuleDidSave(_ article: Article) {
        dismiss(animated: true, completion: nil)
    }
    
    func articleModuleDidCancel() {
        dismiss(animated: true, completion: nil)
    }
}
