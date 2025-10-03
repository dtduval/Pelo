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
        .frame(width: 400, height: 150)
        #endif
    }
    
    private var formContent: some View {
        Form {
            TextField("Reminder", text: $reminderTitle)
                #if os(macOS)
                .textFieldStyle(.roundedBorder)
                #endif
        }
    }
    
    private func addReminder() {
        if !reminderTitle.isEmpty {
            viewModel.addReminder(to: listId, title: reminderTitle)
            isPresented = false
        }
    }
}
