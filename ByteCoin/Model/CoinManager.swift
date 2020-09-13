//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(_ error: Error?)
    func priceDidUpdate(rate price: Double, for currency: String)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8E7D4FAC-08D1-46D5-A224-3C081948B928"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apiKey=\(apiKey)"
        getRequest(on: urlString, currency)
    }
    
    func getRequest(on endpoint: String, _ currency: String) {
        let url = URL(string: endpoint)
        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                self.delegate?.didFailWithError(error)
                return
            }
            
            if let safeData = data {
                if let rate = self.parseJson(on: safeData) {
                    self.delegate?.priceDidUpdate(rate: rate, for: currency)
                }
            }
        }
        task.resume()
    }
    
    func parseJson(on payload: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let coinData = try decoder.decode(CoinData.self, from: payload)
            return coinData.rate
        } catch {
            return nil
        }
    }
}
