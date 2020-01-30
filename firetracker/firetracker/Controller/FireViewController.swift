//
//  FireViewController.swift
//  firetracker
//
//  Created by Veer Doshi on 12/29/18.
//  Copyright © 2018 Veer Doshi. All rights reserved.

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MapKit
import SwiftSpinner
import ContactsUI
import Foundation

class FireViewController: UIViewController, CLLocationManagerDelegate, CNContactPickerDelegate {

    var alertView: UIAlertController?
    
    let locationManager = CLLocationManager()

    //let FIRE_URL = "https://api.aerisapi.com/fires/search?query=country:us&client_id=ldbrCpY034ygHsKHtWYSb&client_secret=DF1x5yR1iZncAMZhjeBeAFlwyV48aJDC2m43pQ3L"
    //let FIRE_URL = "https://api.aerisapi.com/fires/search?query=country:us&limit=20&client_id=ldbrCpY034ygHsKHtWYSb&client_secret=DF1x5yR1iZncAMZhjeBeAFlwyV48aJDC2m43pQ3L"

    //let FIRE_URL = "https://api.aerisapi.com/fires/closest?p=sacramento,ca&radius=500miles&from=-6months&limit=20&client_id=ldbrCpY034ygHsKHtWYSb&client_secret=DF1x5yR1iZncAMZhjeBeAFlwyV48aJDC2m43pQ3L"
    //let FIRE_URL = "https://api.aerisapi.com/fires/closest?p=sacramento,ca&radius=500miles&from=-6months&limit=20&client_id=YjQcb5M9Xo1SolCNOjpMX&client_secret=sdgW40nakFX1vvIJ5eXtRZx6oP7SrKYfvT9zIVRw"
    //let FIRE_URL = "https://api.aerisapi.com/fires/closest?p=sacramento,ca&radius=1000&from=-12months&limit=10&client_id=YjQcb5M9Xo1SolCNOjpMX&client_secret=sdgW40nakFX1vvIJ5eXtRZx6oP7SrKYfvT9zIVRw"
    let FIRE_URL = "http://firetrack.herokuapp.com/fires/"
    let NEW_URL = "https://firetrack.herokuapp.com/weather/"
    let QUAKE_URL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"
    let API_URL = "https://fire-tracker.herokuapp.com/fires"
    let VEER_URL = "https://fire-tracker.herokuapp.com/fire/"
    
    //let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHER_URL = "http://firetrack.herokuapp.com/weather/"
    
    let APP_ID = "3966d66f35976a954a7a90ff92cd7967"
    var circleColor: [MKCircle:UIColor] = [:]
    override func viewDidLoad() {
       super.viewDidLoad()
        mapView.delegate = self

        locationServices()
        

        //getLocationData(url: API_URL)
        testJSONStuff()
        //getFireData(url: FIRE_URL)
        newFireData(url: NEW_URL)
        
        //putLocationData(url: VEER_URL)
        //  getQuakeData(url: QUAKE_URL)
    }

