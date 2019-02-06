//
//  ViewController.swift
//  SearchController
//
//  Created by Scott Gardner on 2/4/19.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recentSearchesTableView: UITableView!
    
    lazy var searchController: UISearchController = {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: SearchResultsViewController.self))
        return UISearchController(searchResultsController: controller)
    }()
    
    var searchResultsController: SearchResultsViewController {
        return searchController.searchResultsController as! SearchResultsViewController
    }
    
    var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()
    
    lazy var data = [
        SectionModel(title: "Letters", data: ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliett", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu"]),
        SectionModel(title: "Numbers", data: (0...100).map { formatter.string(from: NSNumber(integerLiteral: $0))!.capitalized })
    ]
    
    var recentSearches: [String] {
        get { return UserDefaults.standard.array(forKey: "RecentSearches") as? [String] ?? [] }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "RecentSearches")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isInitialized = false
    
    var isSearching = false {
        didSet {
            tableView.isHidden = isSearching
            recentSearchesTableView.isHidden = !isSearching
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureRecentSearchesTableView()
    }
        
    func configureRecentSearchesTableView() {
        recentSearchesTableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0.0, height: 1.0)))
    }
    
    func configureSearchController() {
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Search..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchBar.delegate = self
    }
    
    func reloadRecentSearches() {
        recentSearchesTableView.reloadData()
    }
    
    func reloadSearchResults() {
        searchResultsController.tableView?.reloadData()
    }
    
    func save(recentSearch: String) {
        var recentSearches = self.recentSearches
        recentSearches.insert(recentSearch, at: 0)
        guard let last25 = Array(NSOrderedSet(array: Array(recentSearches.prefix(25)))) as? [String] else { return }
        self.recentSearches = last25
        reloadRecentSearches()
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.tag == 0 ? data.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.tag == 0 ? data[section].data.count : recentSearches.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView.tag == 0 ? data[section].title : "Recent searches"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let text = tableView.tag == 0 ? data[indexPath.section].data[indexPath.row] : "🔍 " + recentSearches[indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.tag == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard tableView.tag == 1 else { return }
        recentSearches.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearching {
            let text = recentSearches[indexPath.row]
            searchBar.text = text
            searchResultsController.searchText = text
            searchBar.delegate?.searchBarSearchButtonClicked?(searchBar)
            searchBar.resignFirstResponder()
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        reloadSearchResults()
        isSearching = true
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultsController.searchText = searchText
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        
        if let searchText = searchBar.text,
            searchText.isEmpty == false {
            save(recentSearch: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadSearchResults()
        isSearching = false
    }
}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchResultsController.data = data
            .map {
                let searchText = searchBar.text?.lowercased() ?? ""
                let data = $0.data.filter { $0.lowercased().contains(searchText) }
                return SectionModel(title: $0.title, data: data)
        }
        
        reloadSearchResults()
    }
}
