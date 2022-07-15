//
//  ViewController.swift
//  My First App
//
//  Created by Aiden Forrest on 29/12/2021.
//

import UIKit
import Foundation
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Request notif perms
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error  {
                print(error.localizedDescription)
            }
        }
        
        // Check if user is first time
        let firstTime = UserDefaults.standard.bool(forKey: Keys.firstime)
        if firstTime != true {
            // Create inital data
            UserDefaults.standard.set(true, forKey: Keys.firstime)
            UserDefaults.standard.set("TODO", forKey: Keys.title)
            let items = [Item(name: "Example Item", deadline: "None", uuid: "None"),
                         Item(name: "Another Example Item", deadline: "None", uuid: "None")]
            let data = try! JSONEncoder().encode(items)
            let startingItems = String(data: data, encoding: .utf8)!
            UserDefaults.standard.set(startingItems, forKey: Keys.todos)
        }
        
        // Setup table
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
        // NOTIFS
        // refreshing table
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("refresh"), object: nil)
    }
    
    // Refresh
    @objc func refresh (notification: NSNotification){
        tableView.reloadData()
    }
    
    // Getting view ready when returning from settings or add item
    override func viewWillAppear(_ animated: Bool) {
        let setTitle = UserDefaults.standard.string(forKey: Keys.title)
        titleText.text = setTitle
        tableView.reloadData()
    }
    
    // Dragging
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let todos = UserDefaults.standard.string(forKey: Keys.todos)
        let decoded = try! JSONDecoder().decode([Item].self, from: (todos?.data(using: .utf8))!)
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = decoded[indexPath.row]
        return [ dragItem ]
    }
    
    // Dragging
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let todos = UserDefaults.standard.string(forKey: Keys.todos)
        var decoded = try! JSONDecoder().decode([Item].self, from: (todos?.data(using: .utf8))!)
        let mover = decoded.remove(at: sourceIndexPath.row)
        decoded.insert(mover, at: destinationIndexPath.row)
    }
    
    // Number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let todos = UserDefaults.standard.string(forKey: Keys.todos)
        let decoded = try! JSONDecoder().decode([Item].self, from: (todos?.data(using: .utf8))!)
        return decoded.count
    }
    
    // Setting up rows based off data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todos = UserDefaults.standard.string(forKey: Keys.todos)
        let decoded = try! JSONDecoder().decode([Item].self, from: (todos?.data(using: .utf8))!)
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        cell.textLabel?.text = decoded[indexPath[1]].name
        cell.detailTextLabel?.text = decoded[indexPath.row].deadline
        return cell
    }
    
    // Removing
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todos = UserDefaults.standard.string(forKey: Keys.todos)
            var decoded = try! JSONDecoder().decode([Item].self, from: (todos?.data(using: .utf8))!)
            let uuid = decoded[indexPath.row].uuid
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
               var identifiers: [String] = []
               for notification:UNNotificationRequest in notificationRequests {
                   if notification.identifier == uuid {
                      identifiers.append(notification.identifier)
                   }
               }
               UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
            decoded.remove(at: indexPath[1])
            let encoded = try! JSONEncoder().encode(decoded)
            UserDefaults.standard.set(String(decoding: encoded, as: UTF8.self), forKey: Keys.todos)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}
