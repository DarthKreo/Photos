//
//  MainViewController.swift
//  Photos
//
//  Created by Владимир Кваша on 26.11.2020.
//

import UIKit

// MARK: - MainViewController

final class MainViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var changePresentButton: UIBarButtonItem!
    @IBOutlet weak var galleryCollection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

