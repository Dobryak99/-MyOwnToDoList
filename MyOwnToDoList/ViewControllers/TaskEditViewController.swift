//
//  TaskEditViewController.swift
//  MyOwnToDoList
//
//  Created by Никита Журавлев on 08.05.2025.
//

import UIKit

protocol TaskEditViewControllerDelegate: AnyObject{
    func taskEditViewController(_ controller: TaskEditViewController, didCreate task: Task)
    func taskEditViewController(_ controller: TaskEditViewController, didUpdate task: Task, at indexPath: IndexPath)
}


class TaskEditViewController: UITableViewController{
    //MARK: - Variables
    private let titleField = UITextField()
    private let remindSwitch = UISwitch()
    private let datePicker = UIDatePicker()
    
    var taskToEdit: Task?
    var editingIndexPath: IndexPath?
    
    weak var delegate: TaskEditViewControllerDelegate?
    
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title =  taskToEdit == nil ? "New Task" : "Edit Task"
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        
        if let task = taskToEdit{
            titleField.text = task.title
            remindSwitch.isOn = task.shouldRemind
            if let date = task.date{
                datePicker.date = date
            }else{
                datePicker.date = .now
            }
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        titleField.becomeFirstResponder()
        setupNavigationBar()
    }
    
    private func setupNavigationBar(){
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTask))
    }
    
    private func notifyDelegateAndPop(task: Task){
        if let index = editingIndexPath{
            delegate?.taskEditViewController(self, didUpdate: task, at: index)
        }else{
            delegate?.taskEditViewController(self, didCreate: task)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlertUnableNotify(){
        let alert = UIAlertController(title: "Notification Disabled", message: "Please enable notifications in Settings to receive reminders.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc private func saveTask(){
        //Check for edit task
        if var oldTask = taskToEdit {
            guard let text = titleField.text, !text.isEmpty else {return}
            
            oldTask.title = text
            oldTask.shouldRemind = remindSwitch.isOn ? true : false
            oldTask.date = datePicker.date
            
            if oldTask.shouldRemind{
                NotificationCenter.shared.requestAuthorizationIfNeeded{ granted in
                    if granted{
                        guard let date = oldTask.date, date > Date() else {
                            self.remindSwitch.setOn(false, animated: true)
                            
                            //Alert here.
                            self.showAlertUnableNotify()
                            return
                        }
                        NotificationCenter.shared.scheduleNotification(for: oldTask)
                        self.notifyDelegateAndPop(task: oldTask)
                    }else{
                        self.remindSwitch.setOn(false, animated: true)
                        
                        //Alert here.
                        self.showAlertUnableNotify()
                        return
                    }
                }
            }else{
                NotificationCenter.shared.removeNotification(for: oldTask)
                notifyDelegateAndPop(task: oldTask)
            }
            
        }else{
            //Completely new task
            guard let text = titleField.text, !text.isEmpty else {return}
            
            let newTask = remindSwitch.isOn ? Task(title: text, shouldRemind: true, date: datePicker.date) : Task(title: text,date: datePicker.date)
            
            if newTask.shouldRemind{
                NotificationCenter.shared.requestAuthorizationIfNeeded{ granted in
                    if granted{
                        guard let date = newTask.date, date > Date() else {
                            self.remindSwitch.setOn(false, animated: true)
                            
                            //Alert here.
                            self.showAlertUnableNotify()
                            return
                        }
                        NotificationCenter.shared.scheduleNotification(for: newTask)
                        self.notifyDelegateAndPop(task: newTask)
                    }else{
                        self.remindSwitch.setOn(false, animated: true)
                        
                        //Alert here.
                        self.showAlertUnableNotify()
                        return
                    }
                }
            }else{
                NotificationCenter.shared.removeNotification(for: newTask)
                notifyDelegateAndPop(task: newTask)
            }
        }
        
        
    }
    
    
}

extension TaskEditViewController{
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Task title" : "Status"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        if indexPath.section == 0{
            switch indexPath.row{
            case 0:
                titleField.placeholder = "Enter title"
                titleField.translatesAutoresizingMaskIntoConstraints = false
                
                cell.contentView.addSubview(titleField)
                
                NSLayoutConstraint.activate([
                    titleField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    titleField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    titleField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    titleField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    titleField.heightAnchor.constraint(equalToConstant: 44)
                ])
            case 1:
                cell.textLabel?.text = "Date:"
                cell.accessoryView = datePicker
            default: break
            }
        }else{
            cell.textLabel?.text = "Remind Me:"
            cell.accessoryView = remindSwitch
        }
        
        return cell
    }
}
