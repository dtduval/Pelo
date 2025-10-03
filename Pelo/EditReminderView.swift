//
//  EditReminderView.swift
//  Pelo
//

import SwiftUI

struct EditReminderView: View {
    @Binding var isPresented: Bool
    let reminder: ReminderItem
    let listId: UUID
    @ObservedObject var viewModel: RemindersViewModel
    
    @State private var title: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @FocusState private var isTextFieldFocused: Bool
    
    init(isPresented: Binding<Bool>, reminder: ReminderItem, listId: UUID, viewModel: RemindersViewModel) {
        self._isPresented = isPresented
        self.reminder = reminder
        self.listId = listId
        self.viewModel = viewModel
        
        _title = State(initialValue: reminder.title)
        _hasDueDate = State(initialValue: reminder.dueDate != nil)
        _dueDate = State(initialValue: reminder.dueDate ?? Date())
    }
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationTitle("Edit Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveChanges()
                        }
                        .disabled(title.isEmpty)
                    }
                }
        }
        #else
        VStack(spacing: 0) {
            HStack {
                Text("Edit Reminder")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            formContent
                .padding()
            
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
            }
            .padding()
        }
        .frame(width: 400, height: 200)
        .onAppear {
            isTextFieldFocused = true
        }
        #endif
    }
    
    private var formContent: some View {
        Form {
            Section {
                TextField("Reminder", text: $title)
                    .focused($isTextFieldFocused)
                    #if os(macOS)
                    .textFieldStyle(.roundedBorder)
                    #endif
            }
            
            Section {
                Toggle("Due Date", isOn: $hasDueDate)
                
                if hasDueDate {
                    DatePicker("Date", selection: $dueDate, displayedComponents: [.date])
                        #if os(macOS)
                        .datePickerStyle(.field)
                        #endif
                }
            }
        }
        #if os(iOS)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTextFieldFocused = true
            }
        }
        #endif
    }
    
    private func saveChanges() {
        if !title.isEmpty {
            viewModel.updateReminder(
                in: listId,
                reminderId: reminder.id,
                title: title,
                dueDate: hasDueDate ? dueDate : nil
            )
            isPresented = false
        }
    }
}
