/*
 練習ポイント：
 1.delegateの使い方
 2.protocolの使い方
 3.APIからデータを取得し、画面で反映
 4.locationManagerの使い方
 5.エラー処理
 6.MVCアーキテクチャの実装
 */

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ask user for authorization
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        
        locationManager.requestLocation()
        
        //set a delegate to monitor text field
        searchTextField.delegate = self
        
        weatherManager.delegate = self

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print(lat, lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    //when text field delegate notices that user pressed ENTER
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    //when text field delegate notices user stopped editing
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Please tell me the location."
            return false
        }
    }
    
    //when text field delegate notices user has finished editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text {
            
            //transfer the city name to weatherManager
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
      
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weather: WeatherModel) {
        DispatchQueue.main.async { [self] in
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
        print(weather.temperatureString)
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }
}
