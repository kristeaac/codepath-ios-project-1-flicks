import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    var moviePosterImageView: UIImageView!
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 10
        contentView.addSubview(titleLabel)
        
        moviePosterImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        moviePosterImageView.contentMode = UIViewContentMode.scaleAspectFit
        contentView.addSubview(moviePosterImageView)        
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
