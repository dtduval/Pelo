//
//  ContentView.swift
//  Pelo
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RemindersViewModel()
    @State private var selectedListIndex = 0
    @State private var showingAddReminder = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Reminders List
            List {
                ForEach(viewModel.lists[selectedListIndex].reminders) { reminder in
                    ReminderRow(
                        reminder: reminder,
                        listId: viewModel.lists[selectedListIndex].id,
                        viewModel: viewModel
                    )
                }
                .onDelete { indexSet in
                    deleteReminders(at: indexSet)
                }
            }
            .listStyle(PlainListStyle())
            
            // Bottom Selector Bar
            ListSelectorBar(
                lists: viewModel.lists,
                selectedIndex: $selectedListIndex
            )
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddReminder = true
                }) {
                    Image(systemName: "plus")
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingAddReminder = true
                }) {
                    Image(systemName: "plus")
                }
            }
            #endif
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(
                isPresented: $showingAddReminder,
                listId: viewModel.lists[selectedListIndex].id,
                viewModel: viewModel
            )
        }
    }
    
    private func deleteReminders(at indexSet: IndexSet) {
        for index in indexSet {
            let reminder = viewModel.lists[selectedListIndex].reminders[index]
            viewModel.deleteReminder(
                from: viewModel.lists[selectedListIndex].id,
                reminderId: reminder.id
            )
        }
    }
}

struct ReminderRow: View {
    let reminder: ReminderItem
    let listId: UUID
    @ObservedObject var viewModel: RemindersViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.toggleReminder(in: listId, reminderId: reminder.id)
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(reminder.title)
                .strikethrough(reminder.isCompleted)
                .foregroundColor(reminder.isCompleted ? .gray : .primary)
            
            Spacer()
        }
    }
}

struct ListSelectorBar: View {
    let lists: [ReminderList]
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<lists.count, id: \.self) { index in
                ListSelectorButton(
                    listName: lists[index].name,
                    isSelected: selectedIndex == index,
                    action: { selectedIndex = index }
                )
            }
        }
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1),
            alignment: .top
        )
    }
}

struct ListSelectorButton: View {
    let listName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(listName)
                    .font(.footnote)
                    .fontWeight(isSelected ? .bold : .regular)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .foregroundColor(isSelected ? .blue : .gray)
    }
}

#Preview {
    ContentView()
}
