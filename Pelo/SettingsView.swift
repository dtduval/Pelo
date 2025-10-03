//
//  SettingsView.swift
//  Pelo
//

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var fontSize: FontSize {
        didSet {
            UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
        }
    }
    
    @Published var colorScheme: AppColorScheme {
        didSet {
            UserDefaults.standard.set(colorScheme.rawValue, forKey: "colorScheme")
        }
    }
    
    enum FontSize: String, CaseIterable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        
        var titleFont: Font {
            switch self {
            case .small: return .body
            case .medium: return .title3
            case .large: return .title
            }
        }
        
        var dueDateFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .title2
            }
        }
    }
    
    enum AppColorScheme: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    init() {
        if let savedFontSize = UserDefaults.standard.string(forKey: "fontSize"),
           let fontSize = FontSize(rawValue: savedFontSize) {
            self.fontSize = fontSize
        } else {
            self.fontSize = .large
        }
        
        if let savedColorScheme = UserDefaults.standard.string(forKey: "colorScheme"),
           let colorScheme = AppColorScheme(rawValue: savedColorScheme) {
            self.colorScheme = colorScheme
        } else {
            self.colorScheme = .system
        }
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Font Size", selection: $settings.fontSize) {
                        ForEach(AppSettings.FontSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    
                    Picker("Theme", selection: $settings.colorScheme) {
                        ForEach(AppSettings.AppColorScheme.allCases, id: \.self) { scheme in
                            Text(scheme.rawValue).tag(scheme)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        #else
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Font Size", selection: $settings.fontSize) {
                        ForEach(AppSettings.FontSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    
                    Picker("Theme", selection: $settings.colorScheme) {
                        ForEach(AppSettings.AppColorScheme.allCases, id: \.self) { scheme in
                            Text(scheme.rawValue).tag(scheme)
                        }
                    }
                }
            }
            .padding()
            
            HStack {
                Spacer()
                Button("Done") {
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 250)
        #endif
    }
}
