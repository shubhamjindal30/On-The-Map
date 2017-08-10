//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Shubham Jindal on 29/03/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Outlet for map view
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    
    
    func populateMap() {
        
        ParseClient.sharedInstance().displayStudentLocations() { (locations, success, error) in
            
            if success {
                for location in locations! {
                    if let lat = location.latitude, let long = location.longitude,
                        let firstName = location.firstName, let lastName = location.lastName,
                        let mediaURL =  location.mediaURL {
                        
                        let annotation = MKPointAnnotation()
                        
                        let latDegrees = CLLocationDegrees(lat)
                        let longDegrees = CLLocationDegrees(long)
                        let coordinate = CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
                        
                        annotation.coordinate = coordinate
                        
                        annotation.title = "\(firstName) \(lastName)"
                        
                        if mediaURL.isEmpty {
                            annotation.subtitle = ConstantsParse.DefaultURL
                        } else {
                            annotation.subtitle = mediaURL
                        }
                        
                        self.annotations.append(annotation)
                    }
                }
                
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.annotations)
                    self.mapView.addAnnotations(self.annotations)
                }
                
            } else {
                self.showAlert(error!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.async {
            self.populateMap()
        }
        
        
    }
    
    //Method for logout button
    @IBAction func logoutAction(_ sender: Any) {
        
        UdacityClient.sharedInstance().endUserSession { (success, error) in
            if success {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(error!)
            }
            
            
        }
    }
    
    //Method to show alerts
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Method to verify url
    func canVerifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            
            if let toOpen = view.annotation?.subtitle {
                if canVerifyUrl(urlString: toOpen) {
                    app.open(URL(string: toOpen!)!, options: [:], completionHandler: nil)
                } else {
                    showAlert("The URL was not valid and could not be opened")
                }
            }
        }
    }

    
    
}
