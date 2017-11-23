

import UIKit


class ModifierItem: NSObject {
    
    var productID: String?
    var modifierID: Double?
    var modifierName: String?
    var price: Double?
    var itemTotalPrice: Double?
    var quantity: Int?
    var notes: String?
    var selectionType:String?
    var viewType:String?
    var showTitle:Bool?
    
    init(productID: String,
        modifierID: Double,
        modifierName: String,
        price: Double,
        itemTotalPrice: Double,
        quantity: Int,
        notes: String,
        selectionType:String,
        viewType:String,
        showTitle:Bool
        )
    {
        
        self.productID = productID
        self.modifierID = modifierID
        self.modifierName = modifierName
        self.price = price
        self.itemTotalPrice = itemTotalPrice
        self.quantity = quantity
        self.notes = notes
        self.selectionType = selectionType
        self.viewType = viewType
        self.showTitle = showTitle
    }
}
