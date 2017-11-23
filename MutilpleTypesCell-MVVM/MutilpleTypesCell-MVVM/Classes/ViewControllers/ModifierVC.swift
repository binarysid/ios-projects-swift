
import UIKit
import Alamofire
import AlamofireObjectMapper

protocol SetModifierDelegate: NSObjectProtocol{
    func modifyProduct(_ price:Double, productID:String, itemCount:Int, name:String, notes:String, productItem: Array<Product>?, modifierFullName:String,itemTotal:Double)
}

class ModifierVC: UIViewController, ModifierPresenterDelegate,ModifierItemDelegate,ModifierOptionsDelegate,ModifierSingleItemDelegate, UITextViewDelegate {
   
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UIButton!
    @IBOutlet weak var specialNotes: UITextView!
    
    var modifiers: Array<Modifier> = []
    var productItem: Array<Product>?
    var modifierFullName:String = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var showPageTitle = false{
        didSet{
            self.productNameLabel.isHidden = !showPageTitle
        }
    }
    
    var modifierTotalPrice:Double = 0.0{
        didSet{
            
            self.priceLabel.text = Resources.currency + String(self.modifierTotalPrice * (Double(self.itemCount)))
        }
    }

    var totalPrice:Double = 0.0{
        didSet{
            self.modifierTotalPrice = self.totalPrice
        }
    }
    var modifierFixedPrice:Double = 0.0
    var itemCount:Int = 0{
        didSet{
            // change price text when item counter change
            self.countLabel.setTitle(String(itemCount), for: UIControlState())
            self.modifierTotalPrice = self.totalPrice
        }
    }
    var productID:String?
    var productName:String?
    fileprivate var viewModel: ModifierViewModel?
    weak var modifierDelegate: SetModifierDelegate?
    let notePlaceHolder = "Add note"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.titleBar()
        self.plusBtn.layer.cornerRadius = 0
        self.countLabel.backgroundColor = UIColor.white
        self.setSpecialNoteText()
        self.productNameLabel.text = self.productName ?? "Lamb Donner Kebab"
        self.tableView.register(FullViewMultiSelectionCell.nib, forCellReuseIdentifier: FullViewMultiSelectionCell.identifier)
        self.tableView.register(ComponentViewMultiSelectionCell.nib, forCellReuseIdentifier: ComponentViewMultiSelectionCell.identifier)
        self.tableView.register(FullViewSingleSelectionCell.nib, forCellReuseIdentifier: FullViewSingleSelectionCell.identifier)
        
