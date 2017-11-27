

import UIKit

protocol DownStateButtonControllerDelegate {
    func selectedButton(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String)
}

class DownStateButton : UIButton {
    
    var delegate: DownStateButtonControllerDelegate?
    var alternateButton:Array<DownStateButton>?
    var radioSelected = UIImage(named: "select_radio_btn")!
    var radioNonSelected = UIImage(named: "non_select_radio_btn.png")!
    var radioButton: UIImageView?
    let spacing: CGFloat = 10
    var modifierItem: ModifierItem?
    var option: ModifierOption?

    var viewType: String?
    var downStateImage:String? = "g.png"{
        
        didSet{
            
            if downStateImage != nil {
                self.radioButton?.image = self.radioSelected
                //self.setImage(UIImage(named: downStateImage!), forState: UIControlState.Selected)
            }
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init(coder: NSCoder) {
        
        super.init(coder: coder)!
        //self.setRadioImage(self)
        self.addTarget(self, action: #selector(DownStateButton.onTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        
    }

    func setRadioImage(_ button:UIButton){
        
        self.radioButton = UIImageView(frame: CGRect(x: 0,y: 0,width: button.frame.size.width, height: button.frame.size.height))
        radioButton!.image = radioNonSelected
        button.addSubview(self.radioButton!)
        
    }
    
    func setTitleText(_ titleStr: String){
        
        let titleText = UILabel()
        titleText.frame = CGRect(x: 10, y: self.frame.size.height/4, width: self.frame.size.width * 0.8, height: self.frame.size.height/2)
        titleText.text = titleStr
        titleText.font = UIFont(name: "Helvetica", size: 12)
        titleText.textColor = UIColor.white
        //titleText.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        
        self.setTitle(titleText.text, for: UIControlState())
        self.titleLabel?.layer.opacity = 0.0
        self.addSubview(titleText)
        
    }
    
    func unselectAlternateButtons(){
        
        if alternateButton != nil {
            
            self.isSelected = true
            
            for aButton:DownStateButton in alternateButton! {
                
                aButton.isSelected = false
                //aButton.removeAllSubViews()
                //aButton.setRadioImage(aButton)
                //aButton.setTitleText(aButton.currentTitle!)
            }
            
        }
        else{
            toggleButton()
        }
        self.option?.selected = self.isSelected
        delegate?.selectedButton(self.isSelected, modifierItem: modifierItem!,option: option!, type:viewType!)
        
    }
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        unselectAlternateButtons()
//        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
//    }
    
    func onTouchUpInside(_ sender: UIButton) {
        
        unselectAlternateButtons()
    }

    func toggleButton(){
        
        if self.isSelected==false{
            
            self.isSelected = true
        }else {
            
            self.isSelected = false
        }
    }
}
