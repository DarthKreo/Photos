//
//  MainViewController.swift
//  Photos
//
//  Created by Владимир Кваша on 26.11.2020.
//

import UIKit
import RealmSwift
import Kingfisher

// MARK: - MainViewController

final class MainViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var changePresentButton: UIBarButtonItem!
    @IBOutlet weak var galleryCollection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Private properties
    
    private lazy var networkService = NetworkService()
    private lazy var photos = [Photo]()
    private lazy var config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    private lazy var listLayout: UICollectionViewFlowLayout = {
        
        let collectionFlowLayout = UICollectionViewFlowLayout()
        let sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        let size = galleryCollection.bounds.width - sectionInset.left * 2
        collectionFlowLayout.sectionInset = sectionInset
        collectionFlowLayout.itemSize = CGSize(width: size, height: size)
        collectionFlowLayout.minimumInteritemSpacing = Constants.collectionFlowLayoutMinimumInteritemSpacing
        collectionFlowLayout.minimumLineSpacing = Constants.collectionFlowLayoutMinimumLineSpacing
        collectionFlowLayout.scrollDirection = .vertical
        return collectionFlowLayout
    }()
    
    private lazy var tileLayout: UICollectionViewFlowLayout = {
        
        let itemsInRow: CGFloat = Constants.itemsInRow
        let collectionFlowLayout = UICollectionViewFlowLayout()
        let sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionFlowLayout.sectionInset = sectionInset
        collectionFlowLayout.minimumInteritemSpacing = sectionInset.left
        collectionFlowLayout.minimumLineSpacing = sectionInset.left
        let paddingSpace = (sectionInset.left + sectionInset.right) * (itemsInRow + 1) + collectionFlowLayout.minimumInteritemSpacing * (itemsInRow - 1)
        let avialableWidth = galleryCollection.bounds.width - paddingSpace
        let size = avialableWidth / itemsInRow
        collectionFlowLayout.scrollDirection = .vertical
        collectionFlowLayout.itemSize = CGSize(width: size, height: size)
        
        return collectionFlowLayout
    }()
    
    private enum Style: String, CaseIterable {
        case table
        case tile
        
        var buttonImage: UIImage {
            switch self {
            case .table: return #imageLiteral(resourceName: "line")
            case .tile: return #imageLiteral(resourceName: "tile")
            }
        }
    }
    private var selectedStyle: Style = .table {
        didSet { updateStyle() }
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getInfo()
        updateStyle()
    }
    
    // MARK: - Override methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.detailSegueIdentifier,
              let detailedVC = segue.destination as? DetailViewController,
              let indexPath = galleryCollection.indexPathsForSelectedItems?.first
        else { return }
        detailedVC.photoId = photos[indexPath.row].id
    }
    
    //MARK: - Actions
    
    @IBAction func changeLayout(_ sender: Any) {
        let allStyles = Style.allCases
        guard let index = allStyles.firstIndex(of: selectedStyle) else { return }
        let nextIndex = (index + 1) % allStyles.count
        selectedStyle = allStyles[nextIndex]
        if galleryCollection.collectionViewLayout == tileLayout {
            galleryCollection.setCollectionViewLayout(listLayout, animated: true)
        } else {
            galleryCollection.setCollectionViewLayout(tileLayout, animated: true)
        }
        galleryCollection.reloadData()
    }
    
    @IBAction func tagSearch(_ segue: UIStoryboardSegue) {
        if segue.identifier == Constants.tagSegueIdentifier {
            guard let detailedControl = segue.source as? DetailViewController,
                  let indexPath = detailedControl.tagsCollection.indexPathsForSelectedItems?.first
            else { return }
            let string = detailedControl.tags[indexPath.row].name
            searchBar.text = string
            search(string)
        }
    }
}

// MARK: - UICollectionViewDelgate, UICollectionViewDataSource

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId,
                                                            for: indexPath) as? GalleryCell
        else { return UICollectionViewCell() }
        cell.photoImage.kf.setImage(with: URL(string: photos[indexPath.row].url))
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            search(searchText)
        } else {
            getInfo()
        }
    }
}

// MARK: - Private methods

private extension MainViewController {
    
    func getInfo() {
        networkService.loadPhotos() { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                switch result {
                case .failure(let error):
                    self.alert(title: Constants.errorTitle,
                               message: error.localizedDescription,
                               style: .alert)
                    self.loadFromRealm()
                case .success(let array):
                    self.photos = array
                    RealmProvider.save(items: array, config: self.config)
                }
                self.galleryCollection.reloadData()
            }
        }
    }
    
    func loadFromRealm() {
        do {
            try photos = Array(RealmProvider.load(type: Photo.self, config: self.config))
        } catch  {
            print(error.localizedDescription)
        }
        self.galleryCollection.reloadData()
    }
    
    func search(_ string: String) {
        networkService.searchPhotos(byString: string) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.alert(title: Constants.errorTitle,
                               message: error.localizedDescription,
                               style: .alert)
                case .success(let array):
                    self.photos = array
                }
                self.galleryCollection.reloadData()
            }
        }
    }
    func updateStyle() {
        changePresentButton.image = selectedStyle.buttonImage
    }
}

// MARK: - Setup

private extension MainViewController {
    func setupView() {
        setupGalleryCollection()
        setupChangePresentButton()
        setupSearchBar()
    }
}

// MARK: - Setups Views

private extension MainViewController {
    
    func setupGalleryCollection() {
        galleryCollection.dataSource = self
        galleryCollection.delegate = self
        galleryCollection.collectionViewLayout = tileLayout
    }
    
    func setupChangePresentButton() {
        changePresentButton.tintColor = .black
        
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
}

// MARK: - Constants

private extension MainViewController {
    enum Constants {
        static let cellId: String = "Cell"
        static let collectionFlowLayoutMinimumInteritemSpacing: CGFloat = 0
        static let collectionFlowLayoutMinimumLineSpacing: CGFloat = 10
        static let itemsInRow: CGFloat = 2
        static let detailSegueIdentifier: String = "showDetails"
        static let tagSegueIdentifier: String = "tagSearch"
        static let errorTitle: String = "Error"
    }
}
