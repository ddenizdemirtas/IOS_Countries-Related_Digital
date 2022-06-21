//
// ViewController.swift
// Countries_2.0
//
// Created by Deniz Demirtas on 6/9/22.
//

import MapKit
import SDWebImage
import SwiftUI
import UIKit



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    var countryNames = [String]()
    var currencyCodes = [String]()
    var countryCodes = [String]()
    var wikiIDs = [String]()
    var imageDict = [String: UIImage]()
    var coordinates = [String: [Double]]()

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath) as! TableViewCell

        cell.imageLabel.text = countryNames[indexPath.row]
        cell.imageCell.sd_setImage(with: URL(string: "https://countryflagsapi.com/png/\(countryCodes[indexPath.row])"))

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryNames.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ARRAY: \(coordinates)")
        submit(self.tableView, countryNames[indexPath.row], countryCodes[indexPath.row], currencyCodes[indexPath.row], wikiIDs[indexPath.row])

        
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let saveAction = UIContextualAction(style: .normal, title: "Add To Favourites") {
            _, _, completionHandler in

            self.tableView.cellForRow(at: indexPath)?.backgroundColor = .yellow
            completionHandler(true)
        }
        saveAction.backgroundColor = .green

        let deleteSaveAction = UIContextualAction(style: .normal, title: "Remove From Favourites", handler: {
            _, _, completionHandler in

            self.tableView.cellForRow(at: indexPath)?.backgroundColor = .white
            completionHandler(true)
        })
        deleteSaveAction.backgroundColor = .white
        if self.tableView.cellForRow(at: indexPath)?.backgroundColor == .yellow {
            deleteSaveAction.backgroundColor = .red
            saveAction.backgroundColor = .white
        }

        let swipeActions = UISwipeActionsConfiguration(actions: [saveAction, deleteSaveAction])

        return swipeActions
    }

    func submit(_ sender: UITableView, _ countryNameSent: String, _ countryCodeSent: String, _ currencyCodeSent: String, _ wikiIDSent: String) {
        // pullCountryImage(code: countryCodeSent)

        let countryScreenData = countryScreenData()

        countryScreenData.countryName = countryNameSent
        countryScreenData.countryCode = countryCodeSent
        countryScreenData.countryCurrency = currencyCodeSent
        countryScreenData.latitude = coordinates[countryCodeSent]![0]
        countryScreenData.longitude = coordinates[countryCodeSent]![1]
        countryScreenData.wikiID = wikiIDSent

        let destinationVC = UIHostingController(rootView: DetailsUIViewController().environmentObject(countryScreenData))

        present(destinationVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        pullCountryList()
        

        // Do any additional setup after loading the view.
    }

    func pullCountryList() {
        let headers = [
            "X-RapidAPI-Host": "wft-geo-db.p.rapidapi.com",
            "X-RapidAPI-Key": "INSERT YOUR RAPID API KEY",
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://wft-geo-db.p.rapidapi.com/v1/geo/countries?limit=10")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [self] (data, response, error) -> Void in
            if error != nil {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    let jsonData = jsonResponse["data"] as! [[String: Any]]
                   
                    for info in jsonData {
                        self.countryNames.append(info["name"] as! String)
                        self.countryCodes.append(info["code"] as! String)
                        self.currencyCodes.append((info["currencyCodes"] as? [String])?.first ?? "not")
                        self.wikiIDs.append(info["wikiDataId"] as! String)
                    }
                   
                    DispatchQueue.main.async {
                        for code in self.countryCodes {
                            self.fetch(code)
                        }
                        self.tableView.reloadData()
                        sleep(1)
                    }

                } catch { print("Error") }
            }
        })

        dataTask.resume()
    }

    func fetch(_ code: String) {
        let headers = [
            "X-RapidAPI-Key": "INSERT YOUR RAPID API KEY",
            "X-RapidAPI-Host": "spott.p.rapidapi.com",
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://spott.p.rapidapi.com/places/\(code)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print("InitialRes: \(httpResponse as Any)")
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    print("QUOTA CHECK: \(jsonResponse)")
                    let jsonCoordinates = jsonResponse["coordinates"] as! [String: Double]

                    let latitude = jsonCoordinates["latitude"] as! Double
                    let longitude = jsonCoordinates["longitude"] as! Double
                    self.coordinates[code] = [latitude, longitude]

                    

                } catch {
                    print("Error")
                }
            }
        })

        dataTask.resume()
    }
}
