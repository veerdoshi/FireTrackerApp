//
//  LoginViewController.swift
//  firetracker
//
//  Created by Veer Doshi on 3/8/19.
//  Copyright © 2019 Veer Doshi. All rights reserved.
//

import UIKit
import ContactsUI

class LoginViewController: UIViewController, CNContactPickerDelegate {

//    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

            
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func contactButtonPressed(_ sender: Any) {
        onClickPickContact()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FireViewController") as UIViewController
        present(vc, animated: false, completion: nil)
    }
    
    
//    UserDefaults.standard.set(nameTextField.text ?? "", forKey: "name")
//    print(UserDefaults.standard.string(forKey: "name"))
    
    
    
    
    func onClickPickContact(){
        
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {
        
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let userName:String = contact.givenName
        //print(userName)
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:String = (userPhoneNumbers[0].value).stringValue
        let removedSpaceString:String = firstPhoneNumber.removeWhitespace()
        let removedDashesString:String = removedSpaceString.removeDashes()
        let removedParenthesis1String:String = removedDashesString.removeParenthesis1()
        let removedParenthesis2String:String = removedParenthesis1String.removeParenthesis2()
        let finalPhoneNumber: String = removedParenthesis2String
        //print(finalPhoneNumber)
        contactWasSelected(name: userName, phonenumber: finalPhoneNumber)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("SAD")
    }
    
    func contactWasSelected (name: String, phonenumber: String) {
        UserDefaults.standard.set(name, forKey: "name")
        print(UserDefaults.standard.string(forKey: "name"))
        
        
        UserDefaults.standard.set(phonenumber, forKey: "phonenumber")
        print(UserDefaults.standard.string(forKey: "phonenumber"))
        
        
        
//        print("THIS IS THE NAME")
//        print(name)
//        print("THIS IS THE PHONE NUMBER")
//        print(phonenumber)
    }
    
    

}


extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    func removeDashes() -> String {
        return self.replace(string: "-", replacement: "")
    }
    func removeParenthesis1() -> String {
        return self.replace(string: "(", replacement: "")
    }
    func removeParenthesis2() -> String {
        return self.replace(string: ")", replacement: "")
    }
}
