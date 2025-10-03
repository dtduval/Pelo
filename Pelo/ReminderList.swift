//
//  ReminderList.swift
//  Pelo
//

import Foundation

struct ReminderList: Identifiable, Codable {
    let id: UUID
    var name: String
    var reminders: [ReminderItem]
    
    init(id: UUID = UUID(), name: String, reminders: [ReminderItem] = []) {
        self.id = id
        self.name = name
        self.reminders = reminders
    }
    
    var sortedReminders: [ReminderItem] {
        reminders.sorted { reminder1, reminder2 in
            // Completed items go to bottom
            if reminder1.isCompleted != reminder2.isCompleted {
                return !reminder1.isCompleted
            }
            
            // Handle items without due dates (put them last among incomplete)
            switch (reminder1.dueDate, reminder2.dueDate) {
            case (.none, .none):
                return reminder1.createdDate < reminder2.createdDate
            case (.none, .some):
                return false
            case (.some, .none):
                return true
            case (.some(let date1), .some(let date2)):
                return date1 < date2
            }
        }
    }
}
