//
//  SettingsViewController.swift
//  My First App
//
//  Created by Aiden Forrest on 04/07/2022.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Preload title
        let prevTitle = UserDefaults.standard.string(forKey: Keys.title)
        titleField.text = prevTitle
    }
    
    @IBAction func save(_ sender: Any) {
        // Set title based of input
        UserDefaults.standard.set(titleField.text!, forKey: Keys.title)
    }
    
    // Close keyboard when touching screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Close keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
