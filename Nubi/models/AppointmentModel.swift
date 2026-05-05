//
//  AppointmentModel.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//

import SwiftUI

// MARK: - Psicólogo de Coppel
struct Psychologist: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let emoji: String
    let bio: String
    let yearsExperience: Int
    let rating: Double
    let availableSlots: [TimeSlot]
}

// MARK: - Horario disponible
struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let dayLabel: String      // "Lun 12 May"
    let date: Date
    let hour: String           // "10:00 AM"
    let isAvailable: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: TimeSlot, rhs: TimeSlot) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Cita agendada
struct Appointment: Identifiable, Codable {
    let id: UUID
    let psychologistName: String
    let date: Date
    let hour: String
    let motivo: String
    let modalidad: String  // "Videollamada" o "Presencial"

    init(psychologistName: String, date: Date, hour: String, motivo: String, modalidad: String) {
        self.id = UUID()
        self.psychologistName = psychologistName
        self.date = date
        self.hour = hour
        self.motivo = motivo
        self.modalidad = modalidad
    }
}

// MARK: - Motivos de consulta
let consultationReasons: [(emoji: String, label: String)] = [
    ("😟", "Ansiedad o estrés"),
    ("😢", "Tristeza o depresión"),
    ("😤", "Manejo de enojo"),
    ("😴", "Burnout laboral"),
    ("🤝", "Conflictos con compañeros"),
    ("💔", "Problemas personales"),
    ("🌀", "No sé cómo me siento"),
    ("💬", "Solo quiero hablar"),
]

// MARK: - Datos de ejemplo de psicólogos
func generateSampleSlots() -> [TimeSlot] {
    let calendar = Calendar.current
    let today = Date()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "es_MX")
    formatter.dateFormat = "EEE d MMM"

    var slots: [TimeSlot] = []
    let hours = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM", "1:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"]

    for dayOffset in 1...7 {
        if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
            let weekday = calendar.component(.weekday, from: date)
            // Excluir domingos (1)
            guard weekday != 1 else { continue }

            let dayLabel = formatter.string(from: date).capitalized
            for hour in hours {
                let available = Bool.random() || dayOffset <= 3
                slots.append(TimeSlot(dayLabel: dayLabel, date: date, hour: hour, isAvailable: available))
            }
        }
    }
    return slots
}

let samplePsychologists: [Psychologist] = [
    Psychologist(
        name: "Dra. Ana Lucía Morales",
        specialty: "Ansiedad y estrés laboral",
        emoji: "👩‍⚕️",
        bio: "Especialista en bienestar laboral con enfoque cognitivo-conductual. Ha acompañado a más de 200 colaboradores de Coppel.",
        yearsExperience: 8,
        rating: 4.9,
        availableSlots: generateSampleSlots()
    ),
    Psychologist(
        name: "Dr. Carlos Ramírez",
        specialty: "Burnout y manejo emocional",
        emoji: "👨‍⚕️",
        bio: "Psicólogo clínico enfocado en prevención de burnout y desarrollo de resiliencia en entornos de retail.",
        yearsExperience: 6,
        rating: 4.8,
        availableSlots: generateSampleSlots()
    ),
    Psychologist(
        name: "Dra. Sofía Hernández",
        specialty: "Inteligencia emocional",
        emoji: "👩‍⚕️",
        bio: "Experta en inteligencia emocional y comunicación asertiva. Certificada en terapia breve centrada en soluciones.",
        yearsExperience: 10,
        rating: 4.95,
        availableSlots: generateSampleSlots()
    ),
]
