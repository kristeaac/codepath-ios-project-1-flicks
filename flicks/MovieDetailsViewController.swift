import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    var posterImage: UIImage!
    var movieTitle: String!
    var movieDescription: String!
    var movieId: Int!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        TheMovieDBHelper.getMovieDetails(id: movieId, callback: populateMovieDetails)
        posterImageView.image = posterImage
        titleLabel.text = movieTitle
        descriptionLabel.text = movieDescription
        descriptionLabel.sizeToFit()
    }
    
    func populateMovieDetails(details: NSDictionary) {
        let runtime = details.object(forKey: "runtime") as! Int
        runtimeLabel.text = "\(runtime) min"
        let releaseDate = details.object(forKey: "release_date") as! String
        releaseDateLabel.text = releaseDate
    }

}
