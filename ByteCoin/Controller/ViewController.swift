import UIKit

class ViewController: UIViewController {
       
    @IBOutlet weak var cryptoLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var cryptoName: UISegmentedControl!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var coinManager = CoinManager()
    
    var selectedCrypto = "BTC"
    var selectedCurrency = "USD"
    
    @IBAction func cryptoNameChanged(_ sender: Any) {
        switch cryptoName.selectedSegmentIndex {
        case 0:
            selectedCrypto = "BTC"
        case 1:
            selectedCrypto = "ETH"
        default:
            break
        }
        coinManager.getCoinPrice(of: selectedCrypto, for: selectedCurrency)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coinManager.delegate = self
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
    }
}
    
// MARK: - CoinManagerDelegate

extension ViewController: CoinManagerDelegate{
    
    func didUpdatePrice(price: String, currency: String) {
        DispatchQueue.main.async {
            self.cryptoLabel.text = price
            self.currencyLabel.text = currency
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
    
// MARK: - UIPickerViewDataSource & UIPickerViewDelegate

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurrency = coinManager.currencyArray[row]
        coinManager.getCoinPrice(of: selectedCrypto, for: selectedCurrency)
    }
    
}
