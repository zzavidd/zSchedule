//
//  ViewController.swift
//  zSchedule
//
//  Created by Zavid Egbue on 08/03/2019.
//  Copyright © 2019 Zavid. All rights reserved.
//

import UIKit
import CoreData

/** Create model of event item */
struct Item {
    let id: NSManagedObject
    let title: String
    let people: String
    let location: String
    let finished: Bool
    let date: Date
    let time: Bool
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var tasks = [[NSManagedObject]]()
    var sections: [String] = []
    var selectedIndexSection = 0
    var selectedIndexRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItem" {
            let secondViewController = segue.destination as! SecondViewController
            let selectedTask = tasks[selectedIndexSection][selectedIndexRow]
            
            let title = selectedTask.value(forKey: "title") as! String
            let people = selectedTask.value(forKey: "people") as! String
            let location = selectedTask.value(forKey: "location") as! String
            let finished = selectedTask.value(forKey: "finished") as? Bool
            let date = selectedTask.value(forKey: "date") as! Date
            let time = selectedTask.value(forKey: "time") as? Bool
            
            let item = Item (
                id: selectedTask,
                title: title,
                people: people,
                location: location,
                finished: finished ?? false,
                date: date,
                time: time ?? true
            )
            
            secondViewController.item = item
        }
    }
    
    /** Fetch all items from CoreData */
    func loadTasks(){
        tasks.removeAll()
        sections.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            let df = DateFormatter()
            df.dateFormat = "MMMM YYYY"
            
            var tasksByMonth = [NSManagedObject]()
            
            /** Populate two-dimensional array grouped by month */
            for task in result as! [NSManagedObject] {
                let date = task.value(forKey: "date") as? Date
                let month = df.string(from: date!)
                
                if !sections.contains(month){
                    if (sections.count > 0){
                        tasks.append(tasksByMonth)
                        tasksByMonth = [NSManagedObject]()
                    }
                    sections.append(month)
                }
        
                tasksByMonth.append(task)
            }
            
            tasks.append(tasksByMonth)
            
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
                    self.selectedIndexSection = index.section
                    self.selectedIndexRow = index.row
                    self.performSegue(withIdentifier: "editItem", sender: self)
                }
                let deleteButton = UIAlertAction(title: "Delete", style: .default) { _ in
                    self.deleteTask(task: self.tasks[index.section][index.row])
                    self.tasks[index.section].remove(at: index.row)
                    self.loadTasks()
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
        return tasks[section].count
    }
    
    /** Return the cell at particular index */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let title = task.value(forKey: "title") as! String
        let people = task.value(forKey: "people") as! String
        let time = task.value(forKey: "time") as? Bool
        cell.textLabel?.text = "\(title) \(!people.isEmpty ? "(w. \(people))" : "")"
        
        let dt = task.value(forKey: "date") as? Date
        
        let df1 = DateFormatter()
        let df2 = DateFormatter()
        let suffix = DateFormatter()
        df1.dateFormat = "EEEE"
        suffix.dateFormat = "d"
        df2.dateFormat = (time ?? true) ? "MMMM YYYY - HH:mm" : "MMMM YYYY"

        let former = df1.string(from: dt!)
        let dateOrdinal = getDateWithOrdinal(suffix.string(from: dt!))
        let latter = df2.string(from: dt!)
        
        let date = "\(former) \(dateOrdinal) \(latter)"
        
        cell.detailTextLabel?.text = date
        
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
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


/** Hide keyboard on touches */
extension UIViewController {
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
