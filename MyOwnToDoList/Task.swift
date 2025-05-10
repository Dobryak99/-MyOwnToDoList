//
//  Task.swift
//  MyOwnToDoList
//
//  Created by Никита Журавлев on 04.05.2025.
//

import Foundation

struct Task: Codable{
    var title: String
    var isDone: Bool = false
    var shouldRemind: Bool = false
    var date: Date?
    var notificationID: UUID = UUID()
}
