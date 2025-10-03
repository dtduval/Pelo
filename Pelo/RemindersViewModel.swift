//
//  RemindersViewModel.swift
//  Pelo
//

import Foundation
import Combine

class RemindersViewModel: ObservableObject {
    @Published var lists: [ReminderList] = []
    
    private let saveKey = "SavedLists"
    
    init() {
        loadData()
        
        // If no lists exist, create the default INBOX
        if lists.isEmpty {
            lists = [
                ReminderList(name: "INBOX", reminders: [])
            ]
            saveData()
        }
    }
    
    // MARK: - List Management
    
    func addList(name: String) {
        let newList = ReminderList(name: name, reminders: [])
        lists.append(newList)
        saveData()
    }
    
    func deleteList(id: UUID) {
        // Don't allow deleting INBOX
        guard let index = lists.firstIndex(where: { $0.id == id }),
              lists[index].name != "INBOX" else { return }
        lists.remove(at: index)
        saveData()
    }
    
    func renameList(id: UUID, newName: String) {
        guard let index = lists.firstIndex(where: { $0.id == id }) else { return }
        lists[index].name = newName
        saveData()
    }
    
    // MARK: - Reminder Management
    
    func addReminder(to listId: UUID, title: String, dueDate: Date? = nil) {
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        let newReminder = ReminderItem(title: title, dueDate: dueDate)
        lists[index].reminders.append(newReminder)
        saveData()
    }
    
    func toggleReminder(in listId: UUID, reminderId: UUID) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }),
              let reminderIndex = lists[listIndex].reminders.firstIndex(where: { $0.id == reminderId }) else { return }
        lists[listIndex].reminders[reminderIndex].isCompleted.toggle()
        saveData()
    }
    
    func updateReminder(in listId: UUID, reminderId: UUID, title: String, dueDate: Date?) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }),
              let reminderIndex = lists[listIndex].reminders.firstIndex(where: { $0.id == reminderId }) else { return }
        lists[listIndex].reminders[reminderIndex].title = title
        lists[listIndex].reminders[reminderIndex].dueDate = dueDate
        saveData()
    }
    
    func deleteReminder(from listId: UUID, reminderId: UUID) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }),
              let reminderIndex = lists[listIndex].reminders.firstIndex(where: { $0.id == reminderId }) else { return }
        lists[listIndex].reminders.remove(at: reminderIndex)
        saveData()
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([ReminderList].self, from: savedData) {
            lists = decoded
        }
    }
}
