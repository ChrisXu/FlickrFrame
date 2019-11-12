import UIKit

class PhotoCollectionViewCell: UICollectionViewCell, Reusable {
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.accessibilityIdentifier = "PhotoCollectionViewCell.imageView"
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - Private methods
    
    private func setUp() {
        backgroundColor = UIColor(displayP3Red: 229 / 255, green: 229 / 255, blue: 234 / 255, alpha: 1) // systemGray5 in iOS13
        layer.cornerRadius = 20
        clipsToBounds = true
        
        addImageView()
    }
    
    private func addImageView() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
}
