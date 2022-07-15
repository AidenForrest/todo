//
//  AddItemViewController.swift
//  My First App
//
//  Created by Aiden Forrest on 05/07/2022.
//

import UIKit
import UserNotifications

class AddItemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var name: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Config textfield to close
        self.name.delegate = self
    }
    
    @IBAction func save(_ sender: Any) {
        // Make sure form is valid
        if name.text != "" {
            // Save item
            guard let todos = UserDefaults.standard.string(forKey: Keys.todos) else {return}
            var data = try! JSONDecoder().decode([Item].self, from: (todos.data(using: .utf8))!)
            var date = "None"
            var uuid = "None"
            // Format date (if toggled)
            if toggle.isOn {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d yyyy, h:mm a"
                let formatteddate = formatter.string(from: picker.date)
                date = formatteddate
                // Schedual notif
                let content = UNMutableNotificationContent()
                content.title = name.text!
                content.body = "The deadline for this item has reached!"
                content.sound = UNNotificationSound.default
                // Trigger
                uuid = UUID().uuidString
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: picker.date )
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
                // Add
                UNUserNotificationCenter.current().add(request)
            }
            data.append(Item(name: name.text!, deadline: date, uuid: uuid))
            let encoded = try! JSONEncoder().encode(data)
            let newItems = String(data: encoded, encoding: .utf8)!
            // Set data and return to home screen
            UserDefaults.standard.set(String(newItems), forKey: Keys.todos)
            // Refresh data on main screen
            NotificationCenter.default.post(name: Notification.Name("refresh"), object: nil)
            dismiss(animated: true)
        } else {
            // Alert user form is not vaild
            let alert = UIAlertController(title: "Error", message: "Please give item a name!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func toggeHasToggled(_ sender: Any) {
        // Show date picker whether toggle is selected
        if toggle.isOn {
            picker.isHidden = false
        } else {
            picker.isHidden = true
        }
    }
    
    // Close keyboard when touching screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Close keyboard when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
