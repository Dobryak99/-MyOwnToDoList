# 📝 To-Do List App (UIKit, Manual UI)

A simple and elegant To-Do List app built in Swift using **UIKit without Storyboards**. Focused on manual UI layout, clean architecture, local notifications, and a smooth user experience.

---

## 📸 Screenshots

| Main Screen | Edit Task | Notification |
|-------------|------------|--------------|
| ![MainScreen]([https://link-to-main-screen.png](https://github.com/Dobryak99/-MyOwnToDoList/blob/main/screenshots/main.png)) | ![EditTask](https://link-to-edit-screen.png) | ![Notification](https://link-to-notification.png) |


https://github.com/Dobryak99/-MyOwnToDoList/blob/main/screenshots/main.png
---

## 🔧 Features

- ✅ Create, edit, and complete tasks  
- 🕓 Reminder support via `UNUserNotificationCenter`  
- 🧠 Simple architecture with delegates and a unified editing controller  
- 📦 Local data storage with `UserDefaults`  
- 📂 Tasks organized into **Active** and **Completed** sections  
- 🧱 Fully manual UIKit UI (no Interface Builder)

## 🧠 Reminder Logic
Notification permission is requested only when the user first enables the "Remind Me" switch

All reminders are scheduled with UNUserNotificationCenter, using a unique task UUID as the identifier

Editing a task updates its reminder

Turning off the reminder or deleting a task cancels its associated notification

## 🛠️ Built With
- Swift 5+

- UIKit (programmatic UI)

- UNUserNotificationCenter

- UserDefaults

## 🚀 Future Improvements
(not implemented yet, but easily extendable)

📌 Task priority

🔁 Recurring tasks

☁️ iCloud sync

🔍 Search & filtering

📊 Sorting by date, priority, etc.
