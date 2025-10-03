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
}
