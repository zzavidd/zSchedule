//
//  ViewController.swift
//  zSchedule
//
//  Created by Zavid Egbue on 08/03/2019.
//  Copyright © 2019 Zavid. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var taskTitle: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
    }
    
    func save(alert: UIAlertAction!){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Title", in: context)!
        
        let title = NSManagedObject(entity: entity, insertInto: context)
        title.setValue(titleTextField.text, forKey: "title")
        
        do {
            try context.save()
            taskTitle.append(title)
        } catch {
            print("Error")
        }
        
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let title = taskTitle[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = title.value(forKey: "title") as? String
        return cell
    }

}

