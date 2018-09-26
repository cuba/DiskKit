//
//  ArticleViewController.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import UIKit
import DiskKit

protocol ArticleModuleDelegate {
    func articleModuleDidSave(_ article: Article)
    func articleModuleDidCancel()
}

class ArticleViewController: UIViewController {
    lazy var textView: UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.delegate = self
        return textView
    }()
    
    let url: URL
    var article: Article
    var delegate: ArticleModuleDelegate?
    
    init(article: Article, url: URL) {
        self.url = url
        self.article = article
        super.init(nibName: nil, bundle: nil)
        
        textView.text = article.details.body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        view.backgroundColor = UIColor.groupTableViewBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(tappedCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(tappedSave))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    private func setupLayout() {
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: 0).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    @objc private func tappedSave() {
        textView.resignFirstResponder()
        
        do {
            try article.save(to: url, from: url)
            delegate?.articleModuleDidSave(article)
        } catch let error {
            print(error)
        }
    }
    
    @objc func tappedCancel() {
        delegate?.articleModuleDidCancel()
    }
}

// MARK: - Keyboard

extension ArticleViewController {
    
    @objc private func keyboardWillShow(notification: NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = self.textView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.textView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.textView.contentInset = contentInset
    }
}

// MARK: - UITextViewDelegate

extension ArticleViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.article.details.body = textView.text
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.article.details.body = textView.text
    }
}

