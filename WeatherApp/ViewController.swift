//
//  ViewController.swift
//  WeatherApp
//
//  Created by Evgeny on 11.07.22.
//

import UIKit

// MARK: - Weather
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

// MARK: - Hourly
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

// MARK: - HourlyUnits
struct HourlyUnits: Codable {
    let time, temperature2M, windspeed10M: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case windspeed10M = "windspeed_10m"
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var weather: Weather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func loadData() {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=52.13&longitude=29.34&hourly=temperature_2m,windspeed_10m"

        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            print(1234)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
                if let data = data {
                    
//                    let jsonString = String(data: data, encoding: .utf8)
//                    print(jsonString)
                    if let results: Weather = try? JSONDecoder().decode(Weather.self, from: data) {
                        self.weather = results
                        print(123)
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
    
}


