import Foundation
import PromiseKit

class RemoteData {
    
    enum FlickrMethod: String {
        case getRecent = "flickr.photos.getRecent"
        case getPopular = "flickr.photos.getPopular"
        case search = "flickr.photos.search"
    }
    
    private static let apiKey = "02e944b562f4779e04132e9007f789f3"
    
    private static func url(for method: FlickrMethod, params: [String: String] = [:]) -> URL? {
        var defaultParams = [
            "api_key": apiKey,
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "sort": "relevance"
        ]
        for (key, value) in params {
            defaultParams[key] = value
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = defaultParams.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
    
    private static func urlRequest(for method: FlickrMethod, params: [String: String] = [:]) throws -> URLRequest {
        guard let url = url(for: method, params: params) else {
            throw "Invalid URL"
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    static func photoUrl(for photo: Photo) -> String {
        return "https://farm\(photo.farmId).staticflickr.com/\(photo.serverId)/\(photo.id)_\(photo.secret).jpg"
    }
    
    static func getRecentPhotos() -> Promise<PhotosResponse> {
        return firstly {
            URLSession.shared.dataTask(.promise, with: try urlRequest(for: .getRecent))
                .validate()
            }.map {
                try JSONDecoder().decode(PhotosResponse.self, from: $0.data)
        }
    }
    
    static func getPopularPhotos() -> Promise<PhotosResponse> {
        return firstly {
            URLSession.shared.dataTask(.promise, with: try urlRequest(for: .getPopular))
                .validate()
            }.map {
                print(String(data: $0.data, encoding: .utf8))
                return try JSONDecoder().decode(PhotosResponse.self, from: $0.data)
        }
    }
    
    static func searchPhotos(text: String) -> Promise<PhotosResponse> {
        return firstly {
            URLSession.shared.dataTask(.promise, with: try urlRequest(for: .search,
                                                                      params: ["text": text]))
                .validate()
            }.map {
                print(String(data: $0.data, encoding: .utf8))
                return try JSONDecoder().decode(PhotosResponse.self, from: $0.data)
        }
    }
    
}
