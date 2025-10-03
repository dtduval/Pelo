//
//  AddReminderView.swift
//  Pelo
//

import SwiftUI

struct AddReminderView: View {
    @Binding var isPresented: Bool
    let listId: UUID
    @ObservedObject var viewModel: RemindersViewModel
    
    @State private var reminderTitle = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            formContent
                .navigationTitle("New Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            addReminder()
                        }
                        .disabled(reminderTitle.isEmpty)
                    }
                }
        }
        #else
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("New Reminder")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            // Form content
            formContent
                .padding()
            
            // Buttons
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Add") {
                    addReminder()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(reminderTitle.isEmpty)
            }
            .padding()
        }
        .frame(width: 400, height: 200)
        #endif
    }
    
    private var formContent: some View {
        Form {
            Section {
                TextField("Reminder", text: $reminderTitle)
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
        .onAppear {
            #if os(iOS)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isTextFieldFocused = true
            }
            #else
            isTextFieldFocused = true
            #endif
        }
    }
    
    private func addReminder() {
        if !reminderTitle.isEmpty {
            viewModel.addReminder(
                to: listId,
                title: reminderTitle,
                dueDate: hasDueDate ? dueDate : nil
            )
            isPresented = false
        }
    }
}
