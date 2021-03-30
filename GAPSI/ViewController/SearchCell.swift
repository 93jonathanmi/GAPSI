//
//  SearchCell.swift
//  GAPSI
//
//  Created by Jonathan Lopez on 29/03/21.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var imgImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    
    
    
    override func prepareForReuse() {
        imgImage.image = nil
        imgImage.backgroundColor = .clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInfo(Modelo: ModelProductLite){
        lblTitle.text = Modelo.title
        
        let myPrice = Modelo.price
        let newPrice = String(format: "%.2f", myPrice)
        
        let myRate = Modelo.rating
        let newRate = String(format: "%.1f", myRate)
        
        lblCost.text = "$\(newPrice)"
        lblRate.text = "Calificación: \(newRate)"
        
        if Modelo.urlimage != ""{
            
            let url = URL(string: Modelo.urlimage)

            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    
                    if data != nil{
                    
                    self.imgImage.image = UIImage(data: data!)
                    }else{
                        
                        //self.imgImage.image = UIImage(named:"iconGray")!
                        
                    }
                    
                }
            }
            
            
        }

        
    }
    

}
