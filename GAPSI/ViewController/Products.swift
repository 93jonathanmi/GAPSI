//
//  ViewController.swift
//  GAPSI
//
//  Created by Jonathan Lopez on 29/03/21.
//

import UIKit

class Products: UIViewController, UISearchBarDelegate {
    
    let defaults = UserDefaults.standard
    
    var dataSearch : [String?] = []
    var dataProducts = [ModelProductLite]()
    var searchThis : String? = ""
    
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableProducts: UITableView!
    @IBOutlet weak var activityWait: UIActivityIndicatorView!
    
    @IBAction func actTap(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.viewSearch.alpha = 0
            }
        
    }
    @IBAction func actSearch(_ sender: Any) {
        
        activityWait.startAnimating()
        
        
        if searchThis != "" {
            
            UIView.animate(withDuration: 0.5) {
                self.viewSearch.alpha = 0
            }
            self.dataSearch.append(searchThis)
            defaults.set(dataSearch, forKey: "SavedStringArray")
            
            DispatchQueue.main.async {
                
            self.perform(#selector(self.loadSearch), with: nil, afterDelay: 0.8)
            }
            
            searchThis = searchThis!.trimmingCharacters(in: .whitespacesAndNewlines)
            searchThis = searchThis?.removeWhitespace()
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
            self.perform(#selector(self.reload), with: nil, afterDelay: 0.9)
        }else{
            if searchThis == ""{
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
                self.perform(#selector(self.reload), with: nil, afterDelay: 0.9)}
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityWait.startAnimating()
        btnSearch.roundCorners([ .bottomRight, .topRight , .bottomLeft, .topLeft], radius: 20)
        activityWait.roundCorners([ .bottomRight, .topRight , .bottomLeft, .topLeft], radius: 20)
        viewSearch.alpha = 0
        
        let myArray = defaults.stringArray(forKey: "SavedStringArray") ?? [String]()
        if myArray.count > 0 {
            
            dataSearch = myArray
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableProducts.delegate = self
        tableProducts.dataSource = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchBar.delegate = self
        
        productRequest()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchThis = searchText
        print(dataSearch.count)
        
        if searchThis == ""{
            
            activityWait.startAnimating()
            viewSearch.alpha = 0
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
            self.perform(#selector(self.reload), with: nil, afterDelay: 0.9)}
        else{
            
            if dataSearch.count >= 1 && searchThis != ""{
                
                viewSearch.alpha = 1
                
            }else{
                viewSearch.alpha = 0
                
                
            }
            
            
        }
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if dataSearch.count >= 1{
            viewSearch.alpha = 1
            
        }else{
            viewSearch.alpha = 0
            
            
        }
    }
    
    
}

extension Products: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellProduct") as! SearchCell
        let infoCell = dataProducts[indexPath.row]
        cell.setInfo(Modelo: infoCell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableProducts.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    // Get informaton to the API
    func productRequest(){
        
        let headers = [
            "X-IBM-Client-Id": "adb8204d-d574-4394-8c1a-53226a40876e"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://00672285.us-south.apigw.appdomain.cloud/demo-gapsi/search?&query=\(searchThis ?? "")")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            self.dataProducts.removeAll()
            
            if (error != nil) {
                print(error)
                
                self.endAnimation()
            } else {
                
                do {
                    
                    
                    let parsedDictionaryArray = try JSONSerialization.jsonObject(with: data!) as! [String:AnyObject]
                    //print(parsedDictionaryArray)
                    
                    if let arry = parsedDictionaryArray["items"] as? [[String:AnyObject]] {
                        
                        for dic in arry {
                            let id = dic["id"] as! String
                            var rating : Double?
                            var price : Double?
                            
                            
                            if let rat = dic["rating"] as? Double {
                                rating = rat
                            }else{
                                if let newRat = dic["rating"] as? String{
                                    let doneRat = Double("\(newRat)")
                                    rating = doneRat
                                }else{
                                    if let newRat2 = dic["rating"] as? Int{
                                        let doneRat2 = Double("\(newRat2)")
                                        rating = doneRat2
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                                
                            }
                            
                            
                            
                            
                            if let pric = dic["price"] as? Double{
                                price = pric
                            }else{
                                let newPric = dic["price"] as? String
                                let donePric = Double("\(newPric!)")
                                
                                price = donePric
                            }
                            
                            
                            
                            let image = dic["image"] as! String
                            let title = dic["title"] as! String
                            
                            
                            
                            let newProduct = ModelProductLite(id: id, rating: rating ?? 0.0, price: price ?? 0.0, title: title, urlimage: image)
                            
                            self.dataProducts.append(newProduct)
                            self.endAnimation()
                            
                            DispatchQueue.main.async {
                                self.perform(#selector(self.loadTable), with: nil, afterDelay: 0.8)
                            }
                            
                            
                        }
                        
                        
                        self.endAnimation()
                        
                    }
                } catch let error as NSError {
                    
                    self.endAnimation()
                    
                    print(error)
                }
                
                
            }
        })
        
        dataTask.resume()
        
    }
    
    
    func endAnimation() {
        
        DispatchQueue.main.async {
            self.activityWait.stopAnimating()
            self.btnSearch.isEnabled = true
            self.btnSearch.setTitle("Search", for: .normal)
            
            if self.dataProducts.count == 0 || self.dataProducts.count == nil{
                
                let alertController = UIAlertController(title: "Búsqueda", message:
                                                            "Esta busqueda no genero ningun resultado, prueba con otros valores.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler:nil))
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                
                
            }
        }
        
        
    }
    
    
    
    
    
    //Reload a table
    @objc func loadTable(){
        self.tableProducts.reloadData()
    }
    
    @objc func loadSearch(){
        
        self.collectionView.reloadData()
    }
    
    
    @objc func reload() {
        productRequest()
        
    }
    
    
    
}

extension Products: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSearch.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! SuggestionCell
        
        let list = dataSearch[indexPath.row]
        
        cell.lblSuggestion.text = list
        cell.viewBAckGround.roundCorners([ .bottomRight, .topRight , .bottomLeft, .topLeft], radius: 15)

        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activityWait.startAnimating()
        
        
        searchBar.text = ""
        searchBar.text = dataSearch[indexPath.row]
        searchThis = dataSearch[indexPath.row]
        
        UIView.animate(withDuration: 0.5) {
            self.viewSearch.alpha = 0
            }
        
        searchThis = searchThis!.trimmingCharacters(in: .whitespacesAndNewlines)
        searchThis = searchThis?.removeWhitespace()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 0.9)
        
        
    }
    
    
    
    
}