        self.installViewModel()
        
    }
    
    fileprivate func setSpecialNoteText(){
        
        self.specialNotes.text = notePlaceHolder
        self.specialNotes.returnKeyType = UIReturnKeyType.done
        self.specialNotes.backgroundColor = UIColor.clear
        self.specialNotes.layer.cornerRadius = 0
        self.specialNotes.layer.borderWidth = 1.0
//        self.specialNotes.layer.borderColor = CustomTask.UIColorFromHex(Resources.sharedInstance.topBarColor).CGColor
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.view.endEditing(true)
    }
    
    fileprivate func configTableView(){
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delegate = viewModel
        self.tableView.dataSource = viewModel
    }
    
    fileprivate func installViewModel(){
        
        self.viewModel = ModifierViewModel(productID: self.productID ?? "103861")
        self.configTableView()
        self.viewModel?.attachDelegate(self as ModifierPresenterDelegate, optionsDelegate:self as ModifierOptionsDelegate)
        self.fetchModifierList()
        //
    }
    
    fileprivate func fetchModifierList(){
        
        self.viewModel!.loadModifierList()
    }
    
    func optionSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String,isSingleSelection:Bool){ // for component view options
        
        self.editModifiers(state,modifierItem:modifierItem,option: option,isSingleSelection:isSingleSelection)
        self.updateModifierObject()
    }
    
    func singleOptionSelected(_ state: Bool, modifierItem: ModifierItem, option: ModifierOption, type: String, isSingleSelection: Bool) { // component view page radio option item selection checker
        
        self.editModifiers(state,modifierItem:modifierItem,option: option,isSingleSelection:isSingleSelection)
        self.updateModifierObject()
    }
    
    // component view selector
    func optionsItemSelected(_ state: Bool,modifierItem: ModifierItem,option: Array<ModifierOption>, type:String){
        
        let modifierItemVC = self.storyboard?.instantiateViewController(withIdentifier: "ModifierItemVC") as! ModifierItemVC
        
        modifierItemVC.modifierItem = modifierItem
        modifierItemVC.option = option
        modifierItemVC.viewType = ModifierViewType(rawValue: type)
        switch type{
            
        case ModifierViewType.ComponentViewMultiSelectionType.rawValue:
            modifierItemVC.attachMuiltiItemDelegate(self as ModifierItemDelegate)
            
            break
        case ModifierViewType.ComponentViewSingleSelectionType.rawValue:
            modifierItemVC.attachSingleItemDelegate(self as ModifierSingleItemDelegate)
            
            break
            //print("")
            
        default:
            break
        }
        self.navigationController?.present(modifierItemVC, animated: true, completion: nil)
        
    }
    
    // multi selection
    @objc func itemSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String){
        
        self.editModifiers(state,modifierItem:modifierItem,option: option,isSingleSelection:false)
        self.updateModifierObject()
    }
    
    func singleItemSelected(_ state: Bool, modifierItem: ModifierItem, option: ModifierOption, type: String) {
        
        self.editModifiers(state,modifierItem:modifierItem,option: option,isSingleSelection:true)
        self.updateModifierObject()
    }
    
     // update viewmodel object
    fileprivate func updateModifierObject(){
        
        if let modelView = self.viewModel{
            modelView.updateModifier(self.modifiers)
        }
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
        })
    }
    
    // add all selected modifiers to the product list
    fileprivate func addAllModifiers(){
        
        if self.isAnyItemSelected(){
            self.modifierFullName = ""

            
            for (index,modifier) in self.modifiers.enumerated(){
                

                
                for (_, option) in self.modifiers[index].option!.enumerated()  {
                 

                    if option.selected! {
                        self.modifierFullName = self.modifierFullName.isEmpty ? option.optionName! : (self.modifierFullName + " , " + option.optionName!)
                    }
                    
                }
            
            }
    
            self.modifierDelegate?.modifyProduct(self.modifierFixedPrice, productID: self.productID ?? "", itemCount: self.itemCount, name: self.productName!, notes: self.specialNotes.text ?? "",productItem: self.getUpdatedProductItemByID(self.productID!, productItem: self.productItem!, quantity: self.itemCount, price: self.modifierFixedPrice, modifierFullName: self.modifierFullName,itemTotal:self.modifierTotalPrice) , modifierFullName:self.modifierFullName,itemTotal:self.modifierTotalPrice)
        }

            //self.navigationController?.popViewControllerAnimated(false)
        
        //
    }
    
    func showLoader() {
        //self.showLoadingHUD()
    }
    
    func hideLoader() {
        //self.hideLoadingHUD()
    }
    
    func refreshData(_ price:Double, quantity:Int,modifiers: Array<Modifier>,showPageTitle:Bool) {
        
        self.modifiers = modifiers
        self.modifierFixedPrice = price
        self.totalPrice = price
        self.itemCount = quantity
        self.showPageTitle = showPageTitle
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
        })
    }
    
    func refreshDataFromLocalDB(_ price: Double, itemTotal: Double, quantity: Int, modifiers: Array<Modifier>) {
        
        self.modifiers = modifiers
        self.modifierFixedPrice = price
        self.itemCount = quantity
        self.modifierTotalPrice = itemTotal
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
        })
    }
    @IBAction func onItemPlus(_ sender: UIButton) {
        
        self.itemCount += 1
        
    }

    @IBAction func onAddItems(_ sender: UIButton) {
        
        self.addAllModifiers()
        
    }
    
    @IBAction func onItemMinus(_ sender: UIButton) {
        
        if self.itemCount>1{
            self.itemCount -= 1
        }
        
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = (self.view.frame).offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        var frameMovement = textView.frame.origin.y
        if frameMovement == 0{
            frameMovement = textView.superview!.frame.origin.y
        }
        
        animateViewMoving(true, moveValue: ((frameMovement/2)-30))
        
        if textView.text == notePlaceHolder {
            textView.text = ""
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        var frameMovement = textView.frame.origin.y
        
        if frameMovement == 0{
            frameMovement = textView.superview!.frame.origin.y
        }
        
        animateViewMoving(false, moveValue: ((frameMovement/2)-30))
        
        if textView.text.isEmpty || textView.text == "" {
            
            textView.textColor =  UIColorFromHex(rgbValue: Resources.titleTextColor)
            textView.text = notePlaceHolder
           
        }
        
    }
    
    @objc func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ModifierVC{
    
    // update the changed state(selected/unselected) of modifier object
    fileprivate func editModifiers(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption,isSingleSelection:Bool){
        
        if self.modifiers.count>0{
            if self.updateItemByID(option, mID: modifierItem.modifierID!, isSelected: state, isSingleSelection:isSingleSelection){
                self.totalPrice =  self.calculateTotalPrice()
            }
            
        }
        
    }
    
    // all selected items price calculator
    func calculateTotalPrice()->Double{
        
        var total = 0.0
        for (_, item) in self.modifiers.enumerated(){
            for(_, option) in item.option!.enumerated(){
                if option.selected!{
                    total = total + option.cost!
                }
            }
        }
        return total
    }
    
    func findModifierByID(_ modifier:Array<Modifier>, mID:Double)->(index:Int, options: Array<ModifierOption>)?{
        
        var modifierOption: Array<ModifierOption>? = []
        
        for (index, item) in modifier.enumerated(){
            if item.modifierItem?.modifierID == mID{
                
                for(_, option) in item.option!.enumerated(){
                    modifierOption?.append(option)
                }
                return (index,modifierOption!)
            }
        }
        return nil
    }
    
    func findOptionByID(_ option:Array<ModifierOption>, oID:Double)->(index:Int, status:Bool){
        
        for (index, item) in option.enumerated(){
            if item.modifierOptionID == oID{
                return (index, true)
            }
        }
        return (-1, false)
    }
    
    func updateItemByID(_ option: ModifierOption, mID:Double, isSelected:Bool, isSingleSelection:Bool)->Bool{
        
        if let optionItems = self.findModifierByID(self.modifiers, mID:mID){ // if modifier item exists
            
            let optionFinder = self.findOptionByID(optionItems.options, oID: option.modifierOptionID!)
            if let modifyOption = self.modifiers[optionItems.index].option{
                
                modifyOption[optionFinder.index].selected = isSelected
                
                if isSingleSelection{
                    for (optIndex, opt) in modifyOption.enumerated(){
                        if optIndex != optionFinder.index{
                            opt.selected = false
                        }
                    }
                }
                return true
            }
            
        }
        return false
    }
    
    //item with modifiers is added to product list & return the new product object
    func getUpdatedProductItemByID(_ id:String,productItem: Array<Product>, quantity:Int, price:Double, modifierFullName:String,itemTotal:Double)->Array<Product>{
        
        let prodArr = productItem
        for product in prodArr{
            
            if product.ProductID==id{
                product.ItemCount = quantity
                product.Price = price
                product.ItemTotalPrice = itemTotal
                product.modifierFullName = modifierFullName
            }
        }
        return prodArr
    }
    
    
    fileprivate func isAnyItemSelected()->Bool{
        
        for (index,_) in self.modifiers.enumerated(){
            for (_, option) in self.modifiers[index].option!.enumerated()   {
                if option.selected!{
                    return option.selected!
                }
            }
        }
        return false
    }

    func addItemByID(_ modifier:Array<Modifier>, option: ModifierOption, mID:Double, isSelected:Bool)->Bool{
        
        if let optionItems = self.findModifierByID(modifier, mID:mID){ // if modifier item exists
            let optionFinder = self.findOptionByID(optionItems.options, oID: option.modifierOptionID!)
            
            modifier[optionItems.index].option?.append(option)
            
            return true
            
        }
        return false
    }
    
    func removeItemByID(_ modifier:Array<Modifier>, option: ModifierOption, mID:Double)->(modifierItemIndex:Int,status:Bool){
        
        if let optionItems = self.findModifierByID(modifier, mID:mID){ // if modifier item exists
            let optionFinder = self.findOptionByID(optionItems.options, oID: option.modifierOptionID!)
            if optionFinder.status{ // if modifier option added already
                
                modifier[optionItems.index].option?.remove(at: optionFinder.index)
                
                return (optionItems.index,status:true)
            }
        }
        return (-1,status:false)
    }
    
    func emptyModifierByID(_ mID:Double){
        
        for (_, item) in self.modifiers.enumerated(){
            if item.modifierItem?.modifierID == mID{
                for(optionIndex, option) in item.option!.enumerated(){
                    item.option?.remove(at: optionIndex)
                }
            }
        }
    }

}
