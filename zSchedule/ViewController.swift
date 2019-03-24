//
//  ViewController.swift
//  zSchedule
//
//  Created by Zavid Egbue on 08/03/2019.
//  Copyright © 2019 Zavid. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var tasks: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Detect long presses */
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        loadTasks()
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)

        /** Reload table data */
        loadTasks()
        tableView.reloadData()
    }
    
    
    /** Fetch all items from CoreData */
    func loadTasks(){
        tasks.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data)
                tasks.append(data)
            }
        } catch {
            print("Failed.")
        }
    }
    
    /** Delete task from CoreData */
    func deleteTask(task: NSManagedObject){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(task)
        
        do { try context.save() } catch { print(error) }
    }
    
    
    /** Bring up ActionSheet on long press */
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            
            let position = sender.location(in: tableView)
            
            if let index = tableView.indexPathForRow(at: position){
                
                let cell = tableView.cellForRow(at: index)
                
                let actionSheet: UIAlertController = UIAlertController(
                    title: cell?.textLabel?.text,
                    message: "What do you wish to do with this task?",
                    preferredStyle: .actionSheet
                )
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
                let editButton = UIAlertAction(title: "Edit", style: .default) { _ in
                    
                }
                let deleteButton = UIAlertAction(title: "Delete", style: .default) { _ in
                    self.deleteTask(task: self.tasks[index.row])
                    self.tasks.remove(at: index.row)
                    self.tableView.reloadData()
                }
                
                actionSheet.addAction(editButton)
                actionSheet.addAction(deleteButton)
                actionSheet.addAction(cancelButton)
                
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    /** Return number of tasks */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    /** Load tasks into tableView */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let title = task.value(forKey: "title") as! String
        let people = task.value(forKey: "people") as! String
        cell.textLabel?.text = "\(title) \(!people.isEmpty ? "w/\(people)" : "")"
        
        let dt = task.value(forKey: "date") as? Date
        
        let df1 = DateFormatter()
        let df2 = DateFormatter()
        let suffix = DateFormatter()
        df1.dateFormat = "EEEE"
        suffix.dateFormat = "d"
        df2.dateFormat = "MMMM YYYY"

        let former = df1.string(from: dt!)
        let dateOrdinal = getDateWithOrdinal(suffix.string(from: dt!))
        let latter = df2.string(from: dt!)
        
        let date = "\(former) \(dateOrdinal) \(latter)"
        
        cell.detailTextLabel?.text = date
        
        return cell
    }
    
    /** Retrieve the ordinal of chosen date */
    func getDateWithOrdinal(_ dt: String) -> String {
        var suffix = ""
        
        switch dt {
        case "1", "21", "31": suffix = "st";
        case "2", "22": suffix = "nd";
        case "3", "23": suffix = "rd";
        default: suffix = "th";
        }
        
        return "\(dt)\(suffix)"
    }

}

