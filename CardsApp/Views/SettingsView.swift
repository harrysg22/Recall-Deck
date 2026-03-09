//
//  SettingsView.swift
//  CardsApp
//

import SwiftUI

struct AppSettings {
    var recallSeconds: Double = 10
    var reviewReminderHour: Int = 20
    var reviewReminderMinute: Int = 0
    var notificationsEnabled: Bool = true
    var failDownToBox: Int = 1
    var speechRate: Float = 0.5
    var yandexAPIKey: String = ""
}

struct SettingsView: View {
    @AppStorage("recallSeconds") private var recallSeconds: Double = 10
    @AppStorage("reviewReminderHour") private var reviewReminderHour: Int = 20
    @AppStorage("reviewReminderMinute") private var reviewReminderMinute: Int = 0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("failDownToBox") private var failDownToBox: Int = 1
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    @AppStorage("yandexAPIKey") private var yandexAPIKey: String = ""

    var body: some View {
        Form {
            Section("Juego Recordar") {
                Stepper(value: $recallSeconds, in: 5...60, step: 5) {
                    Text("Tiempo para recordar: \(Int(recallSeconds)) s")
                }
            }
            Section("Repaso al fallar") {
                Picker("Bajar a caja", selection: $failDownToBox) {
                    Text("Caja 0").tag(0)
                    Text("Caja 1").tag(1)
                }
            }
            Section("Pronunciación") {
                VStack(alignment: .leading) {
                    Text("Velocidad de habla")
                    Slider(value: $speechRate, in: 0...1, step: 0.1)
                }
            }
            Section("Notificaciones") {
                Toggle("Recordatorio de repaso", isOn: $notificationsEnabled)
                if notificationsEnabled {
                    HStack {
                        Text("Hora")
                        Spacer()
                        DatePicker("", selection: Binding(
                            get: {
                                var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                                c.hour = reviewReminderHour
                                c.minute = reviewReminderMinute
                                return Calendar.current.date(from: c) ?? Date()
                            },
                            set: { d in
                                let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                                reviewReminderHour = c.hour ?? 20
                                reviewReminderMinute = c.minute ?? 0
                            }
                        ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                }
            }
            Section("Traducción automática") {
                SecureField("Clave API Yandex Dictionary", text: $yandexAPIKey)
                Text("Opcional. Sin clave puedes añadir palabras manualmente o importar CSV.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: notificationsEnabled) { _, enabled in
            if !enabled {
                NotificationService.cancelReviewReminder()
            }
        }
        .onChange(of: reviewReminderHour) { _, _ in
            Task { await rescheduleNotification() }
        }
        .onChange(of: reviewReminderMinute) { _, _ in
            Task { await rescheduleNotification() }
        }
    }

    private func rescheduleNotification() async {
        guard notificationsEnabled else { return }
        let h = reviewReminderHour == 0 ? 20 : reviewReminderHour
        let m = reviewReminderMinute
        NotificationService.scheduleReviewReminder(count: 0, hour: h, minute: m)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
