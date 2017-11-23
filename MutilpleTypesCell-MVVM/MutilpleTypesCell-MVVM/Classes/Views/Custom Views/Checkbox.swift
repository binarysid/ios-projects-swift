

import UIKit

protocol CheckboxDelegate{
    
    func didSelectCheckbox(_ state: Bool, modifierItem: ModifierItem,option: ModifierOption,type:String)
}

class Checkbox : UIButton{
    
    var mDelegate: CheckboxDelegate?
    var customTag: Double?
    var modifierItem: ModifierItem?
    var option: ModifierOption?
    var viewType: String?
    
    required init(coder: NSCoder){
        
        super.init(coder: coder)!
        self.applyStyle()
        //self.setTitle(title, forState: UIControlState.Normal)
        self.addTarget(self, action: #selector(Checkbox.onTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        
    }
    
    func adjustEdgeInsets(){
        
        let lLeftInset: CGFloat = 8.0
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.imageEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, lLeftInset, 0.0 as CGFloat, 0.0 as CGFloat)
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0 as CGFloat, (lLeftInset * 2), 0.0 as CGFloat, 0.0 as CGFloat)
        
    }
    
    func applyStyle(){
        
        self.setTitle("", for: UIControlState())
        self.setImage(UIImage(named: "checked_checkbox"), for: UIControlState.selected)
        self.setImage(UIImage(named: "unchecked_checkbox"), for: UIControlState())
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
     }
    
    func onTouchUpInside(_ sender: UIButton){
        
       self.onSelectChange()
        
    }
    
    func onSelectChange(){
        
        print(self.isSelected)
        self.isSelected = !self.isSelected
        print(self.isSelected)
        self.option?.selected = self.isSelected
        mDelegate?.didSelectCheckbox(self.isSelected, modifierItem: modifierItem!,option: option!, type:viewType!)
        
    }
    
}
