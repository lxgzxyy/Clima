

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=523bbd8c9830750467c21a6f2181e0b5&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    //receive the city name from textField
    func fetchWeather(cityName: String){
        let url = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: url)
    }
    
    //call the API
    func performRequest(urlString: String){
        //1. Create a URL
        if let url = URL(string: urlString) {
            
            //2. Create a URLSession (just like a browser)
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in     //closure
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                //handle the response data
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        
                        //可以使得这个方法可以重复利用。任何想通过这个weatherManager把JSON数据传到Interface的人只需要定义.didUpdateWeather这个方法就行。
                        delegate?.didUpdateWeather(weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(condtionID: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
}
