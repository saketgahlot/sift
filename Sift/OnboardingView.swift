import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("recyclingDaysData") private var recyclingDaysData = Data()
    
    @State private var selectedDays: Set<Int> = []
    @State private var notificationsEnabled = false
    
    let daysOfWeek = [
        (0, "SUN"),
        (1, "MON"),
        (2, "TUE"),
        (3, "WED"),
        (4, "THU"),
        (5, "FRI"),
        (6, "SAT")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    // Title
                    VStack(spacing: 12) {
                        Text("SIFT")
                            .font(.system(size: 48, weight: .light, design: .monospaced))
                            .foregroundColor(.black)
                            .tracking(10)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 80, height: 1)
                        
                        Text("WELCOME")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(3)
                    }
                    .padding(.top, 60)
                    
                    // Instructions
                    VStack(spacing: 16) {
                        Text("WHEN IS YOUR")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        Text("RECYCLING DAY?")
                            .font(.system(size: 20, weight: .light, design: .monospaced))
                            .foregroundColor(.black)
                            .tracking(3)
                        
                        Text("Select all days that apply")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.8))
                            .tracking(1)
                    }
                    .padding(.top, 20)
                    
                    // Day selector
                    VStack(spacing: 12) {
                        ForEach(daysOfWeek, id: \.0) { day in
                            Button(action: {
                                if selectedDays.contains(day.0) {
                                    selectedDays.remove(day.0)
                                } else {
                                    selectedDays.insert(day.0)
                                }
                            }) {
                                HStack {
                                    Text(day.1)
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .tracking(2)
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedDays.contains(day.0) ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20, weight: .light))
                                }
                                .foregroundColor(selectedDays.contains(day.0) ? .white : .black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(selectedDays.contains(day.0) ? Color.black : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Continue button
                    VStack(spacing: 16) {
                        if !selectedDays.isEmpty {
                            Text("We'll remind you the day before")
                                .font(.system(size: 9, weight: .regular, design: .monospaced))
                                .foregroundColor(.gray)
                                .tracking(1)
                        }
                        
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text(selectedDays.isEmpty ? "SKIP" : "CONTINUE")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black)
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .frame(minHeight: geometry.size.height)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        }
    }
    
    func completeOnboarding() {
        // Save selected days
        if let encoded = try? JSONEncoder().encode(Array(selectedDays)) {
            recyclingDaysData = encoded
        }
        
        // Request notification permissions if days were selected
        if !selectedDays.isEmpty {
            NotificationManager.shared.requestPermission { granted in
                if granted {
                    NotificationManager.shared.scheduleRecyclingReminders(for: Array(selectedDays))
                }
            }
        }
        
        // Mark onboarding as complete
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
}
