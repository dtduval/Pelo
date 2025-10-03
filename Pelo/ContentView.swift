//
//  ContentView.swift
//  Pelo
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RemindersViewModel()
    @StateObject private var settings = AppSettings()
    @State private var selectedListId: UUID?
    @State private var showingSidebar = false
    
    var body: some View {
        #if os(iOS)
        iOSContentView(
            viewModel: viewModel,
            settings: settings,
            selectedListId: $selectedListId,
            showingSidebar: $showingSidebar
        )
        .preferredColorScheme(settings.colorScheme.colorScheme)
        .onAppear {
            // Select INBOX by default
            if selectedListId == nil, let inbox = viewModel.lists.first {
                selectedListId = inbox.id
            }
        }
        #else
        macOSContentView(
            viewModel: viewModel,
            settings: settings,
            selectedListId: $selectedListId
        )
        .preferredColorScheme(settings.colorScheme.colorScheme)
        .onAppear {
            // Select INBOX by default
            if selectedListId == nil, let inbox = viewModel.lists.first {
                selectedListId = inbox.id
            }
        }
        #endif
    }
}

// MARK: - iOS View

struct iOSContentView: View {
    @ObservedObject var viewModel: RemindersViewModel
    @ObservedObject var settings: AppSettings
    @Binding var selectedListId: UUID?
    @Binding var showingSidebar: Bool
    @State private var showingAddReminder = false
    
    var selectedList: ReminderList? {
        viewModel.lists.first { $0.id == selectedListId }
    }
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Top toolbar
                HStack {
                    Button(action: {
                        withAnimation {
                            showingSidebar.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // List name in center
                    if let list = selectedList {
                        Text(list.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Show + button only when sidebar is closed
                    if !showingSidebar {
                        Button(action: {
                            showingAddReminder = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        // Empty space to balance the layout when sidebar is open
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Reminders list
                if let list = selectedList {
                    List {
                        ForEach(list.sortedReminders) { reminder in
                            ReminderRow(
                                reminder: reminder,
                                listId: list.id,
                                viewModel: viewModel,
                                settings: settings,
                                selectedReminderId: nil
                            )
                        }
                        .onDelete { indexSet in
                            deleteReminders(at: indexSet, from: list.id)
                        }
                        
                        // Add new reminder row at bottom
                        Button(action: {
                            showingAddReminder = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                Text("New Reminder")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Text("Select a list")
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                if let list = selectedList {
                    AddReminderView(
                        isPresented: $showingAddReminder,
                        listId: list.id,
                        viewModel: viewModel
                    )
                }
            }
            
            // Sidebar overlay
            if showingSidebar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showingSidebar = false
                        }
                    }
                
                HStack {
                    SidebarView(
                        viewModel: viewModel,
                        settings: settings,
                        selectedListId: $selectedListId
                    )
                    .frame(width: 280)
                    #if os(iOS)
                    .background(Color(uiColor: .systemBackground))
                    #else
                    .background(Color(nsColor: .windowBackgroundColor))
                    #endif
                    .transition(.move(edge: .leading))
                    .onChange(of: selectedListId) { oldValue, newValue in
                        withAnimation {
                            showingSidebar = false
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CloseSidebar"))) { _ in
            withAnimation {
                showingSidebar = false
            }
        }
    }
    
    private func deleteReminders(at indexSet: IndexSet, from listId: UUID) {
        guard let list = viewModel.lists.first(where: { $0.id == listId }) else { return }
        let sortedReminders = list.sortedReminders
        for index in indexSet {
            let reminder = sortedReminders[index]
            viewModel.deleteReminder(from: listId, reminderId: reminder.id)
        }
    }
}

// MARK: - macOS View

struct macOSContentView: View {
    @ObservedObject var viewModel: RemindersViewModel
    @ObservedObject var settings: AppSettings
    @Binding var selectedListId: UUID?
    @State private var showingAddReminder = false
    @State private var selectedReminderId: UUID?
    @State private var showingDeleteConfirmation = false
    @State private var reminderToDelete: UUID?
    
    var selectedList: ReminderList? {
        viewModel.lists.first { $0.id == selectedListId }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(
                viewModel: viewModel,
                settings: settings,
                selectedListId: $selectedListId
            )
            .frame(minWidth: 200)
        } detail: {
            if let list = selectedList {
                VStack(spacing: 0) {
                    List {
                        ForEach(list.sortedReminders) { reminder in
                            ReminderRow(
                                reminder: reminder,
                                listId: list.id,
                                viewModel: viewModel,
                                settings: settings,
                                selectedReminderId: $selectedReminderId
                            )
                        }
                        
                        // Add new reminder row at bottom
                        Button(action: {
                            showingAddReminder = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                Text("New Reminder")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding(.top, 16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listStyle(PlainListStyle())
                    #if os(macOS)
                    .onDeleteCommand {
                        if let reminderId = selectedReminderId {
                            reminderToDelete = reminderId
                            showingDeleteConfirmation = true
                        }
                    }
                    #endif
                }
                .navigationTitle(list.name)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            showingAddReminder = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddReminder) {
                    AddReminderView(
                        isPresented: $showingAddReminder,
                        listId: list.id,
                        viewModel: viewModel
                    )
                }
                .alert("Delete Reminder", isPresented: $showingDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        if let reminderId = reminderToDelete {
                            viewModel.deleteReminder(from: list.id, reminderId: reminderId)
                            selectedReminderId = nil
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete this reminder?")
                }
            } else {
                Text("Select a list")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    let reminder: ReminderItem
    let listId: UUID
    @ObservedObject var viewModel: RemindersViewModel
    @ObservedObject var settings: AppSettings
    @Binding var selectedReminderId: UUID?
    @State private var showingEditReminder = false
    
    init(reminder: ReminderItem, listId: UUID, viewModel: RemindersViewModel, settings: AppSettings, selectedReminderId: Binding<UUID?>? = nil) {
        self.reminder = reminder
        self.listId = listId
        self.viewModel = viewModel
        self.settings = settings
        self._selectedReminderId = selectedReminderId ?? .constant(nil)
    }
    
    var isSelected: Bool {
        selectedReminderId == reminder.id
    }
    
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(settings.fontSize.titleFont)
                    .strikethrough(reminder.isCompleted)
                    .foregroundColor(reminder.isCompleted ? .gray : .primary)
                
                if let dueDate = reminder.dueDate {
                    Text(formatDueDate(dueDate))
                        .font(settings.fontSize.dueDateFont)
                        .foregroundColor(dueDateColor(for: reminder))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
        #if os(macOS)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedReminderId = reminder.id
        }
        .onTapGesture(count: 2) {
            showingEditReminder = true
        }
        #else
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditReminder = true
        }
        #endif
        .contextMenu {
            Button("Edit") {
                showingEditReminder = true
            }
            Button("Delete", role: .destructive) {
                viewModel.deleteReminder(from: listId, reminderId: reminder.id)
            }
        }
        .sheet(isPresented: $showingEditReminder) {
            EditReminderView(
                isPresented: $showingEditReminder,
                reminder: reminder,
                listId: listId,
                viewModel: viewModel
            )
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func dueDateColor(for reminder: ReminderItem) -> Color {
        if reminder.isCompleted {
            return .gray
        } else if reminder.isOverdue {
            return .red
        } else if reminder.isDueToday {
            return .orange
        } else {
            return .secondary
        }
    }
}

#Preview {
    ContentView()
}