    @IBOutlet weak var mapView: MKMapView!


    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
    SwiftSpinner.show("Loading")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            //self.getLocationData(url: self.API_URL)
            self.testJSONStuff()
//            self.getFireData(url: self.FIRE_URL)
            self.newFireData(url: self.NEW_URL)
        }

    SwiftSpinner.hide()
    }


    @IBAction func zoomToUserLocation(_ sender: Any) {
        locationServices()
        mapView.zoomToUserLocation()
    }
    
    
    @IBAction func addFriendContact(_ sender: Any) {
        onClickPickContact()

    }
    
    func newFireData(url: String) {
        
        
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                
                
                let fireJSON : JSON = JSON(response.result.value!)
                let countJSON : Int = fireJSON["weather"].count - 1
                print(countJSON)
              
                
                //print(fireJSON["weather"][0]["loc"]["lat"])
                let span = MKCoordinateSpan.init(latitudeDelta: 100, longitudeDelta: 100)

                for n in 0...countJSON {
                    let location = CLLocationCoordinate2D(latitude:fireJSON["weather"][n]["loc"]["lat"].double!, longitude: fireJSON["weather"][n]["loc"]["long"].double!)
                
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.mapView.setRegion(region, animated: true)

                    let areaFire : Float = fireJSON["weather"][n]["areaInAcres"].float!

                    let windDeg : Float = fireJSON["weather"][n]["windDeg"].float ?? 0.0
                    let windSpeed : Float = fireJSON["weather"][n]["windSpeedinMPH"].float ?? 0.0
                    let humidity : Float = fireJSON["weather"][n]["humidity"].float ?? 0.0
                    let growthMeasurement : Float = fireJSON["weather"][n]["growthMeasurement"].float ?? 0.0


                    let annotation = MKPointAnnotation()

                    let areaOfFire : Float = ((areaFire/3.14159).squareRoot()) * 1609.34
                    let radius : Float = areaOfFire


                    if (growthMeasurement<=2.35) {
                        annotation.coordinate = location
                        annotation.title = "\(fireJSON["weather"][n]["name"]) Fire"
                        annotation.subtitle = "\(fireJSON["weather"][n]["description"]), Humidity: \(humidity), Wind Speed: \(windSpeed), Growth Potential: Low"

                        self.mapView.addAnnotation(annotation)

                        let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
                        self.circleColor[circle] = .yellow
                        self.mapView.addOverlay(circle)
                    } else if ((growthMeasurement>2.35) && (growthMeasurement<=3.8)) {

                        annotation.coordinate = location
                        annotation.title = "\(fireJSON["weather"][n]["name"]) Fire"
                        annotation.subtitle = "\(fireJSON["weather"][n]["description"]), Humidity: \(humidity), Wind Speed: \(windSpeed), Growth Potential: Moderate"
                        self.mapView.addAnnotation(annotation)

                        let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
                        self.circleColor[circle] = .orange
                        self.mapView.addOverlay(circle)
                    } else if (growthMeasurement>3.8) {

                        annotation.coordinate = location
                        annotation.title = "\(fireJSON["weather"][n]["name"]) Fire"
                        annotation.subtitle = "\(fireJSON["weather"][n]["description"]), Humidity: \(humidity), Wind Speed: \(windSpeed), Growth Potential: High"
                        self.mapView.addAnnotation(annotation)

                        let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
                        self.circleColor[circle] = .red
                        self.mapView.addOverlay(circle)
                    }

                }
                
                
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
        
        
    }
    
    
    func getFireData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the fire data")
                let fireJSON : JSON = JSON(response.result.value!)
                let countJSON : Int = fireJSON["response"].count - 1
                print(countJSON)
                
                let span = MKCoordinateSpan.init(latitudeDelta: 100, longitudeDelta: 100)
                
                
                
                
                Alamofire.request(self.WEATHER_URL, method: .get).responseJSON {
                    response in
                    if response.result.isSuccess {
                        let weatherJSON : JSON = JSON(response.result.value!)
                        
                        for n in 0...countJSON {
                            let location = CLLocationCoordinate2D(latitude:fireJSON["response"][n]["loc"]["lat"].double!, longitude: fireJSON["response"][n]["loc"]["long"].double!)
                            let region = MKCoordinateRegion(center: location, span: span)
                            self.mapView.setRegion(region, animated: true)
                            let areaFireABC : Float = fireJSON["response"][n]["report"]["areaKM"].float!
                            let areaFire : Float = areaFireABC/640
                            
                            let windDeg : Float = weatherJSON["weather"][n]["windDeg"].float ?? 0.0
                            let windSpeed : Float = weatherJSON["weather"][n]["windSpeedinMPH"].float ?? 0.0
                            let humidity : Float = weatherJSON["weather"][n]["humidity"].float ?? 0.0
                            let growthMeasurement : Float = weatherJSON["weather"][n]["growthMeasurement"].float ?? 0.0
                            
                            
                            let annotation = MKPointAnnotation()
                            
                            let areaOfFire : Float = ((areaFire/3.14159).squareRoot()) * 1609.34
                            let radius : Float = areaOfFire
                            
                            
                            if (growthMeasurement<=2.35) {
                                annotation.coordinate = location
                                annotation.title = "\(fireJSON["response"][n]["report"]["name"]) Fire"
                                annotation.subtitle = "Wind degrees: \(windDeg)° Wind speed: \(windSpeed)mph Humidity: \(humidity)%  Growth Potential: Low"
                                
                                self.mapView.addAnnotation(annotation)
                                
                                let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
                                self.circleColor[circle] = .yellow
                                self.mapView.addOverlay(circle)
                            } else if ((growthMeasurement>2.35) && (growthMeasurement<=3.8)) {
                                
                                annotation.coordinate = location
                                annotation.title = "\(fireJSON["response"][n]["report"]["name"]) Fire"
                                annotation.subtitle = "Wind degrees: \(windDeg)° Wind speed: \(windSpeed)mph Humidity: \(humidity)%  Growth Potential: Moderate"
                                self.mapView.addAnnotation(annotation)
                                
                                let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
                                self.circleColor[circle] = .orange
                                self.mapView.addOverlay(circle)
                            } else if (growthMeasurement>3.8) {
                                
                                annotation.coordinate = location
                                annotation.title = "\(fireJSON["response"][n]["report"]["name"]) Fire"
                                annotation.subtitle = "Wind degrees: \(windDeg)° Wind speed: \(windSpeed)mph Humidity: \(humidity)%  Potential: High"
                                self.mapView.addAnnotation(annotation)
                                
                                let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
                                self.circleColor[circle] = .red
                                self.mapView.addOverlay(circle)
                            }
                            
                        }
                        
                        
                    } else {
                        print("Error \(String(describing: response.result.error))")
                    }
                }
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                
            }
        }
    }
    
    




    func locationServices() {
        let  status = CLLocationManager.authorizationStatus()

        switch status {

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return

        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
        
        locationManager.delegate = self
        //locationManager.startUpdatingLocation()
        locationManager.requestLocation()
    }

    
    
    
    func testJSONStuff(){
        
        //        let url : String = "https://fire-tracker.herokuapp.com/fire/4083241829+5107321243"
        
        let numberKey : String = UserDefaults.standard.string(forKey: "phonenumber")!
        let friendsURL : String = "https://fire-tracker.herokuapp.com/friend/" + numberKey
        
        Alamofire.request(friendsURL, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the fire data")
                let friendsJSON : JSON = JSON(response.result.value!)
                
                let countJSON : Int = friendsJSON["friends"].count - 1
                
                
                
                if countJSON < 0 {
                    print("HI")
                    let joinedNumbers: String = ""
                } else {
                    var listOfNumbers : [String] = []
                    
                    for xyz in 0...countJSON {
                        let phonenumberfound : String = friendsJSON["friends"][xyz]["friendphone"].string!
                        let statusOfFriend : String = friendsJSON["friends"][xyz]["status"].string!
                        if statusOfFriend == "yes" {
                            listOfNumbers.append(phonenumberfound)
                        } else {
                            print("NOT AUTHORIZED")
                        }
                        
                    }
                    
                    
                    if listOfNumbers.count > 0 {
                        let joinedNumbers: String = listOfNumbers.joined(separator: "+")
                        let joinedURL : String = "https://fire-tracker.herokuapp.com/fire/" + joinedNumbers
                        self.getLocationData(url: joinedURL)
                    } else {
                        print("NO ACCOUNTS AUTHORIZED")
                    }
                    
                    
                }
                
                
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                
            }
        }
        
    }
    
    
    
    

    func getLocationData(url: String) {
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {

                print("Success! Got the location data")
                print(url)
                let fireJSON : JSON = JSON(response.result.value!)
                let countJSON : Int = fireJSON["friends"].count - 1
                print(countJSON)

                let span = MKCoordinateSpan.init(latitudeDelta: 100, longitudeDelta: 100)
                let userKey : String = UserDefaults.standard.string(forKey: "name")!
                
                print(fireJSON["fires"][0]["latitude"])
                for n in 0...countJSON {
                    let location = CLLocationCoordinate2D(latitude:fireJSON["friends"][n]["latitude"].double!, longitude: fireJSON["friends"][n]["longitude"].double!)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.mapView.setRegion(region, animated: true)
                    
                    var nameFromData : String = fireJSON["friends"][n]["name"].string!
                    if nameFromData == userKey {
                        print("HI")
                    } else {
                        print("BYE")
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        annotation.title = "\(fireJSON["friends"][n]["name"])'s Location"
                        annotation.subtitle = "Latitude: \(fireJSON["friends"][n]["latitude"].double!) Longitude: \(fireJSON["friends"][n]["longitude"].double!)"
                        self.mapView.addAnnotation(annotation)
                    }
                    
                    

                }
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }

    
    
    
    
    
    func putLocationData(url: String, lat: Float, lon: Float) {
        
        let numberKey : String = UserDefaults.standard.string(forKey: "phonenumber")!
        let nameKey : String = UserDefaults.standard.string(forKey: "name")!
        
        let parameters: Parameters = ["name": nameKey, "latitude": lat, "longitude": lon]
        
        let appendedURL = url+numberKey
       
        Alamofire.request(appendedURL, method: .put, parameters: parameters).responseString { response in
            print(response)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            putLocationData(url: VEER_URL, lat: Float(currentLocation.coordinate.latitude), lon: Float(currentLocation.coordinate.longitude))
            print("Current location: \(currentLocation.coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func createAlert (title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        //CREATING ON BUTTON
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            print ("YES")
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            print("NO")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func onClickPickContact(){
        
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
        //print("HI")
        
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {
        print("POOP")
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let userName:String = contact.givenName
        //print(userName)
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:String = (userPhoneNumbers[0].value).stringValue
        let removedSpaceString:String = firstPhoneNumber.removeWhitespace()
        let removedDashesString:String = removedSpaceString.removeDashes()
        let removedParenthesis1String:String = removedDashesString.removeParenthesis1()
        let removedParenthesis2String:String = removedParenthesis1String.removeParenthesis2()
        let finalPhoneNumber: String = removedParenthesis2String
        //print(finalPhoneNumber)
        contactWasSelected(name: userName, phonenumber: finalPhoneNumber)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("SAD")
    }
    
    func contactWasSelected (name: String, phonenumber: String) {
        let parameters: Parameters = ["friendname": name, "friendphone": phonenumber, "status": "no"]
        let numberKey : String = UserDefaults.standard.string(forKey: "phonenumber")!
        let url : String = "https://fire-tracker.herokuapp.com/friend/"
        let minus : String = "-"
        let appendedURL : String = url+numberKey+minus+phonenumber
        Alamofire.request(appendedURL, method: .put, parameters: parameters).responseString { response in
            print(response)
            
        }
        
        if let accountSID = ProcessInfo.processInfo.environment["ACfdc7970b134923c65d56da4f6bc33352"],
            let authToken = ProcessInfo.processInfo.environment["8caf25f609ca5e73b8b030b6b2d7eed2"] {
            
            let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
            let parameters = ["From": "4086206325", "To": "\(phonenumber)", "Body": "This message is from Firetracker. The account with the phonenumber \(numberKey) has requested permission to access your location during wildfires. Text 'Y' to grant permission."]
            
            Alamofire.request(url, method: .post, parameters: parameters)
                .authenticate(user: accountSID, password: authToken)
                .responseJSON { response in
                    debugPrint(response)
            }
            
            RunLoop.main.run()
        }
        
    }
    
    //    func getQuakeData(url: String) {
    //        Alamofire.request(url, method: .get).responseJSON {
    //            response in
    //            if response.result.isSuccess {
    //
    //                print("Success! Got the quake data")
    //                let quakeJSON : JSON = JSON(response.result.value!)
    //                let quakeCountJSON : Int = quakeJSON["features"].count - 1
    //
    //                //print(fireJSON)
    //                print(quakeCountJSON)
    //
    //                let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
    //
    //                print(quakeJSON["features"][0]["properties"]["mag"])
    //                for n in 0...quakeCountJSON {
    //                    let location = CLLocationCoordinate2D(latitude:quakeJSON["features"][n]["geometry"]["coordinates"][1].double!, longitude: quakeJSON["features"][n]["geometry"]["coordinates"][0].double!)
    //                    let region = MKCoordinateRegion(center: location, span: span)
    //                    self.mapView.setRegion(region, animated: true)
    //                    let annotation = MKPointAnnotation()
    //                    annotation.coordinate = location
    //                    annotation.title = quakeJSON["features"][n]["properties"]["place"].string
    //                    annotation.subtitle = "Magnitude: \(quakeJSON["features"][n]["properties"]["mag"])"
    //                    self.mapView.addAnnotation(annotation)
    //                }
    //
    //            }
    //            else {
    //                print("Error \(String(describing: response.result.error))")
    //
    //            }
    //        }
    //    }

    
    
}

extension FireViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = circleColor[overlay]
            circleRenderer.fillColor = circleColor[overlay]?.withAlphaComponent(0.3)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


