//
//  Api.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-21.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation

fileprivate struct Path {
    static let domain = URL(string: "http://127.0.0.1/rappucino")
    static let login = domain?.appendingPathComponent("login").appendingPathExtension("php")
    static let register = domain?.appendingPathComponent("register").appendingPathExtension("php")
    static let upload = domain?.appendingPathComponent("upload_recording").appendingPathExtension("php")
    static let create_squad = domain?.appendingPathComponent("create_squad").appendingPathExtension("php")
    static let get_squads = domain?.appendingPathComponent("get_squads").appendingPathExtension("php")
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let home_dir = documentsDirectory.appendingPathComponent("finishedfiles")
}

class Api: NSObject, URLSessionDelegate {
    
    static let shared = Api()
    
    private func dataTask(_ request: URLRequest, completion: @escaping (_ object: AnyObject?) -> Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    if json != nil {
                        completion(json as AnyObject?)
                    } else {
                        completion(data as AnyObject?)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
            
        }.resume()
        
    }
    
    private func createGetRequest(path: URL, json: String?) -> URLRequest {
        
        var request: URLRequest!
        
        if let json = json?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            request = URLRequest(url: URL(string: "\(path.absoluteString)?\(json)")!)
            
        } else {
            
            request = URLRequest(url: path)
            
        }
        
        request.httpMethod = "GET"
        
        return request
        
    }
    
    private func createPostRequest(path: URL, json: String?) -> URLRequest {
        
        var request: URLRequest!
        
        request = URLRequest(url: path)
        
        if let json = json as? String {
            request.httpBody = json.data(using: .utf8)
        }
        
        request.httpMethod = "POST"
        
        return request
        
    }
    
    func login(handle: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        
        if let url = Path.login {
            
            let json = "handle=\(handle)&password=\(password)"
            
            let request = createPostRequest(path: url, json: json)
            
            dataTask(request) {
                object in
                
                if let obj = object as? [String: AnyObject] {
                    if let success = obj["success"] as? Bool {
                        if success {
                            if let rapper_id = obj["rapper_id"] as? String {
                                UserDefaults.standard.setValue(rapper_id, forKey: "rapper_id")
                                completion(true)
                            } else {
                                completion(false)
                            }
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
                
            }
            
        } else {
            completion(false)
        }
        
    }
    
    func register(name: String, handle: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        
        if let url = Path.register {
            
            let json = "name=\(name)&handle=\(handle)&password=\(password)"
            
            let request = createPostRequest(path: url, json: json)
            
            dataTask(request) {
                object in
                
                if let obj = object as? [String: AnyObject] {
                    if let success = obj["success"] as? Bool {
                        if success {
                            if let rapper_id = obj["rapper_id"] as? String {
                                UserDefaults.standard.setValue(rapper_id, forKey: "rapper_id")
                                completion(true)
                            } else {
                                completion(false)
                            }
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
                
            }
            
        } else {
            completion(false)
        }
        
    }
    
    func upload_recording(fileURL: URL) {
        
        if let url = Path.upload {
            
            let request = NSMutableURLRequest(url: url as URL)
            
            request.httpMethod = "POST"
            
            let parameters : [String: Any] = [
                "from_rapper_id" : "lgeefs96",
                "to_rapper_id" : "jimmyjurner",
                "to_squad_id" : "wobblypops"
            ]
            
            let boundary = generateBoundaryString()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let filename = fileURL.deletingPathExtension().lastPathComponent + ".m4a"
            let mimetype = "audio/mp4"
            
            var audioData: Data?
            
            do {
                try audioData = Data(contentsOf: fileURL)
            } catch let error {
                print(error)
            }
            
            if audioData != nil {
                
                let body = NSMutableData()
                
                // All of the weird code like "\r\n" is required to format file data for http request
                
                //a set of data (parameters) is sent in-between each boundary
                
                if parameters.count > 0 {
                    for (key, value) in parameters {
                        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                        body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
                    }
                }
                
                body.append("--\(boundary)\r\n".data(using:String.Encoding.utf8)!)
                
                body.append("Content-Disposition:form-data; name=\"audioFile\"; filename=\"\(filename)\"\r\n".data(using:String.Encoding.utf8)!)
                
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                
                body.append(audioData!)
                
                body.append("\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("--\(boundary)--\r\n".data(using:String.Encoding.utf8)!)
                
                request.httpBody = body as Data
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                    (data, response, error) -> Void in
                    
                    if error != nil {
                        
                        print(error ?? "Error")
                        return
                        
                    }
                    
                    do {
                        
                        let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        print(object)
                        
                    } catch let error {
                        
                        print(error)
                        
                    }
                    
                }
                
                task.resume()
                
            }
            
        }
        
    }
    
    func create_squad(squad: Squad, completion: @escaping (_ success: Bool) -> Void) {
        
        if let url = Path.create_squad {
            
            /*let json = [
                "name=\(squad.getName())&rappers=\(squad.getRappers())&picture_url=\(squad.getPictureURL()?.absoluteString ?? "")"
            
            let request = createPostRequest(path: url, json: json)
            
            dataTask(request) {
                object in
                
                print(object)
                
            }*/
            
        }
        
    }
    
    func get_squads(rapper_id: String, completion: @escaping (_ squads: [Squad]?) -> Void) {
        
        if let url = Path.get_squads {
            
            let request = createGetRequest(path: url, json: "rapper_id=\(rapper_id)")
            
            dataTask(request) {
                object in
                
                //print(object)
                
                if object != nil {
                    
                    if let obj = object! as? [[String: Any]] {
                        
                        var squads = [Squad]()
                        
                        for o in obj {
                            
                            var rappers = [Rapper]()
                            
                            for r in (o["rappers"] as? [[String: Any]])! {
                                guard let id = r["id"] as? String,
                                    let name = r["name"] as? String,
                                    let handle = r["handle"] as? String,
                                    let picture_url = r["picture_url"] as? String else {
                                    break
                                }
                                let rapper = Rapper(id: id, name: name, handle: handle, picture_url: URL(string: picture_url)!)
                                rappers.append(rapper)
                            }
                            
                            guard let name = o["name"] as? String,
                                let picture_url = o["picture_url"] as? String else {
                                break
                            }
                            
                            let squad = Squad(rappers: rappers, name: name, picture_url: URL(string: picture_url))
                            squads.append(squad)
                            
                        }
                        
                        completion(squads)
                        
                    } else {
                        
                        completion(nil)
                        
                    }
                    
                } else {
                    
                    completion(nil)
                    
                }
                
            }
            
        } else {
            completion(nil)
        }
        
    }
    
    func generateBoundaryString() -> String {
        
        return "Boundary-\(NSUUID().uuidString)"
        
    }
    
}
