import UIKit
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]()
    var page = 1
    var totalPages: Int!
    var totalResults: Int!
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    let refreshControl = UIRefreshControl()
    var networkErrorView: UIView!
    
    
    @IBOutlet var mainView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TheMovieDBHelper.getNowPlaying(page: page, callback: initialMovieListLoad, failureCallback: showNetworkError)
        initializeInfiniteScroll()
        initializeRefreshControl()
        initializeNetworkErrorView()
    }
    
    func initializeNetworkErrorView() {
        let y = (self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)!
        let frame = CGRect(origin: CGPoint(x: 0, y : y), size: CGSize(width: tableView.bounds.size.width, height: 50))
        networkErrorView = UIView(frame: frame)
        networkErrorView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.65)
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: tableView.bounds.size.width, height: 50)))
        label.text = "Network Error"
        label.textAlignment = .center
        label.textColor = UIColor.white
        networkErrorView.addSubview(label)
        networkErrorView.sizeToFit()
        addBottomBorderWithColor(view: networkErrorView, color: UIColor.black, width: 2)
        networkErrorView.isHidden = true
        mainView.addSubview(networkErrorView)
    }
    
    func initialMovieListLoad(movies: [NSDictionary]?, page: Int, totalPages: Int, totalResults: Int) {
        MBProgressHUD.hide(for: self.view, animated: true)
        handleMovieList(movies: movies, page: page, totalPages: totalPages, totalResults: totalResults)
    }
    
    func handleMovieList(movies: [NSDictionary]?, page: Int, totalPages: Int, totalResults: Int) {
        self.isMoreDataLoading = false
        self.loadingMoreView!.stopAnimating()
        self.refreshControl.endRefreshing()
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
    
    func showNetworkError() {
        MBProgressHUD.hide(for: self.view, animated: true)
        networkErrorView.isHidden = false
        self.isMoreDataLoading = false
        self.loadingMoreView!.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    func addBottomBorderWithColor(view: UIView, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0, y : view.frame.size.height), size: CGSize(width: view.frame.width, height: width))
        view.layer.addSublayer(border)
    }
    
    func initializeRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(refreshFeed), for: UIControlEvents.valueChanged)
        tableView.insertSubview(self.refreshControl, at: movies.count)
    }
    
    func refreshFeed() {
        movies = [NSDictionary]()
        tableView.reloadData()
        networkErrorView.isHidden = true
        TheMovieDBHelper.getNowPlaying(page: 1, callback: handleMovieList, failureCallback: showNetworkError)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == movies.count - 1) {
            loadMoreMovies()
        }
        return populateCellWithMovieDetails(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadMoreMovies() {
        if (!isMoreDataLoading) {
            isMoreDataLoading = true
            animateLoadingIndicator()
            networkErrorView.isHidden = true
            TheMovieDBHelper.getNowPlaying(page: page + 1, callback: handleMovieList, failureCallback: showNetworkError)
        }
    }
    
    func animateLoadingIndicator() {
        let frame = CGRect(origin: CGPoint(x: 0,y :tableView.contentSize.height), size: CGSize(width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight))
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
    }
    
    func populateCellWithMovieDetails(indexPath: IndexPath) -> UITableViewCell {
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
                view.alpha = 0.0
                let image = UIImage(data: data!)
                view.image = image
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    view.alpha = 1.0
                })
            })
            
        }).resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! MovieDetailsViewController
        destinationViewController.posterImage = (sender! as! MovieCell).movieImageView.image
        destinationViewController.movieTitle = (sender! as! MovieCell).titleLabel.text
        destinationViewController.movieDescription = (sender! as! MovieCell).descriptionLabel.text
        let indexPath = tableView.indexPath(for: (sender! as! UITableViewCell))
        let movieId = movies[(indexPath?.row)!].object(forKey: "id") as! Int
        destinationViewController.movieId = movieId
    }

}
