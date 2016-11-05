import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]()
    var page = 1
    var totalPages: Int!
    var totalResults: Int!
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?

    override func viewDidLoad() {
        super.viewDidLoad()
        TheMovieDBHelper.getNowPlaying(page: page, callback: handleMovieList)
        initializeInfiniteScroll()
    }
    
    func handleMovieList(movies: [NSDictionary]?, page: Int, totalPages: Int, totalResults: Int) {
        self.isMoreDataLoading = false
        self.loadingMoreView!.stopAnimating()
        self.movies.append(contentsOf: movies!)
        tableView.reloadData()
    }

    func initializeInfiniteScroll() {
        let frame = CGRect(origin: CGPoint(x: 0,y :tableView.contentSize.height), size: CGSize(width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight))
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == movies.count - 1) {
            loadMoreMovies()
        }
        return populateCellWithMoveDetails(indexPath: indexPath)
    }
    
    func loadMoreMovies() {
        if (!isMoreDataLoading) {
            isMoreDataLoading = true
            animateLoadingIndicator()
            TheMovieDBHelper.getNowPlaying(page: page + 1, callback: handleMovieList)
        }
    }
    
    func animateLoadingIndicator() {
        let frame = CGRect(origin: CGPoint(x: 0,y :tableView.contentSize.height), size: CGSize(width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight))
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
    }
    
    func populateCellWithMoveDetails(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        let title = movie.object(forKey: "title") as! String
        let description = movie.object(forKey: "overview") as! String
        let posterPath = movie.object(forKey: "poster_path") as? String
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description
        if (posterPath == nil) {
            cell.movieImageView.image = nil
        } else {
            loadImageFromUrl(url: "https://image.tmdb.org/t/p/w342\(posterPath!)", view: cell.movieImageView)
        }
        return cell
    }
    
    func loadImageFromUrl(url: String, view: UIImageView){
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                view.image = image
            })
            
        }).resume()
    }

}
