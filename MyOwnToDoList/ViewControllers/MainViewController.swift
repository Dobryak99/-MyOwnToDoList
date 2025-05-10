//
//  ViewController.swift
//  MyOwnToDoList
//
//  Created by Никита Журавлев on 04.05.2025.
//

import UIKit

class MainViewController: UITableViewController {
    //MARK: - Variables
    let mainCellTitle = "MainCell"
    private let tasksKey = "tasks"
    
    var activeTasks: [Task] = []
    var completedTasks: [Task] = []
    
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        loadTasks()
    }
    
    
    //Settings for main screen
    func setupTableView(){
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        title = "Tasks"
        tableView.register(TaskCell.self, forCellReuseIdentifier: mainCellTitle)
    }
    
    //Settings for navigation bar
    func setupNavigationBar(){
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editList))
        navigationItem.rightBarButtonItems = [addButton, editButton]
        navigationController?.navigationBar.tintColor = .black
    }
    
    func saveTasks(){
        let allTasks = activeTasks + completedTasks
        if let data = try? JSONEncoder().encode(allTasks){
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }
    
    private func loadTasks(){
        if let data = UserDefaults.standard.data(forKey: tasksKey),
            let savedTasks = try? JSONDecoder().decode([Task].self, from: data){
                activeTasks = savedTasks.filter {!$0.isDone}
                completedTasks = savedTasks.filter {$0.isDone}
            }
    }
    
    @objc func addTask(){
        let vc = TaskEditViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func editList(){
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
}


extension MainViewController: TaskEditViewControllerDelegate, TaskCellDelegate{
    
    //MARK: - Table View Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = indexPath.section == 0 ? activeTasks[indexPath.row] : completedTasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: mainCellTitle, for: indexPath) as! TaskCell
        
        cell.accessoryType = .disclosureIndicator
        cell.titleLabel.text = task.title
        cell.isCompleted = task.isDone
        cell.delegate = self
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? activeTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "IN PROGRESS" : "DONE"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {return}
        
        tableView.beginUpdates()
        if indexPath.section == 0{
            NotificationCenter.shared.removeNotification(for: activeTasks[indexPath.row])
            activeTasks.remove(at: indexPath.row)
        }else{
            NotificationCenter.shared.removeNotification(for: completedTasks[indexPath.row])
            completedTasks.remove(at: indexPath.row)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveTasks()
        tableView.endUpdates()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task: Task
        
        if indexPath.section == 0{
            task = activeTasks[indexPath.row]
        }else{
            task = completedTasks[indexPath.row]
        }
        
        let vc = TaskEditViewController()
        vc.taskToEdit = task
        vc.delegate = self
        vc.editingIndexPath = indexPath
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section == 0, destinationIndexPath.section == 0 else {
            tableView.reloadData()
            return
        }
        
        let movedTask = activeTasks.remove(at: sourceIndexPath.row)
        activeTasks.insert(movedTask, at: destinationIndexPath.row)
        saveTasks()
    }
    
    
    func taskEditViewController(_ controller: TaskEditViewController, didCreate task: Task) {
        tableView.beginUpdates()
        
        if task.isDone{
            completedTasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }else{
            activeTasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        saveTasks()
        tableView.endUpdates()
    }
    
    func taskEditViewController(_ controller: TaskEditViewController, didUpdate task: Task, at indexPath: IndexPath) {
        if indexPath.section == 0{
            activeTasks.remove(at: indexPath.row)
        }else{
            completedTasks.remove(at: indexPath.row)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if task.isDone{
            completedTasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }else{
            activeTasks.insert(task, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        saveTasks()
        tableView.reloadData()
    }
    
    func didToggleCompletion(in cell: TaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        
        tableView.beginUpdates()
        
        if indexPath.section == 0{
            let task = activeTasks.remove(at: indexPath.row)
            var temp = task
            temp.isDone = true
            completedTasks.insert(temp, at: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }else{
            let task = completedTasks.remove(at: indexPath.row)
            var temp = task
            temp.isDone = false
            activeTasks.insert(temp, at: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        saveTasks()
        tableView.endUpdates()
    }
    
}

