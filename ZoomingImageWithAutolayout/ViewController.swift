//
//  ViewController.swift
//  ZoomingImageWithAutolayout
//
//  Created by Dung Vu on 6/3/16.
//  Copyright © 2016 Zinio Pro. All rights reserved.
//

import UIKit

extension UIView {
    class func getConstraintItem(firstView: UIView, secondView: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        let list = [firstView, secondView]
        return firstView.constraints.filter({ (constraint) -> Bool in
            if list.contains({ return ($0 === constraint.firstItem || $0 === constraint.secondItem)}) && constraint.firstAttribute == attribute {
                return true
            } else {return false}
        }).first
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    lazy var trailing: NSLayoutConstraint? = {
       return UIView.getConstraintItem(self.scrollView,
                                       secondView: self.imageView,
                                       attribute: .Trailing)
    }()

    lazy var top: NSLayoutConstraint? = {
        return UIView.getConstraintItem(self.scrollView,
                                        secondView: self.imageView,
                                        attribute: .Top)
    }()

    lazy var bottom: NSLayoutConstraint? = {
        return UIView.getConstraintItem(self.scrollView,
                                        secondView: self.imageView,
                                        attribute: .Bottom)
    }()

    lazy var leading: NSLayoutConstraint? = {
        return UIView.getConstraintItem(self.scrollView,
                                        secondView: self.imageView,
                                        attribute: .Leading)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleZoomingGesture(_:)))
        tapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Set zoom at Rect
    func zoomRectForScale(scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero

        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale

        let newCenter = imageView.convertPoint(center, fromView: self.view)
        zoomRect.origin.x = newCenter.x - zoomRect.size.width / 2
        zoomRect.origin.y = newCenter.y - zoomRect.size.height / 2

        return zoomRect
    }

    func handleZoomingGesture(tapGesture: UITapGestureRecognizer) {
        let locationInView = tapGesture.locationInView(self.view)

        if scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            let zoomRect = self.zoomRectForScale(self.scrollView.maximumZoomScale, withCenter: locationInView)
            scrollView.zoomToRect(zoomRect, animated: true)
        }


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 4
        updateMinZoomScaleForSize(view.bounds.size)
    }

    // Helper
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        // 2
        scrollView.minimumZoomScale = minScale
        // 3
        scrollView.zoomScale = minScale

        scrollView.maximumZoomScale = 2
    }

    private func updateConstraintsForSize(size: CGSize) {
        // 2
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        top?.constant = yOffset
        bottom?.constant = yOffset
        // 3
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        leading?.constant = xOffset
        trailing?.constant = xOffset

        view.layoutIfNeeded()
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
