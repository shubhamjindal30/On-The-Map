//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Shubham Jindal on 29/03/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import Foundation
struct StudentLocation {
    
    static var studentLocations = [StudentLocation]()
    
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var uniqueKey: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(dictionary: [String:AnyObject]) {
        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"]  as? String
        self.latitude = dictionary["latitude"]  as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.mapString = dictionary["mapString"] as? String
        self.mediaURL = dictionary["mediaURL"]  as? String
        self.uniqueKey = dictionary["uniqueKey"] as? String
    }
    
}
