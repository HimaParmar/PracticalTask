
import UIKit

class Validations: NSObject {
    
    static var sharedInstance = Validations()
    
    static func isEmptyField(fieldValue: String) -> Bool {
        let trimmed = fieldValue.trimmingCharacters(in: CharacterSet.whitespaces)
        return trimmed.isEmpty
    }
    
    static func validateEmailID(emailID: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailID)
        
    }
    
    static func validateMobileNumber(mobileNumber: String) -> Bool {
        return mobileNumber.contains("+91")
    }

    static func validatePassword(password: String) -> Bool {
        
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return emailPred.evaluate(with: password)
        
    }
    
    static func validateAgeFromDOB(birthday: String) -> Bool {
        return self.calcAge(birthday: birthday) > 18
    }
    
    static func validateUsername(str: String) -> Bool
    {
        do
        {
            let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z\\_]{4,20}$", options: .caseInsensitive)
            if regex.matches(in: str, options: [], range: NSMakeRange(0, str.count)).count > 0 {return true}
        }
        catch {}
        return false
    }
    
    //static func validateDOB()
    
    static func calcAge(birthday: String) -> Int{
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate! = NSDate()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now as Date, options: [])
        guard let age = calcAge.year else { return 0 }
        return age
    }


}
