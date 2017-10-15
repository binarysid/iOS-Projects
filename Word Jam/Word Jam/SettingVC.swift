//
//  SettingVC.swift
//  Word Jam
//
//  Created by MacBook Air on 15/10/2017.
//  Copyright © 2017 StatUp. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    let userData = DataStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Resources.appBackgroundColor
        self.nameTextField.backgroundColor =  Resources.textFieldBackgroundColor
        // Do any additional setup after loading the view.
    }
    @IBAction func onSaveName(_ sender: UIButton) {
        
        if self.nameTextField.text?.isEmpty == false {
            userData.setUserName(name: self.nameTextField.text!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameTextField.text = userData.getUserName()
        self.setNavigationBarItem()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: textField.frame.origin.y/2-50)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        animateViewMoving(up: true, moveValue: -(textField.frame.origin.y/2-50))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
