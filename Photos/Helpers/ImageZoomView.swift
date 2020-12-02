//
//  ImageZoomView.swift
//  Photos
//
//  Created by Владимир Кваша on 30.11.2020.
//

import UIKit

// MARK: - ImageZoomView

final class ImageZoomView: UIScrollView {
    
    // MARK: - Private properties
    
    private lazy var imageView = UIImageView()
    private lazy var gestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Init
    
    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        imageView.image = image
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        setupScrollView()
        setupGestureRecognizer()
        addSubview(imageView)
    }
    
    //MARK: - Private methods
    
    private func setupGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTouchesRequired = Constants.gestureRecognizerNumberOfTouchesRequired
        addGestureRecognizer(gestureRecognizer)
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - zoomRect.size.width / Constants.zoomRectSize
        zoomRect.origin.y = newCenter.y - zoomRect.size.height / Constants.zoomRectSize
        return zoomRect
    }
    
    @objc
    private func handleDoubleTap() {
        if zoomScale == Constants.zoomScale {
            zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
        } else {
            setZoomScale(Constants.zoomScale, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ImageZoomView: UIScrollViewDelegate {
    
    func setupScrollView() {
        minimumZoomScale = Constants.minimumZoomScale
        maximumZoomScale = Constants.maximumZoomScale
        delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Constants

private extension ImageZoomView {
    
    enum Constants {
        static let gestureRecognizerNumberOfTouchesRequired: Int = 2
        static let zoomRectSize: CGFloat = 2.0
        static let zoomScale: CGFloat = 1
        static let minimumZoomScale: CGFloat = 1.0
        static let maximumZoomScale: CGFloat = 2.0
    }
}
