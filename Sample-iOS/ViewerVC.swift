//
//  ViewerVC.swift
//  Sample-iOS
//
//  Created by Yannick Heinrich on 04.09.18.
//  Copyright © 2018 Yannick Heinrich. All rights reserved.
//

import UIKit
import Grade

private let reuseIdentifier = "SampleCell"

final class GradientView: UIView {
    private var colors = [UIColor.white.cgColor, UIColor.white.cgColor]

    var startColor: CGColor {
        set {
            colors[0] = newValue
        }
        get {
            return colors[0]
        }
    }

    var endColor: CGColor {
        set {
            colors[1] = newValue
        }
        get {
            return colors[1]
        }
    }

    private lazy var gradient: CGGradient = {
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)
        return gradient!
    }()

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.drawLinearGradient(gradient, start: CGPoint(x: rect.midX, y: rect.minY), end: CGPoint(x: rect.midX, y: rect.maxY), options: [])
    }
}

final class SampleCell: UICollectionViewCell {
    @IBOutlet weak var baseImageView: UIImageView!

    var colors: (UIColor, UIColor)?
}

final class ViewerVC: UICollectionViewController {

    private let imagesNames = ["up", "wall-e", "inside-out", "finding-dory", "drive", "true-detective", "stanger-things"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SampleCell

        let image = UIImage(named: imagesNames[indexPath.row])!
        cell.baseImageView.image = image
        
        var colors: (UIColor, UIColor)! = cell.colors

        if colors == nil {
            colors = GradeColors(forImage: image)
        }

        var background: GradientView! = cell.backgroundView as? GradientView
        if background == nil {
            let view = GradientView(frame: .zero)
            background = view
            cell.backgroundView = background
        }

        background.startColor = colors.0.cgColor
        background.endColor = colors.1.cgColor


        return cell
    }

}
