//
//  SearchResultsViewController.swift
//  SearchController
//
//  Created by Scott Gardner on 2/4/19.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchText = ""
    var data = [SectionModel]()
    
    func attributedText(for text: String) -> NSAttributedString {
        guard searchText.isEmpty == false,
            let ranges: [Range<String.Index>] = { let r = text.lowercased().ranges(of: searchText.lowercased()); return r.isEmpty ? nil : r }()
            else { return NSAttributedString(string: text) }
        
        let attributedText = NSMutableAttributedString(string: text)
        
        ranges.forEach {
            attributedText.addAttributes(
                [.foregroundColor: UIColor.red,
                 .font: UIFont.boldSystemFont(ofSize: 17.0)
                 ],
                range: NSRange($0, in: text)
            )
        }
        
        return attributedText
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = data[section].data.count
        return count == 0 ? 1 : count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let data = self.data[indexPath.section].data
        
        if data.isEmpty {
            cell.textLabel?.text = "No results found"
        } else {
            cell.textLabel?.attributedText = attributedText(for: data[indexPath.row])
        }
        
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
