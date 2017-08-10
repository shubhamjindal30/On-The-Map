//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Shubham Jindal on 28/03/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import Foundation
class ParseClient: NSObject {
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Get student locations
    func getStudentLocations(completionHandlerForGetLocations: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ConstantsParse.ApiUrl)/\(ConstantsParse.StudentLocation)\(ConstantsParse.LimitAndOrder)")!)
        request.addValue(ConstantsParse.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ConstantsParse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = UdacityClient.sharedSession
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                completionHandlerForGetLocations(nil, false, ConstantsUdacity.NetworkProblem)
                return
            }
            
            DataHandling.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForGetLocations)
            
            self.parseData(data!, completionHandlerForConvertedData: completionHandlerForGetLocations)
        }
        
        task.resume()
    }
    
    // MARK: Post a student's location
    func postStudentLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandlerForPostLocation: @escaping (_ result: [String:AnyObject]?, _ success: Bool,  _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(ConstantsParse.ApiUrl)/\(ConstantsParse.StudentLocation)")!)
        request.httpMethod = "POST"
        request.addValue(ConstantsParse.AppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ConstantsParse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDict: [String:Any] = [
            "uniqueKey": UdacityClient.accountID!,
            "firstName": UdacityClient.firstName!,
            "lastName": UdacityClient.lastName!,
            "mapString": mapString,
            "mediaURL": mediaUrl,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let session = UdacityClient.sharedSession
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                completionHandlerForPostLocation(nil, false, ConstantsUdacity.NetworkProblem)
                return
            }
            
            DataHandling.shared.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPostLocation)
            
            self.parseData(data!, completionHandlerForConvertedData: completionHandlerForPostLocation)
            
            
            
        }
        task.resume()
    }
    
    // MARK: Display all student locations
    func displayStudentLocations(_ completionHandlerForAnnotations: @escaping (_ result: [StudentLocation]?, _ success: Bool, _ error: String?) -> Void) {
        
        ParseClient.sharedInstance().getStudentLocations { (results, success, error) in
            if success {
                if let data = results!["results"] as AnyObject? {
                    StudentLocation.studentLocations.removeAll()
                    for result in data as! [AnyObject] {
                        let student = StudentLocation(dictionary: result as! [String : AnyObject])
                        StudentLocation.studentLocations.append(student)
                    }
                    completionHandlerForAnnotations(StudentLocation.studentLocations, true, nil)
                }
            } else {
                completionHandlerForAnnotations(nil, false, error)
            }
        }
    }
    
    
    // MARK: Parse the raw JSON data accordingly
    private func parseData(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        } catch {
            completionHandlerForConvertedData(nil, false, "There was an error parsing the JSON")
            return
        }
        completionHandlerForConvertedData(parsedResult as? [String:AnyObject], true, nil)
    }
}
