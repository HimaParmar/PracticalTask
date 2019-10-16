
import UIKit
import CoreData

let alert_general = "Please fill out all details"
let alert_username = "User name should be minimum 4 character long and should not include special characters"
let alert_emailID = "Please enter valid email ID"
let alert_age = "Your age should be 18+"
let alert_mobile = "Please enter mobile number with valid country code. \n Example: +91**********"
let alert_password = "Password should contain mimimum 8 characters with at-least 1 capital character and 1 digit"

class ViewController: UIViewController {
    
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    //Local data storage
    
    var userData = User.init(us_dateofbirth: "", us_email: "", us_fullname: "", us_mobilenumber: "", us_username: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFullName.delegate = self
        txtMobileNumber.delegate = self
        
        context = appDelegate.persistentContainer.viewContext
       
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        txtDOB.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        //Fetch Data from core data
        self.fetchData()

    }
    
    //If there will be no user in core data then this function will be called
    
    func loadViewWhenThereIsNoUser() {
        
        btnRegister.isHidden = false
        self.view.isUserInteractionEnabled = true
        btnLogout.isHidden = true
        
        self.setUserData()

    }
    
    //If there will be user in core data then this function will be called

    func loadViewWhenThereIsUser() {
        
        btnRegister.isHidden = true
        self.view.isUserInteractionEnabled = false
        btnLogout.isHidden = false
        
        self.setUserData()
        
    }
    
    // setting textfields
    
    func setUserData() {
        
        txtDOB.text =  userData.us_dateofbirth
        txtEmail.text = userData.us_email
        txtFullName.text = userData.us_fullname
        txtMobileNumber.text = userData.us_mobilenumber
        txtUserName.text = userData.us_username
        txtPassword.text = DAKeychain.shared["password"]
        
    }
    
   

    @IBAction func btnRegisterClicked(_ sender: Any) {
        
       if self.validateInputs() {
            
        // stores data in local object
        
        userData = User.init(us_dateofbirth: txtDOB.text ?? "", us_email: txtEmail.text ?? "", us_fullname: txtFullName.text ?? "", us_mobilenumber: txtMobileNumber.text ?? "", us_username: txtUserName.text ?? "")
            print(userData.us_dateofbirth)
        
        // stores password in keychain
            
        DAKeychain.shared["password"] = txtPassword.text ?? "" // Store
            
        // stores value in core data
        openCoreDatabse()
            
            
       }
        
    }
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        
        // clears core data entity
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LoggedInUser")
        _ = NSBatchDeleteRequest(fetchRequest: fetch)
        
        // clears local data
        userData = User.init(us_dateofbirth: "", us_email: "", us_fullname: "", us_mobilenumber: "", us_username: "")
        
        // clears keychain data
        Keychain.logout()
        
        //loads local values
        loadViewWhenThereIsNoUser()
    }
    
}

//MARK: DatePicker Extension

extension ViewController {
    
    @objc func handleDatePicker(sender: UIDatePicker) {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd/MM/yyyy"
           txtDOB.text = dateFormatter.string(from: sender.date)
    }
    
}

//MARK: Register User Extension


extension ViewController {
    
    func validateInputs() -> Bool {
        
        if Validations.isEmptyField(fieldValue: txtDOB.text ?? "") ||
            Validations.isEmptyField(fieldValue: txtUserName.text ?? "") || Validations.isEmptyField(fieldValue: txtMobileNumber.text ?? "") || Validations.isEmptyField(fieldValue: txtFullName.text ?? "") || Validations.isEmptyField(fieldValue: txtEmail.text ?? "") || Validations.isEmptyField(fieldValue: txtPassword.text ?? "") {
            self.displayAlertControllerWithMessage(messageString: alert_general)
            return false
        }else if !Validations.validateUsername(str: txtUserName.text ?? "") {
            self.displayAlertControllerWithMessage(messageString: alert_username)
            return false
        }else if !Validations.validateEmailID(emailID: txtEmail.text ?? "") {
            self.displayAlertControllerWithMessage(messageString: alert_emailID)
            return false
        }else if !Validations.validateAgeFromDOB(birthday: txtDOB.text ?? "") {
            self.displayAlertControllerWithMessage(messageString: alert_age)
            return false
        }else if !Validations.validateMobileNumber(mobileNumber: txtMobileNumber.text ?? "") {
            self.displayAlertControllerWithMessage(messageString: alert_mobile)
            return false
        }else if !Validations.validatePassword(password: txtPassword.text ?? "") {
            self.displayAlertControllerWithMessage(messageString: alert_password)
            return false
        }
        
        return true
    }
    
    func displayAlertControllerWithMessage(messageString: String) {
        
        let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
          
        })
        self.present(alertController, animated: true, completion: nil)
        
    }
}


//MARK: Textfield delegate Extension


extension ViewController: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtFullName {
            return range.location < 50 // full name greater than 50 will not be allowed
        }else if textField == txtMobileNumber {
            return range.location < 13 // mobile number greater than 13 will not be allowed
        }else if textField == txtUserName {
            return range.location < 20 // user name greater than 20 will not be allowed
        }
        
        return true
    }
    
}

//MARK: Coredata Extension

extension ViewController {
    
    // MARK: Methods to Open, Store and Fetch data
    
    func openCoreDatabse()
    {
        context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LoggedInUser", in: context)
        let loggedInUser = NSManagedObject(entity: entity!, insertInto: context)
        saveData(UserDBObj:loggedInUser)
        
    }
    
    func saveData(UserDBObj:NSManagedObject)
    {
        //storing data to core data
        
        UserDBObj.setValue(userData.us_dateofbirth , forKey: "us_dateofbirth")
        UserDBObj.setValue(userData.us_email, forKey: "us_email")
        UserDBObj.setValue(userData.us_fullname, forKey: "us_fullname")
        UserDBObj.setValue(userData.us_mobilenumber, forKey: "us_mobilenumber")
        UserDBObj.setValue(userData.us_username, forKey: "us_username")


        print("Storing Data to coredata")
        
        do {
            try context.save()
        } catch {
            print("Storing data Failed")
        }

        fetchData()
    }
    
    func fetchData()
    {

        print("Fetching Data from core data")
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "LoggedInUser")
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try context.fetch(request)
            
            if result.count > 0 {
                print(result)
                for data in result {
                    
                    userData.us_dateofbirth = data.value(forKey: "us_dateofbirth") as! String
                    userData.us_email = data.value(forKey: "us_email") as! String
                    userData.us_fullname = data.value(forKey: "us_fullname") as! String
                    userData.us_mobilenumber = data.value(forKey: "us_mobilenumber") as! String
                    userData.us_username = data.value(forKey: "us_username") as! String
                    
                    loadViewWhenThereIsUser()
                    
                }
            }else {
                //No data stored
                loadViewWhenThereIsNoUser()
            }
            
        } catch {
            print("Fetching data from coredata Failed")
        }
    }
    
}

//MARK: UIBarButton Extension

extension UIBarButtonItem {

    var isHidden: Bool {
        get {
            return tintColor == .clear
        }
        set {
            tintColor = newValue ? .clear : .white 
            isEnabled = !newValue
            isAccessibilityElement = !newValue
        }
    }

}

//MARK: Keychain Extension

public class Keychain: NSObject {
  public class func logout()  {
    let secItemClasses =  [
      kSecClassGenericPassword,
      kSecClassInternetPassword,
    ]
    for itemClass in secItemClasses {
      let spec: NSDictionary = [kSecClass: itemClass]
      SecItemDelete(spec)
    }
  }
}


