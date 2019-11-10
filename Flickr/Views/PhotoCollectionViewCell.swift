//
//  PhotoCollectionViewCell.swift
//  Flickr
//
//  Created by Chris Xu on 11/10/19.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell, Reusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private methods
    
    private func setUp() {
        backgroundColor = .lightGray
        layer.cornerRadius = 20
    }
}
