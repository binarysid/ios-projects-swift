
//

import Foundation

// main product list
class Product {
    
    var ProductID:String?
    var ProductName:String?
    var Path:String?
    var Price:Double!
    var Details:String?
    var AlergimonicID:String?
    var IsFaviorite:Int?
    var ItemTotalPrice:Double?
    var TotalAmount:Double?
    var ItemCountLocalDb:Int?
    var Quantity:Int?
    var SpecialNotes:String?
    var ItemCount:Int=0
    var hasModifier: Int?
    var modifierFullName:String?
    
    init(ProductID:String, ProductName:String, Path:String, Price:Double, Details:String, AlergimonicID:String, IsFaviorite:Int, ItemTotalPrice:Double, ItemCount:Int,
        SpecialNotes:String,hasModifier: Int,modifierFullName:String){
        
        self.ProductID = ProductID
        self.ProductName = ProductName
        self.Path = Path
        self.Price = Price
        self.Details = Details
        self.AlergimonicID = AlergimonicID
        self.IsFaviorite = IsFaviorite
        self.ItemTotalPrice = ItemTotalPrice
        self.ItemCount = ItemCount
        self.SpecialNotes = SpecialNotes
        self.hasModifier = hasModifier
        self.modifierFullName = modifierFullName
    }
    
}
