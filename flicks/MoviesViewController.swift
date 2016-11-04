//
//  MoviesViewController.swift
//  flicks
//
//  Created by Kristy Caster on 11/4/16.
//  Copyright © 2016 kristeaac. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var movies = [NSDictionary]()
    var page: Int!
    var totalPages: Int!
    var totalResults: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        TheMovieDBHelper.getNowPlaying(callback: handleMovieList)
    }
    
    func handleMovieList(movies: [NSDictionary]?, page: Int, totalPages: Int, totalResults: Int) {
        self.movies = movies!
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                //print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                view.image = image
            })
            
        }).resume()
    }

}
