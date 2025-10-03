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
        
        // If no lists exist, create the default two lists
        if lists.isEmpty {
            lists = [
                ReminderList(name: "INBOX", reminders: []),
                ReminderList(name: "Work Prep", reminders: [])
            ]
            saveData()
        }
    }
    
    // MARK: - Reminder Management
    
    func addReminder(to listId: UUID, title: String) {
        guard let index = lists.firstIndex(where: { $0.id == listId }) else { return }
        let newReminder = ReminderItem(title: title)
        lists[index].reminders.append(newReminder)
        saveData()
    }
    
    func toggleReminder(in listId: UUID, reminderId: UUID) {
        guard let listIndex = lists.firstIndex(where: { $0.id == listId }),
              let reminderIndex = lists[listIndex].reminders.firstIndex(where: { $0.id == reminderId }) else { return }
        lists[listIndex].reminders[reminderIndex].isCompleted.toggle()
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
