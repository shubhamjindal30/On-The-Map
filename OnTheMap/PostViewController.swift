//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Shubham Jindal on 30/03/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    
    enum ViewOnDisplay {
        case FormView
        case MapView
        case LinkView
    }
    struct Location {
        let latitude: Double
        let longitude: Double
        let mapString: String
        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
    
    var posterLatitude: CLLocationDegrees? = nil
    var posterLongitude: CLLocationDegrees? = nil
    
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var formLabel: UILabel!
    @IBOutlet weak var formTextField: UITextField!
    @IBOutlet weak var formSearchButton: UIButton!
    @IBOutlet weak var formActivitySpinner: UIActivityIndicatorView!
    
    
    @IBOutlet weak var mapWrappedView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewButton: UIButton!
    
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var websiteViewButton: UIButton!
    @IBOutlet weak var websiteViewTextField: UITextField!
    @IBOutlet weak var websiteViewLabel: UILabel!
    
    @IBAction func searchButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)
        showActivitySpinner(self.formActivitySpinner, style: .gray)
        
        let geocoder = CLGeocoder()
        
        guard let place = formTextField.text else {
            self.showAlert("Please enter a location")
            return
        }
        
        geocoder.geocodeAddressString(place) { (placemarks, error) in
            
            if error != nil {
                self.showAlert("Can't find location")
                self.hideActivitySpinner(self.formActivitySpinner)
            } else {
                self.displayView(.MapView)
                
                let placemark = placemarks?.first
                
                if let placemark = placemark {
                    let coordinate = placemark.location?.coordinate
                    
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: coordinate!, span: span)
                    
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = coordinate!
                    
                    self.posterLatitude = coordinate?.latitude
                    self.posterLongitude = coordinate?.longitude
                    
                    DispatchQueue.main.async {
                        self.mapView.removeAnnotation(annotation)
                        self.mapView.addAnnotation(annotation)
                        self.mapView.setRegion(region, animated: true)
                        self.hideActivitySpinner(self.formActivitySpinner)
                    }
                    
                } else {
                    self.showAlert("No matches for that location")
                }
            }
            
            
        }

    }
    @IBAction func placePinAction(_ sender: Any) {
        self.displayView(.LinkView)
    }
    @IBAction func websiteSubmitAction(_ sender: Any) {
        
        if websiteViewTextField.text!.isEmpty {
            displayAlert("No Website", errorMsg: "Please add a website")
            return
        }
        
        
        
        
        
        ParseClient.sharedInstance().postStudentLocation(mapString: formTextField.text!, mediaUrl: websiteViewTextField.text!, latitude: posterLatitude!, longitude: posterLongitude!) { (result, success, error) in
            
            
            if error != nil{
                DispatchQueue.main.async {
                    self.displayAlert("Network Problem", errorMsg: "Please check your internet connection")
                }
                return
            }
            else{
                _=result
            }
            
            
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.hideActivitySpinner(self.formActivitySpinner)
            }
        }
        

    }
    func displayAlert(_ errorTitle: String, errorMsg: String) {
        
        let alert = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton2Action(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton3Action(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //Show Activity Spinner
    func showActivitySpinner(_ spinner: UIActivityIndicatorView!, style: UIActivityIndicatorViewStyle) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.activityIndicatorViewStyle = style
            activitySpinner?.hidesWhenStopped = true
            activitySpinner?.isHidden = false
            activitySpinner?.startAnimating()
        }
    }
    
    //Hide Activity Spinner
    func hideActivitySpinner(_ spinner: UIActivityIndicatorView!) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.isHidden = true
            activitySpinner?.stopAnimating()
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

    func displayView(_ viewToDisplay: ViewOnDisplay) {
        switch viewToDisplay {
        case .FormView:
            formView.isHidden = false
            mapWrappedView.isHidden = true
            websiteView.isHidden = true
        case .MapView:
            formView.isHidden = true
            mapWrappedView.isHidden = false
            websiteView.isHidden = true
        case .LinkView:
            formView.isHidden = true
            mapWrappedView.isHidden = true
            websiteView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formActivitySpinner.isHidden = true
        
        self.displayView(.FormView)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
}
