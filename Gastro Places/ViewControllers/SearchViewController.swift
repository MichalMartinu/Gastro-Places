//
//  SearchViewController.swift
//  Gastro Places
//
//  Created by Michal Martinů on 14/03/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTypePicker: UISegmentedControl!
    @IBOutlet weak var resultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
}

extension SearchViewController: UISearchBarDelegate {
}
