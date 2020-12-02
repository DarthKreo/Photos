//
//  DetailViewController.swift
//  Photos
//
//  Created by Владимир Кваша on 28.11.2020.
//

import UIKit
import RealmSwift
import Kingfisher

// MARK: - DetailViewController

final class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var likeCommStack: UIStackView!
    @IBOutlet weak var authorAvatarImage: UIImageView!
    @IBOutlet weak var photoNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var takenDateLabel: UILabel!
    @IBOutlet weak var uplDateLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var tagsCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public properties
    
    public var photoId = String()
    public var tags = [Tags]()
    
    //MARK: - Private properties
    
    private lazy var details = DetailedPhoto()
    private lazy var config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    private lazy var networkService = NetworkService()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        getTags()
    }
    
    //MARK: - Actions
    
    @objc
    func imageTapped(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        
        guard let img = imageView.image else { return }
        let newImageView = ImageZoomView(frame: UIScreen.main.bounds, image: img)
        
        newImageView.backgroundColor = .black
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissFullScreen(sender:)))
        newImageView.addGestureRecognizer(tap)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc
    func dismissFullScreen(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
}

//MARK: - Private methods

private extension DetailViewController {
    
    func getInfo() {
        activityIndicator.startAnimating()
        networkService.loadDetails(id: photoId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.alert(title: Constants.alertTitle,
                               message: error.localizedDescription,
                               style: .alert)
                    do {
                        try self.details = Array(RealmProvider.load(type: DetailedPhoto.self,
                                                                    config: self.config)).first ?? DetailedPhoto()
                    } catch  {
                        print(error.localizedDescription)
                    }
                case .success(let detail):
                    self.details = detail
                    RealmProvider.saveObject(item: detail, config: self.config)
                    RealmProvider.addProperties(details: detail, to: self.photoId)
                }
                self.activityIndicator.stopAnimating()
                self.setupView()
            }
        }
    }
    
    func getTags() {
        networkService.loadTags(id: photoId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.alert(title: Constants.alertTitle,
                               message: error.localizedDescription,
                               style: .alert)
                    self.tags = Array(self.details.tags)
                case .success(let tags):
                    self.tags = tags
                    self.tagsCollection.reloadData()
                    RealmProvider.save(items: tags, config: self.config)
                    RealmProvider.addTags(tags: tags, to: self.details)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                                            for: indexPath) as? TagsCell
        else { return UICollectionViewCell() }
        cell.layer.borderWidth = Constants.cellBorderWidth
        cell.layer.cornerRadius = Constants.cellCornerRadius
        cell.tagNameLabel.text = tags[indexPath.item].name
        return cell
    }
}

// MARK: - Setup

private extension DetailViewController {
    
    func setupView() {
        setupMainImage()
        setupAuthorAvatarImage()
        setupPhotoNameLabel()
        setupAuthorNameLabel()
        setupTakenDateLabel()
        setupUplDateLabel()
        setupLikesLabel()
        setupModelLabel()
        setupActivityIndicator()
        setupTagsCollection()
    }
    
}

// MARK: - Setups Views

private extension DetailViewController {
    
    func setupMainImage() {
        mainImage.kf.setImage(with: URL(string: details.url))
        mainImage.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(imageTapped(sender:))))
    }
    
    func setupAuthorAvatarImage() {
        authorAvatarImage.kf.setImage(with: URL(string: details.byAvatar))
        authorAvatarImage.layer.cornerRadius = Constants.authorAvatarImageCornerRadius
    }
    
    func setupPhotoNameLabel() {
        if details.descr.isEmpty {
            photoNameLabel.text = Constants.photoNameLabelEmptyText
        } else {
                photoNameLabel.text = details.descr.capitalizingFirst()
            }
    }
    
    func setupAuthorNameLabel() {
        if details.authorName.isEmpty {
            authorNameLabel.text = Constants.authorNameLabelEmptyText
        } else {
            let text = details.authorName.lowercased()
            authorNameLabel.text = Constants.authorNameLabelText + text.capitalized
        }
    }
    
    func setupTakenDateLabel() {
        takenDateLabel.text = Functions.convertDateFormat(inputDate: details.creationDate)
    }
    
    func setupUplDateLabel() {
        uplDateLabel.text = Functions.convertDateFormat(inputDate: details.uploadDate)
    }
    
    func setupLikesLabel() {
        likesLabel.text = String(details.likes) + Constants.likesLabelText
    }
    
    func setupModelLabel() {
        if details.deviceModel.isEmpty {
            modelLabel.addImage(image: Constants.modelLabelImage,
                                text: Constants.modelLabelEmptyText)
        } else {
            modelLabel.addImage(image: Constants.modelLabelImage,
                                text: details.deviceModel)
        }
    }
    
    func setupTagsCollection() {
        tagsCollection.delegate = self
        tagsCollection.dataSource = self
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
}

// MARK: - Constants

private extension DetailViewController {
    
    enum Constants {
        static let authorNameLabelText: String = "by "
        static let likesLabelText: String = " people liked this photo"
        static let alertTitle: String = "Error"
        static let reuseIdentifier: String = "TagCell"
        static let cellBorderWidth: CGFloat = 1.0
        static let cellCornerRadius: CGFloat = 8
        static let authorAvatarImageCornerRadius: CGFloat = 35
        static let photoNameLabelEmptyText: String = "Unnamed"
        static let authorNameLabelEmptyText: String = "Unknown"
        static let modelLabelImage: String = "photocam"
        static let modelLabelEmptyText: String = "No info"
    }
}
