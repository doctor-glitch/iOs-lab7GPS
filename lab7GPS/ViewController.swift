//
//  ViewController.swift
//  lab7GPS
//
//  Created by user224311 on 3/8/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager = CLLocationManager ()
    
    var maxSpeedData = 0.0;
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0.0
    var timeHrs: Double = 0.0
    var initialVelocity = 0.0
    var finalVelocity = 0.0
    var maxAcc = 0.00
    
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var speed: UILabel!
    
    @IBOutlet var maxSpeed: UILabel!
    
    @IBOutlet var avgSpeed: UILabel!
    
    @IBOutlet var distance: UILabel!
    
    @IBOutlet var maxAccleration: UILabel!
    
    @IBOutlet var overspeedIndicator: UIImageView!
    
    @IBOutlet var tripStartIndicator: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripStartIndicator.backgroundColor = UIColor.gray;
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickStartTrip(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        tripStartIndicator.backgroundColor = UIColor.green;
    }
    
    
    @IBAction func onClickStopTrip(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        self.map.showsUserLocation = false
        tripStartIndicator.backgroundColor = UIColor.gray;
        overspeedIndicator.backgroundColor = UIColor.white;
        traveledDistance = 0.0
        maxSpeedData = 0.0
        initialVelocity = 0.0
        finalVelocity = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Make map visable and set initial location
        locationManager.delegate = self
        
        //get the best location with accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //get permissions from user
        locationManager.requestWhenInUseAuthorization()
        
        //starts updating the location
        //        locationManager.startUpdatingLocation()
        
        map.delegate = self
    }
    
    // sets location and gets updates render function for additional zoom
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            manager.startUpdatingLocation()
            render (location)
        }
        
        //calculate total distance travelled
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
        }
        lastLocation = locations.last
        
        let distanceKms = traveledDistance/1000
        distance.text = "\(String(format: "%.2f", distanceKms)) km"
        
        
        //calculate total travelled time to find average speed
        let startTime = startLocation.timestamp
        let endTime = lastLocation.timestamp
        
        let travelledTime = endTime.timeIntervalSince(startTime)
        timeHrs = travelledTime/3600
                
        //average speed
        avgSpeed.text = "\(String(format: "%.2f", (traveledDistance/travelledTime ) / 3.6)) km/hr"
        
        
    }
    
    // render function sets the region and pin for orginal location
    func render (_ location: CLLocation) {
        
        let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )
        
        //span settings determine how much to zoom into the map - defined details
        let span = MKCoordinateSpan(latitudeDelta: 0.0002, longitudeDelta: 0.0002)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        map.setRegion(region, animated: true)
        
        //to show blue dot on the map
        self.map.showsUserLocation = true
        
        finalVelocity = location.speed
        
        if finalVelocity > 115 {
            overspeedIndicator.backgroundColor = UIColor.red;
        } else {
            overspeedIndicator.backgroundColor = UIColor.white;
        }
        
        //calculating max accleration
        let acceleration = ((finalVelocity - initialVelocity) / timeHrs)
        if !acceleration.isNaN && !acceleration.isInfinite && (acceleration * 0.2778) > maxAcc{
            maxAcc = acceleration * 0.2778
            maxAccleration.text = "\(String(format: "%.2f", maxAcc)) m/s^2"
        }
        initialVelocity = finalVelocity
        
        //current speed
        speed.text = "\(finalVelocity) km/hr"
        
        //calculate max Speed
        if(maxSpeedData < finalVelocity){
            maxSpeedData = finalVelocity
            maxSpeed.text = "\(String(format: "%.2f", maxSpeedData)) km/hr"
        }
        
        
        
        
    }
    
}

