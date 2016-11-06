import Foundation

class TheMovieDBHelper {
    
    static func getNowPlaying(page: Int, callback: @escaping ([NSDictionary]?, Int, Int, Int) -> Void, failureCallback: @escaping () -> Void) {
        getMovieList(endpoint: "now_playing", page: page, callback: callback, failureCallback: failureCallback)
    }
    
    static func getTopRated(page: Int, callback: @escaping ([NSDictionary]?, Int, Int, Int) -> Void, failureCallback: @escaping () -> Void) {
        getMovieList(endpoint: "top_rated", page: page, callback: callback, failureCallback: failureCallback)
    }
    
    static func getMovieList(endpoint: String, page: Int, callback: @escaping ([NSDictionary]?, Int, Int, Int) -> Void, failureCallback: @escaping () -> Void) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&page=\(page)")
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
                failureCallback()
            }
            
        });
        task.resume()
    }
    
    static func getMovieDetails(id: Int, callback: @escaping (NSDictionary) -> Void) {
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(id)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    callback(responseDictionary)
                }
            } else {
                NSLog("uh oh")
            }
            
        });
        task.resume()
    }
    
}
