//
//  ModelProduct.swift
//  GAPSI
//
//  Created by Jonathan Lopez on 29/03/21.
//

import Foundation

class ModelProductLite{
    
    var id : String
    
    var rating: Double
    var price: Double
    var title : String
    var urlimage: String


    init(id : String,rating: Double, price: Double, title : String, urlimage: String){
        
        self.id = id
        self.rating = rating
        self.price = price
        self.title = title
        self.urlimage = urlimage
        
    }
}

