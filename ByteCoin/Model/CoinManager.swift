import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"

    private var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "CoinAPI-Info", ofType: "plist") else {
                fatalError("Couldn't find file 'CoinAPI-Info.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.value(forKey: "API_KEY") as? String else {
                fatalError("Couldn't find key 'API_KEY' in 'CoinAPI-Info.plist'.")
            }
//            if (value.starts(with: "_")) {
//                  fatalError("Register for an API key from CoinAPI.io")
//            }
            return value
        }
    }
    
    
    let currencyArray = ["USD","AUD","CAD","CNY","EUR","GBP","HKD","JPY","NZD","RUB","SGD"]

    func getCoinPrice(of crypto: String, for currency: String) {
        let urlString = "\(baseURL)/\(crypto)/\(currency)?apikey=\(apiKey)"
        //Use optional binding to unwrap the URL that's created from the urlString
        if let url = URL(string: urlString) {
            //Create a new URLSession object with default configuration
            let session = URLSession(configuration: .default)
            //Create a new data task for the URLSession
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            //Start task to fetch data from bitcoin average's servers
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
}
