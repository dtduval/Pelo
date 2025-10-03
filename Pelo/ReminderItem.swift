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
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdDate: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdDate = createdDate
    }
}
