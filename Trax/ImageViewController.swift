//
//  ImageViewController.swift
//  Cassini
//
//  Created by Junor on 16/3/15.
//  Copyright © 2016年 Junor. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    
    // load image frome the url
    var imageURL: NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()   // user leave the app
            }
        }
    }
    
    // multithreading
    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()  // it will be break, if hasn't the question mark
            let wula = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(wula, 0)) { () -> Void in
                let imageData = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if url == self.imageURL {  // time consuming, so it's better to check wheather it's the last load url
                        if imageData != nil {
                            self.image = UIImage(data: imageData!)
                        } else {
                            self.image = nil
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.2
            scrollView.maximumZoomScale = 2.0
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // set the private stuff
    private var imageView = UIImageView()
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size   // the scrollView here maybe nil
            spinner?.stopAnimating()   // it will be break, if hasn't the question mark
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    // if the user left the app, the come back then set everything
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
}


// MARK: - UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
