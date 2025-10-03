//
//  ReminderItem.swift
//  Pelo
//

import Foundation

struct ReminderItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdDate: Date
    var dueDate: Date?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdDate: Date = Date(), dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.dueDate = dueDate
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
    
    var isDueToday: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
}
