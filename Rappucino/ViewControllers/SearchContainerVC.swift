//
//  CreateSquadViewController.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-28.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit

class SearchResultsViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var rappers = [Rapper]()
    var selectedRappers = [Rapper]()
    
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    let createSquadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    func setupUI() {
        
        self.view.backgroundColor = .white
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        // Setup the Scope Bar
        //searchController.searchBar.scopeButtonTitles = ["All", "Rappers", "Squads"]
        
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = false
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        let searchBar = searchController.searchBar
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for rappers"
        
        //tableView.tableHeaderView = searchBar
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        createSquadButton.backgroundColor = .blue
        createSquadButton.setTitle("Create squad!", for: .normal)
        createSquadButton.setTitleColor(.white, for: .normal)
        createSquadButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        createSquadButton.addTarget(self, action: #selector(createSquadButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(createSquadButton)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.frame = CGRect(x: 0, y: view.bounds.height*0.1, width: view.bounds.width, height: view.bounds.height*0.8)
        createSquadButton.frame = CGRect(x: 0, y: tableView.frame.maxY, width: view.bounds.width, height: view.bounds.height - tableView.frame.maxY)
        
        
        self.present(searchController, animated: true, completion: nil)
        
    }
    
    @objc func createSquadButtonPressed(sender: UIButton) {
        
        for r in selectedRappers {
            print(r.getName())
        }
        
        self.searchController.isActive = false
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchTerm = searchController.searchBar.text {
            
            if searchTerm.count < 1 { return }
            
            Api.shared.get_rappers(query: searchTerm) { rappers in
                if let rappers = rappers {
                    self.rappers = rappers
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rappers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let r = rappers[indexPath.row]
        
        cell.textLabel?.text = r.getName()
        cell.detailTextLabel?.text = r.getHandle()
        
        if selectedRappers.contains( where: { $0.getId() == r.getId() } ) {
            cell.accessoryType = .checkmark
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let r = rappers[indexPath.row]
        if !selectedRappers.contains( where: { $0.getId() == r.getId() } ) {
            selectedRappers.append(r)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            selectedRappers.remove(at: selectedRappers.index(where: { $0.getId() == r.getId() })!)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        
    }
    
}
