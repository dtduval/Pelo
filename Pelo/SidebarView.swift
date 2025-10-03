//
//  SidebarView.swift
//  Pelo
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: RemindersViewModel
    @ObservedObject var settings: AppSettings
    @Binding var selectedListId: UUID?
    @State private var showingAddList = false
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // "My Lists" header
            HStack {
                Text("My Lists")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                Spacer()
            }
            
            // Lists
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.lists) { list in
                        Button(action: {
                            selectedListId = list.id
                            // Force sidebar to close on iOS even if same list is selected
                            #if os(iOS)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                NotificationCenter.default.post(name: NSNotification.Name("CloseSidebar"), object: nil)
                            }
                            #endif
                        }) {
                            HStack {
                                Text(list.name)
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(list.reminders.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedListId == list.id ? Color.gray.opacity(0.2) : Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            if list.name != "INBOX" {
                                Button("Delete", role: .destructive) {
                                    // If deleting selected list, switch to INBOX
                                    if selectedListId == list.id, let inbox = viewModel.lists.first(where: { $0.name == "INBOX" }) {
                                        selectedListId = inbox.id
                                    }
                                    viewModel.deleteList(id: list.id)
                                }
                            }
                        }
                        #if os(iOS)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if list.name != "INBOX" {
                                Button(role: .destructive) {
                                    // If deleting selected list, switch to INBOX
                                    if selectedListId == list.id, let inbox = viewModel.lists.first(where: { $0.name == "INBOX" }) {
                                        selectedListId = inbox.id
                                    }
                                    viewModel.deleteList(id: list.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        #endif
                    }
                    
                    // Add New List Button (after lists)
                    Button(action: {
                        showingAddList = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New List")
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Divider()
            
            // Settings Button
            Button(action: {
                showingSettings = true
            }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                    Text("Settings")
                        .font(.title3)
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showingAddList) {
            AddListView(isPresented: $showingAddList, viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(isPresented: $showingSettings, settings: settings)
        }
    }
}

struct AddListView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: RemindersViewModel
    @State private var listName = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            Form {
                TextField("List Name", text: $listName)
                    .focused($isTextFieldFocused)
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addList()
                    }
                    .disabled(listName.isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isTextFieldFocused = true
                }
            }
        }
        #else
        VStack(spacing: 0) {
            HStack {
                Text("New List")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Form {
                TextField("List Name", text: $listName)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Add") {
                    addList()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(listName.isEmpty)
            }
            .padding()
        }
        .frame(width: 300, height: 150)
        .onAppear {
            isTextFieldFocused = true
        }
        #endif
    }
    
    private func addList() {
        if !listName.isEmpty {
            viewModel.addList(name: listName)
            isPresented = false
        }
    }
}
