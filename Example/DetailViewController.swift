//
//  DetailViewController.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import UIKit
import DiskKit

protocol DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, requiresSaveForArticle article: Article)
    func detailViewController(_ detailViewController: DetailViewController, didModifyArticle article: Article)
}

class DetailViewController: UIViewController {
    lazy var textView: UITextView = {
        let textView = UITextView(frame: CGRect.zero)
        textView.delegate = self
        return textView
    }()
    
    var article: Article?
    var delegate: DetailViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        view.backgroundColor = UIColor.groupTableViewBackground
        configure(with: self.article)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(tappedSave))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    func configure(with article: Article?) {
        self.article = article
        title = article?.filename ?? "New Article"
        textView.text = article?.body
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
        guard let article = article else { return }
        delegate?.detailViewController(self, requiresSaveForArticle: article)
    }
}

// MARK: - Keyboard

extension DetailViewController {
    
    @objc private func keyboardWillShow(notification: NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
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

extension DetailViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var article = self.article ?? Article(body: "")
        article.body = textView.text
        article.isModified = true
        self.article = article
        delegate?.detailViewController(self, didModifyArticle: article)
    }
}

