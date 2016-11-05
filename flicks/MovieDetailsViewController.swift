import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    var posterImage: UIImage!
    var movieTitle: String!
    var movieDescription: String!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.image = posterImage
        titleLabel.text = movieTitle
        descriptionLabel.text = movieDescription
        descriptionLabel.sizeToFit()
    }

}
