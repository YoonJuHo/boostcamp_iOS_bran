//
//  BoostCampAPI.swift
//  ImageBoard
//
//  Created by JU HO YOON on 2017. 7. 29..
//  Copyright © 2017년 YJH Studio. All rights reserved.
//

import Foundation

enum UserResult {
    case success(User)
    case failure(UserError)
}

enum UserError: Error {
    case emailOverlaped
    case userJSONSerializationFail
    case userInitializationFail
}

enum ArticleResult {
    case success([Article])
    case failure(ArticleError)
}

enum ArticleError: Error {
    case articleJSONSerializationFail
    case articleInitializationFail
}

class BoostCampAPI {
    
    private struct RequestHeader {
        struct Field {
            static let contentType = "Content-Type"
        }
        
        struct Value {
            static let json = "application/json"
            static let formData = "multipart/form-data"
        }
    }
    
    private struct RequestMethod {
        static let get = "GET"
        static let post = "POST"
        static let put = "PUT"
        static let delete = "DELETE"
    }
    
    struct urlPath {
        static let baseURL = "https://ios-api.boostcamp.connect.or.kr"
        static let login = urlPath.baseURL + "/login"
        static let user = urlPath.baseURL + "/user"
        static let image = urlPath.baseURL + "/image"
    }
    
    static let shared = BoostCampAPI()
    
    // MARK: All Article
    // Get all articles.
    // if requesting server and creating article object fail, completion argument is nil.
    func allBoard(completionBlock completion: @escaping (_ articleResult: ArticleResult) -> Void) {
        let session = URLSession.shared
        
        guard let url = URL(string: urlPath.baseURL) else {
            return completion(.failure(.articleJSONSerializationFail))
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            self.logResponse(response: response)
            
            guard let jsonData = data,
                let jsonArticles = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]],
                let articles = jsonArticles
            else {
                return completion(.failure(.articleJSONSerializationFail))
            }
            
            var resultArticles: [Article] = []
            
            for article in articles {
                guard let newArticle = Article(jsonData: article) else { continue }
                resultArticles.append(newArticle)
            }
            
