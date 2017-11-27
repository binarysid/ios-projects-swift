
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
    
    private func getTotalPriceFromUpdatedModifier(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String,isSingleSelection:Bool)->Double{
        
        guard let modelView = self.viewModel else{
            return self.totalPrice
        }
        guard let priceSum = modelView.editModifiers(state,modifierItem:modifierItem,option: option,isSingleSelection:isSingleSelection) else{
            return self.totalPrice
        }
        self.updateTableView()
        
        return priceSum
    }
    
    func optionSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String,isSingleSelection:Bool){ // for component view options
        
        self.totalPrice = getTotalPriceFromUpdatedModifier(state,modifierItem:modifierItem,option: option, type: type,isSingleSelection:isSingleSelection)

    }
    
    func singleOptionSelected(_ state: Bool, modifierItem: ModifierItem, option: ModifierOption, type: String, isSingleSelection: Bool) { // component view page radio option item selection checker
        
        self.totalPrice = getTotalPriceFromUpdatedModifier(state,modifierItem:modifierItem,option: option, type: type,isSingleSelection:isSingleSelection)
        
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
        
        self.totalPrice = getTotalPriceFromUpdatedModifier(state,modifierItem:modifierItem,option: option, type: type,isSingleSelection:false)

    }
    
    func singleItemSelected(_ state: Bool, modifierItem: ModifierItem, option: ModifierOption, type: String) {
        
        self.totalPrice = getTotalPriceFromUpdatedModifier(state,modifierItem:modifierItem,option: option, type: type,isSingleSelection:true)

    }
    
    fileprivate func updateTableView(){
        
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
        })
    }
    
    
    func showLoader() {
        //self.showLoadingHUD()
    }
    
    func hideLoader() {
        //self.hideLoadingHUD()
    }
    
    func refreshData(_ price:Double, quantity:Int,modifiers: Array<Modifier>,showPageTitle:Bool) {
        
        self.modifierFixedPrice = price
        self.totalPrice = price
        self.itemCount = quantity
        self.showPageTitle = showPageTitle
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
        })
    }
    
    func refreshDataFromLocalDB(_ price: Double, itemTotal: Double, quantity: Int, modifiers: Array<Modifier>) {
        
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
        
        //self.addAllModifiers()
        guard let modelView = self.viewModel else{
            return
        }
        self.modifierFullName = modelView.addAllModifiers(modifierName: self.modifierFullName)
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


