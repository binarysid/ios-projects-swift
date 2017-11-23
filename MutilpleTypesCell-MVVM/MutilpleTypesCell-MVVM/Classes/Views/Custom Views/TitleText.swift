

import Foundation
import UIKit

class TitleText: UILabel{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
        self.textColor = UIColorFromHex(rgbValue: Resources.titleTextColor)
        //self.font = UIFont(name: "Helvetica", size: self.font.pointSize)
    }
}

func UIColorFromHex(rgbValue:UInt32)->UIColor {
    
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(1.0))
}
