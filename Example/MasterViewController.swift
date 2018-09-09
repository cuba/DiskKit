//
//  MasterViewController.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import UIKit
import DiskKit

public enum CellProvider {
    case standard
    case subtitle
    case rightValue
    
    public var reuseIdentifier: String {
        switch self {
        case .standard                          : return "StandardCell"
        case .subtitle                          : return "SubtitleCell"
        case .rightValue                        : return "RightValueCell"
        }
    }
    
    public var cellType: UITableViewCell.Type {
        switch self {
        case .standard                  : return UITableViewCell.self
        case .subtitle                  : return UITableViewCell.self
        case .rightValue                : return UITableViewCell.self
        }
    }
    
    public func dequeCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .subtitle:
            return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        case .rightValue:
            return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        default:
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
                return cell
            } else {
                tableView.register(cellType, forCellReuseIdentifier: reuseIdentifier)
                return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            }
        }
    }
}

class MasterViewController: UITableViewController {
    var articles: [Article] = []
    let subfolder: Folder = "examples"
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        
        do {
            try Disk.create(subfolder: subfolder, in: .documents)
            articles = try EncodableDisk.files(in: .documents)
        } catch let error {
            // TODO: Show error
            print(error.localizedDescription)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedAddButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tappedRefreshButton))
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func tappedAddButton() {
        let article = Article(body: "")
        navigate(to: article)
    }
    
    @objc private func tappedRefreshButton() {
        do {
            articles = try EncodableDisk.files(in: .documents)
        } catch let error {
            // TODO: Show error
            print(error.localizedDescription)
        }
    }
    
    private func navigate(to article: Article) {
        let detailsViewController = DetailViewController(article: article)
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        detailsViewController.configure(with: article)
        detailsViewController.delegate = self
        splitViewController?.showDetailViewController(navigationController, sender: self)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellProvider.subtitle.dequeCell(for: tableView, at: indexPath)

        let article = articles[indexPath.row]
        cell.textLabel?.text = article.displayFileName
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = dateFormatter.string(from: article.dateUpdated)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        navigate(to: article)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            articles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
}

extension MasterViewController: DetailViewControllerDelegate {
    func detailViewController(_ detailViewController: DetailViewController, requiresSaveForArticle article: Article) {
        var article = article
        
        do {
            article.isModified = false
            let url = try EncodableDisk.store(article, to: .documents, as: article.fileName)
            print(url)
        } catch let error {
            // TODO: Show error
            print(error)
            return
        }
        
        if let indexPath = indexPath(for: article) {
            articles[indexPath.row] = article
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            articles.insert(article, at: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func detailViewController(_ detailViewController: DetailViewController, didModifyArticle article: Article) {
        guard let indexPath = indexPath(for: article) else { return }
        articles[indexPath.row] = article
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func indexPath(for article: Article) -> IndexPath? {
        guard let row = articles.index(of: article) else { return nil }
        return IndexPath(row: row, section: 0)
    }
}
