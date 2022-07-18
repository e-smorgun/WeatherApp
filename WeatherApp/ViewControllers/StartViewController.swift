//
//  StartViewController.swift
//  WeatherApp
//
//  Created by Evgeny on 14.07.22.
//

import UIKit

enum UserDefaultsKey: String {
    case kCityes = "kCityes"
}

class StartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewCityButton: UIButton!
    
    var currentCity: String = ""
    var allCity: [String] = []
    var latitude: Double = 0.0, longitude: Double = 0.0
    var result: Result?
    var weather: Weather?

    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: UserDefaultsKey.kCityes.rawValue) == nil {
            allCity.append("My Location")
            UserDefaults.standard.set(allCity, forKey: UserDefaultsKey.kCityes.rawValue)
        } else {
            allCity = UserDefaults.standard.object(forKey: UserDefaultsKey.kCityes.rawValue) as! [String]
        }
        print(allCity)
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func didTapAddNewCityButton() {
        let alert = UIAlertController(title: "What city would you like to add?", message: "", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
            let textField = alert.textFields![0]
            self.allCity.append(textField.text ?? "")
            UserDefaults.standard.set(self.allCity, forKey: UserDefaultsKey.kCityes.rawValue)
            self.tableView.reloadData()
        }))
//        alert.addAction(UIAlertAction(title: "For my location", style: .default, handler: { action in
//            self.addNewCityByLocation()
//            print(self.longitude, self.latitude)
//            self.loadData()
//            self.allCity.append(weather.)
//        }))
        alert.addAction(UIAlertAction(title: "Close alert", style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell", for: indexPath) as? NavigationTableViewCell {
    
            cell.cityLabel.text = allCity[indexPath.row]
            
            return cell
        }
        return UITableViewCell()
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        let story: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ViewController = story.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        vc.currentCity = allCity[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
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
}
