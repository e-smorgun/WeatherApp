//
//  ViewController.swift
//  WeatherApp
//
//  Created by Evgeny on 11.07.22.
//

import UIKit
import CoreLocation

struct Weather: Codable {
    let latitude, longitude: Double
    let elevation: Int
    let generationtimeMS: Double
    let utcOffsetSeconds: Int
    let hourly: Hourly
    let hourlyUnits: HourlyUnits

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, elevation
        case generationtimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case hourly
        case hourlyUnits = "hourly_units"
    }
}

struct Hourly: Codable {
    let temperature2M: [Double]
    let time: [String]
    let windspeed10M: [Double]

    enum CodingKeys: String, CodingKey {
        case temperature2M = "temperature_2m"
        case time
        case windspeed10M = "windspeed_10m"
    }
}

struct HourlyUnits: Codable {
    let time, temperature2M, windspeed10M: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case windspeed10M = "windspeed_10m"
    }
}

struct Result: Codable {
    var results: [City]?
}

struct City: Codable {
    var name: String?
    var country: String?
    let latitude, longitude: Double
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var currentCity: String = ""
    var weather: Weather?
    var latitude: Double = 0.0, longitude: Double = 0.0
    var locationManager = CLLocationManager()

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentCity == "My Location"
        {
            LocationLabel.text = "My Location"
            loadLocation()
        } else {
        loadCityData()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    func loadLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = 5.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func loadData() {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m,windspeed_10m"

        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
                if let data = data {
                    if let results: Weather = try? JSONDecoder().decode(Weather.self, from: data) {
                        self.weather = results
                        self.tableView.reloadData()
                    }
                }

                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weather?.hourly.time.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureTableViewCell", for: indexPath) as? TemperatureTableViewCell {
            let currentTime =  weather?.hourly.time[indexPath.row]
            let currentTemperature = weather?.hourly.temperature2M[indexPath.row]
            let currentWind = weather?.hourly.windspeed10M[indexPath.row]
                        
            cell.timeLabel.text = "\(currentTime!)"
            cell.temperatureLabel.text = "Temperature - \(currentTemperature ?? -100)"
            cell.windLabel.text = "Wind - \(currentWind ?? -100)"
            
            return cell
        }
        return UITableViewCell()
    }
    
    func loadCityData() {
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(currentCity)&count=1"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
                if let data = data {

                    if let result: Result = try? JSONDecoder().decode(Result.self, from: data) {
                        
                        if(result.results == nil) {
                            self.LocationLabel.text = "Error"
                        } else {
                            self.LocationLabel.text = (result.results?.first?.name)!
                            self.longitude = (result.results?.first!.longitude)!
                            self.latitude = (result.results?.first!.latitude)!
                            self.loadData()                        }
                    }
                }
                
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    self.present(alert, animated: true)
                }
            }
        }
    }

    
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            loadData()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
            
        }
    }
    
}
