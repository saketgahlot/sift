import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("recyclingDaysData") private var recyclingDaysData = Data()
    
    @State private var selectedDays: Set<Int> = []
    @State private var showSaveConfirmation = false
    
    let daysOfWeek = [
        (0, "SUN", "Sunday"),
        (1, "MON", "Monday"),
        (2, "TUE", "Tuesday"),
        (3, "WED", "Wednesday"),
        (4, "THU", "Thursday"),
        (5, "FRI", "Friday"),
        (6, "SAT", "Saturday")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Text("SETTINGS")
                            .font(.system(size: 32, weight: .light, design: .monospaced))
                            .foregroundColor(.black)
                            .tracking(6)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 60, height: 1)
                    }
                    .padding(.top, 20)
                    
                    // Recycling Days Section
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("RECYCLING DAYS")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.black)
                                .tracking(2)
                            
                            Text("Select all days that apply")
                                .font(.system(size: 9, weight: .regular, design: .monospaced))
                                .foregroundColor(.gray)
                                .tracking(1)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 10) {
                            ForEach(daysOfWeek, id: \.0) { day in
                                Button(action: {
                                    if selectedDays.contains(day.0) {
                                        selectedDays.remove(day.0)
                                    } else {
                                        selectedDays.insert(day.0)
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(day.1)
                                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                .tracking(2)
                                            Text(day.2)
                                                .font(.system(size: 9, weight: .regular, design: .monospaced))
                                                .tracking(0.5)
                                                .opacity(0.7)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedDays.contains(day.0) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20, weight: .light))
                                    }
                                    .foregroundColor(selectedDays.contains(day.0) ? .white : .black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(selectedDays.contains(day.0) ? Color.black : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .cornerRadius(4)
                                }
                                .id("\(day.0)-\(selectedDays.contains(day.0))")
                            }
                        }
                        .id(selectedDays.hashValue)
                        .padding(.horizontal, 24)
                    }
                    
                    // Notification Info
                    VStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("You'll receive a reminder at 7 PM")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(1)
                        
                        Text("the day before each recycling day")
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(1)
                    }
                    .padding(.horizontal, 24)
                    
                    // Save Button
                    Button(action: {
                        saveSettings()
                    }) {
                        Text("SAVE CHANGES")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .tracking(2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    // Confirmation message
                    if showSaveConfirmation {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Settings saved successfully")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.green)
                                .tracking(1)
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .onAppear {
            loadCurrentDays()
        }
    }
    
    func loadCurrentDays() {
        if let decoded = try? JSONDecoder().decode([Int].self, from: recyclingDaysData) {
            selectedDays = Set(decoded)
        }
    }
    
    func saveSettings() {
        // Save selected days
        if let encoded = try? JSONEncoder().encode(Array(selectedDays)) {
            recyclingDaysData = encoded
        }
        
        // Update notifications
        if !selectedDays.isEmpty {
            // Request permission first (will do nothing if already granted)
            NotificationManager.shared.requestPermission { granted in
                if granted {
                    NotificationManager.shared.updateRecyclingDays(Array(selectedDays))
                }
            }
        } else {
            // Remove all notifications if no days selected
            NotificationManager.shared.removeAllNotifications()
        }
        
        // Show confirmation
        withAnimation {
            showSaveConfirmation = true
        }
        
        // Hide confirmation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSaveConfirmation = false
            }
        }
    }
}

#Preview {
    SettingsView()
}