            if resultArticles.count > 0 {
                completion(.success(resultArticles))
            } else {
                completion(.failure(.articleJSONSerializationFail))
            }
        }
        task.resume()
    }
    
    // MARK: User
    // Login with user object.
    // if requesting server and creating user object fail, completion argument is nil.
    func signIn(with user: User, completionBlock completion: @escaping (_ user: UserResult) -> ()){
        
        let session = URLSession.shared
        
        var jsonBody = [String: Any]()
        jsonBody[User.jsonKey.email] = user.email
        jsonBody[User.jsonKey.password] = user.password
        
        guard let body = try? JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions.prettyPrinted),
            let url = URL(string: urlPath.login)
        else {
            return completion(.failure(.userJSONSerializationFail))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.post
        request.httpBody = body
        request.addValue(RequestHeader.Value.json, forHTTPHeaderField: RequestHeader.Field.contentType)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.logResponse(response: response)
            
            guard let jsonData = data,
                let userJson = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any],
                let user = userJson
            else {
                return completion(.failure(.userJSONSerializationFail))
            }
            
            guard let resultUser = User(jsonData: user) else { return completion(.failure(UserError.userInitializationFail)) }
            completion(.success(resultUser))
        }
        task.resume()
        
    }
    
    // Sign up with user object.
    // if requesting server and creating user object fail, completion argument is nil.
    func signUp(with user: User, completionBlock completion: @escaping (_ user: UserResult) -> ()) {
        let session = URLSession.shared
        
        var jsonBody = [String: Any]()
        jsonBody[User.jsonKey.email] = user.email
        jsonBody[User.jsonKey.password] = user.password
        jsonBody[User.jsonKey.nickname] = user.nickname
        
        guard let body = try? JSONSerialization.data(withJSONObject: jsonBody, options: JSONSerialization.WritingOptions.prettyPrinted),
            let url = URL(string: urlPath.user)
        else {
            return completion(.failure(.userJSONSerializationFail))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.post
        request.httpBody = body
        request.addValue(RequestHeader.Value.json, forHTTPHeaderField: RequestHeader.Field.contentType)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.logResponse(response: response)
            
            if let urlResponse = response as? HTTPURLResponse {
                
                if urlResponse.statusCode == 406 {
                    return completion(.failure(UserError.emailOverlaped))
                }
            }
            
            guard let jsonData = data,
                let userJson = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any],
                let user = userJson
            else {
                return completion(.failure(.userJSONSerializationFail))
            }
            
            guard let resultUser = User(jsonData: user) else { return completion(.failure(UserError.userInitializationFail)) }
            completion(.success(resultUser))
        }
        task.resume()
    }
    
    // MARK: Article
    // Upload article.
    // if requesting server and creating article object fail, completion argument is nil.
    func postArticle(with article: Article, comopletionBlock completion: @escaping (_ articleResult: ArticleResult) -> ()) {
        
        guard let imageData = article.imageData else { return }
        let session = URLSession.shared
        
        var jsonBody = [String: Any]()
        jsonBody[Article.jsonKey.imageTitle] = article.imageTitle
        jsonBody[Article.jsonKey.imageDescription] = article.imageDescription
        jsonBody[Article.jsonKey.imageData] = imageData.base64EncodedString()
        
        guard let body = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted),
            let url = URL(string: urlPath.image)
            else {
                print("1fail")
                return completion(.failure(.articleJSONSerializationFail))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.post
        request.httpBody = body
        request.addValue(RequestHeader.Value.json, forHTTPHeaderField: RequestHeader.Field.contentType)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.logResponse(response: response)
            
            guard let jsonData = data,
                let articleJSON = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any],
                let article = articleJSON
            else {
                print("2fail2")
                return completion(.failure(.articleJSONSerializationFail))
            }
            
            guard let resultArticle = Article(jsonData: article) else { return completion(.failure(.articleInitializationFail)) }
            print("3fail")
            completion(.success([resultArticle]))
        }
        task.resume()
    }
    
    
    func updateArticle(with article: Article, comopletionBlock completion: @escaping (_ articleResult: ArticleResult) -> ()) {
        let session = URLSession.shared
        
        var jsonBody = [String: Any]()
        jsonBody[Article.jsonKey.imageTitle] = article.imageTitle
        jsonBody[Article.jsonKey.imageDescription] = article.imageDescription
        jsonBody[Article.jsonKey.imageData] = article.imageData
        
        guard let body = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted),
            let url = URL(string: urlPath.image.appending("/\(article.id)"))
            else {
                return completion(.failure(.articleJSONSerializationFail))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.post
        request.httpBody = body
        request.addValue(RequestHeader.Value.json, forHTTPHeaderField: RequestHeader.Field.contentType)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.logResponse(response: response)
            
            guard let jsonData = data,
                let articleJSON = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any],
                let article = articleJSON
                else {
                    return completion(.failure(.articleJSONSerializationFail))
            }
            
            guard let resultArticle = Article(jsonData: article) else { return completion(.failure(.articleInitializationFail)) }
            completion(.success([resultArticle]))
        }
        task.resume()
    }
    
    func deleteArticle(with article: Article, comopletionBlock completion: @escaping (_ articleResult: ArticleResult) -> ()) {
        let session = URLSession.shared
        
        guard let url = URL(string: urlPath.image.appending("/\(article.id)")) else { return completion(.failure(.articleJSONSerializationFail)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.delete
        
        let task = session.dataTask(with: request) { (data, response, error) in
            self.logResponse(response: response)
            
            guard let jsonData = data,
                let jsonArticles = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]],
                let article = jsonArticles?.first
                else {
                    return completion(.failure(.articleJSONSerializationFail))
            }

            guard let resultArticle = Article(jsonData: article) else { return completion(.failure(.articleInitializationFail)) }
            completion(.success([resultArticle]))
        }
        task.resume()
    }
    
    // Print Log.
    private func logResponse(response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse {
            print("response status : \(httpResponse.statusCode)")
        }
    }
}
