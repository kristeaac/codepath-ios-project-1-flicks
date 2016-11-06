import UIKit
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var collectionView: UICollectionView!
    var movies = [NSDictionary]()
    var filteredMovies = [NSDictionary]()
    var page = 1
    var totalPages: Int!
    var totalResults: Int!
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    let refreshControl = UIRefreshControl()
    var networkErrorView: UIView!
    let searchBar = UISearchBar()
    var searchActive = false
    var endpoint: String!
    
    
    @IBOutlet var mainView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCollectionView()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        TheMovieDBHelper.getMovieList(endpoint: endpoint, page: page, callback: initialMovieListLoad, failureCallback: showNetworkError)
        initializeInfiniteScroll()
        initializeRefreshControl()
        initializeNetworkErrorView()
        initializeSearchBar()
    }
    
    func initializeRefreshControl() {
        refreshControl.backgroundColor = UIColor.black
        refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(refreshFeed), for: UIControlEvents.valueChanged)
        tableView.insertSubview(self.refreshControl, at: movies.count)
    }
    
    func initializeCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        collectionView = UICollectionView(frame: tableView.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCollectionCell")
        collectionView.backgroundColor = UIColor.black
        collectionView.isHidden = true
        self.view.addSubview(collectionView)
    }
    
    func initializeSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
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
        collectionView.reloadData()
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
    
    func refreshFeed() {
        movies = [NSDictionary]()
        tableView.reloadData()
        collectionView.reloadData()
        networkErrorView.isHidden = true
        TheMovieDBHelper.getMovieList(endpoint: endpoint, page: 1, callback: handleMovieList, failureCallback: showNetworkError)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchActive ? filteredMovies.count : movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchActive ? filteredMovies.count : movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == movies.count - 1) {
            loadMoreMovies()
        }
        return populateTableViewCellWithMovieDetails(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == movies.count - 1) {
            loadMoreMovies()
        }
        return populateCollectionViewCellWithMovieDetails(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "movieCollectionViewSegue", sender: collectionView.cellForItem(at: indexPath))
    }
    
    func loadMoreMovies() {
        if (!isMoreDataLoading) {
            isMoreDataLoading = true
            animateLoadingIndicator()
            networkErrorView.isHidden = true
            TheMovieDBHelper.getMovieList(endpoint: endpoint, page: page + 1, callback: handleMovieList, failureCallback: showNetworkError)
        }
    }
    
    func animateLoadingIndicator() {
        let frame = CGRect(origin: CGPoint(x: 0,y :tableView.contentSize.height), size: CGSize(width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight))
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
    }
    
    func populateTableViewCellWithMovieDetails(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = searchActive ? filteredMovies[indexPath.row] : movies[indexPath.row]
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
    
    func populateCollectionViewCellWithMovieDetails(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionViewCell
        let movie = searchActive ? filteredMovies[indexPath.row] : movies[indexPath.row]
        let posterPath = movie.object(forKey: "poster_path") as? String
        let title = movie.object(forKey: "title") as! String
        cell.titleLabel.text = title
        if (posterPath == nil) {
            cell.moviePosterImageView.image = nil
        } else {
            loadImageFromUrl(url: "https://image.tmdb.org/t/p/w342\(posterPath!)", view: cell.moviePosterImageView)
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
        let identifier = segue.identifier!
        var posterImage: UIImage!
        var movieTitle: String!
        var movieDescription: String!
        var index: Int!
        var movie: NSDictionary!
        
        if (identifier == "movieTableViewSegue") {
            let cell = sender as! MovieCell
            posterImage = cell.movieImageView.image
            movieTitle = cell.titleLabel.text
            movieDescription = cell.descriptionLabel.text
            let indexPath = tableView.indexPath(for: cell)
            index = indexPath?.row
            movie = searchActive ? filteredMovies[index] : movies[index]
        } else {
            let cell = sender as! MovieCollectionViewCell
            posterImage = cell.moviePosterImageView.image
            movieTitle = cell.titleLabel.text
            let indexPath = collectionView.indexPath(for: cell)
            index = indexPath?.row
            movie = searchActive ? filteredMovies[index] : movies[index]
            movieDescription = movie.object(forKey: "overview") as! String
        }
        
        let destinationViewController = segue.destination as! MovieDetailsViewController
        destinationViewController.posterImage = posterImage
        destinationViewController.movieTitle = movieTitle
        destinationViewController.movieDescription = movieDescription
        let movieId = movie.object(forKey: "id") as! Int
        destinationViewController.movieId = movieId
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = movies.filter({ (movie) -> Bool in
            let title = movie.object(forKey: "title") as! NSString
            let tmp: NSString = title
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if (filteredMovies.count == 0) {
            searchActive = false;
        } else {
            searchActive = true;
        }
        tableView.reloadData()
        collectionView.reloadData()
    }

    @IBAction func onViewChange(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            tableView.isHidden = false
            collectionView.isHidden = true
        } else {
            tableView.isHidden = true
            collectionView.isHidden = false
        }
    }
}
