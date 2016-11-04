//
//  TheMovieDBHelper.swift
//  flicks
//
//  Created by Kristy Caster on 11/4/16.
//  Copyright © 2016 kristeaac. All rights reserved.
//

import Foundation

class TheMovieDBHelper {
    
    static func getNowPlaying(callback: @escaping ([NSDictionary]?, Int, Int, Int) -> Void) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    let r = responseDictionary.object(forKey: "results") as! [NSDictionary]
                    let page = responseDictionary.object(forKey: "page") as! Int
                    let totalPages = responseDictionary.object(forKey: "total_pages") as! Int
                    let totalResults = responseDictionary.object(forKey: "total_results") as! Int
                    callback(r, page, totalPages, totalResults)
                }
            } else {
                NSLog("uh oh")
            }

        });
        task.resume()
    }
    
}
