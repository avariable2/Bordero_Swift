import Foundation

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case week = "semaine"
    case month = "mois"
    case year = "année"

    var id: Self { self }

    var displayName: LocalizedStringResource {
        switch self {
        case .week: "Semaine"
        case .month: "Mois"
        case .year: "Année"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }

    var chartComponent: Calendar.Component {
        switch self {
        case .week: .day
        case .month: .weekOfYear
        case .year: .month
        }
    }

    var previousPeriodDescription: LocalizedStringResource {
        switch self {
        case .week: "la semaine précédente"
        case .month: "le mois précédent"
        case .year: "l’année précédente"
        }
    }

    func interval(
        containing date: Date,
        calendar: Calendar = .current
    ) -> DateInterval {
        calendar.dateInterval(of: calendarComponent, for: date)
            ?? DateInterval(start: date, duration: 0)
    }
}
