//
//  VideoManager.swift
//  ApiPlayer
//
//  Created by Александр Гусев on 29.01.2023.
//

import Foundation

enum Query: String, CaseIterable {
    case nature, people, animals, ocean, food
}

class VideoManager : ObservableObject {
    @Published private(set) var videos: [Video] = []
    @Published var selectedQuery: Query = Query.nature {
        didSet{
            Task.init{
                await findVideos(topic: selectedQuery)
            }
        }
    }
    
    init(){
        Task.init{
            await findVideos(topic: selectedQuery)
        }
    }
    
    func findVideos(topic: Query) async {
        do{
            guard let url = URL(string: "https://api.pexels.com/videos/search?query=\(topic)&per_page=10&orientation=portrait") else
            { fatalError("fatal error") }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("RfEkQNKAyGRkHfN1lW9haXaOdICRDqd11j0vERtHt0o9OiSSmJqpEoeT", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("BadRequest")}
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(ResponseBody.self, from: data)
            
            self.videos = []
            self.videos = decodedData.videos
        } catch{
            print("Error \(error)")
        }
    }
}

struct ResponseBody : Decodable {
    var page: Int
    var perPage: Int
    var totalResults: Int
    var url: String
    var videos: [Video]
}
