
import Foundation

public class RestURL : NSObject{
    
    static let sharedInstance = RestURL()
    private var baseURL = "http://77.68.80.27:4010/"
    public var GetModifierInfo = "marketplaceapi/getproductmodifierinfo?"

    
    override init(){

        GetModifierInfo = baseURL+GetModifierInfo
    }
    
    public func getProductModifier(productID:String)->AnyObject{
        
        let param = ["productid": productID]
        return param as AnyObject
    }
   
}
