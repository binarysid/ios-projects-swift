
import UIKit
import Alamofire
import AlamofireObjectMapper

// mutiple selection delegate
protocol ModifierItemDelegate:NSObjectProtocol{
    func optionSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String, isSingleSelection:Bool)
}

// Single selection delegate
protocol ModifierSingleItemDelegate:NSObjectProtocol{
    func singleOptionSelected(_ state: Bool,modifierItem: ModifierItem,option: ModifierOption, type:String, isSingleSelection:Bool)
}

class ModifierItemVC: UIViewController,UITableViewDataSource, UITableViewDelegate,CellSelectionDelegate,CellSingleSelectionDelegate {
   
    @IBOutlet weak var productTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var modifiers: Array<Modifier> = []
    var modifierTotalPrice:Double = 0.0
    var itemCount:Int = 0
    var modifierItem: ModifierItem?
    var option: Array<ModifierOption>?
    var viewType:ModifierViewType?
    weak fileprivate var modifierDelegate: ModifierItemDelegate?
    weak fileprivate var modifierSingleItemDelegate: ModifierSingleItemDelegate?
    //private var viewModel: ModifierViewModel?
    var radioOptions:Array<DownStateButton> = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.titleBar()
        self.productTitle.text = self.modifierItem?.modifierName! ?? ""
        //self.option?.append(ModifierOption(productID: "", modifierID: 0, modifierOptionID: 0, optionName: "", cost: 0.0))
        self.tableView.register(FullViewMultiSelectionCell.nib, forCellReuseIdentifier: FullViewMultiSelectionCell.identifier)
        self.tableView.register(FullViewSingleSelectionCell.nib, forCellReuseIdentifier: FullViewSingleSelectionCell.identifier)
        self.tableView.rowHeight = 57
    }
    
    
    func attachMuiltiItemDelegate(_ delegate:ModifierItemDelegate){
        self.modifierDelegate = delegate
    }
    
    func attachSingleItemDelegate(_ delegate:ModifierSingleItemDelegate){
        self.modifierSingleItemDelegate = delegate
    }
    
    // multiple cell selection delegate method
    func didSelectCellItem(_ state: Bool,modifierItem: ModifierItem, option: ModifierOption, type:String) {
        
        if self.option != nil{
            option.selected = state
            self.modifierDelegate!.optionSelected(state, modifierItem:modifierItem, option: option, type:type,isSingleSelection:false)
        }
    }
    
    // single cell selection delegate method
    func didSelectSingleCellItem(_ state: Bool, modifierItem: ModifierItem, option: ModifierOption, type: String) {

        if self.option != nil{
            option.selected = state
            self.modifierSingleItemDelegate?.singleOptionSelected(state, modifierItem: modifierItem, option: option, type: type, isSingleSelection: true)
            
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // check view selection type
        if let viewSelectionType = self.viewType{
            switch viewSelectionType{
                
        case .ComponentViewSingleSelectionType:
        let cell : FullViewSingleSelectionCell = tableView.dequeueReusableCell(withIdentifier: FullViewSingleSelectionCell.identifier, for: indexPath) as! FullViewSingleSelectionCell
        cell.selectedOption.isSelected = !cell.selectedOption.isSelected

        if let modifierOption = self.option{
            modifierOption[indexPath.row].selected = cell.selectedOption.isSelected
            self.modifierSingleItemDelegate?.singleOptionSelected(cell.selectedOption.isSelected, modifierItem: modifierItem!, option: modifierOption[indexPath.row], type: self.viewType!.rawValue, isSingleSelection: true)

        }
         
        case .ComponentViewMultiSelectionType:
        let cell : FullViewMultiSelectionCell = tableView.dequeueReusableCell(withIdentifier: FullViewMultiSelectionCell.identifier, for: indexPath) as! FullViewMultiSelectionCell
        cell.selectedOption.modifierItem = modifierItem
        
        cell.selectedOption.viewType = self.viewType!.rawValue
        if let modifierOption = self.option{
            cell.selectedOption.option = modifierOption[indexPath.row]
            cell.selectedOption.isSelected = !modifierOption[indexPath.row].selected!
            modifierOption[indexPath.row].selected = cell.selectedOption.isSelected
            self.modifierDelegate!.optionSelected(cell.selectedOption.isSelected, modifierItem:self.modifierItem!, option: modifierOption[indexPath.row], type:self.viewType!.rawValue,isSingleSelection:false)
            
        }
            default:
                break
            }
        }
        
        DispatchQueue.main.async(execute: {
            self.tableView?.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let modifierOption = self.option{
            return modifierOption.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let viewSelectionType = self.viewType{
            switch viewSelectionType{
            case .ComponentViewMultiSelectionType:
            let cell : FullViewMultiSelectionCell = self.tableView.dequeueReusableCell(withIdentifier: FullViewMultiSelectionCell.identifier, for: indexPath) as! FullViewMultiSelectionCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            if let modifierOption = self.option{
            
                cell.modifierName.text = modifierOption[indexPath.row].optionName
                if !modifierOption[indexPath.row].noCost!{
                    //cell.price.text = "+" + Resources.sharedInstance.currency + modifierOption[indexPath.row].cost!.roundToPlaces(2).twoDigitString()
                }
                else{
                    cell.price.text = ""
                }
                
                cell.selectedOption.isSelected = modifierOption[indexPath.row].selected!
                cell.cellDelegate = self
                cell.selectedOption.modifierItem = self.modifierItem
                cell.selectedOption.option = modifierOption[indexPath.row]
                cell.selectedOption.viewType = ModifierViewType.FullViewMultiSelectionType.rawValue
                
                
            }
            return cell
                
            case .ComponentViewSingleSelectionType:
                let cell : FullViewSingleSelectionCell = self.tableView.dequeueReusableCell(withIdentifier: FullViewSingleSelectionCell.identifier, for: indexPath) as! FullViewSingleSelectionCell
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                if let modifierOption = self.option{
                    
                    cell.modifierName.text = modifierOption[indexPath.row].optionName
                    if !modifierOption[indexPath.row].noCost!{
                        //cell.price.text = "+" + Resources.sharedInstance.currency + modifierOption[indexPath.row].cost!.roundToPlaces(2).twoDigitString()
                    }
                    else{
                        cell.price.text = ""
                    }
                    
                    cell.selectedOption.isSelected = modifierOption[indexPath.row].selected!
                    cell.cellDelegate = self
                    cell.selectedOption.modifierItem = self.modifierItem
                    cell.selectedOption.option = modifierOption[indexPath.row]
                    cell.selectedOption.viewType = ModifierViewType.FullViewMultiSelectionType.rawValue
                    self.radioOptions.append(cell.selectedOption)
                    if indexPath.row == modifierOption.count-1{
                        
                        for (_,radioOption) in self.radioOptions.enumerated(){
                            radioOption.alternateButton = self.radioOptions.filter{ $0 != radioOption}
                        }
                        
                    }

                    
                }
                return cell
                
            default:
                break
            }
        }
        return UITableViewCell()
    }
    

    @IBAction func onContinue(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

