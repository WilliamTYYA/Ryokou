//
//  DateRangeField.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/24/25.
//

import Foundation
import SwiftUI

extension Calendar {
    static let app = Calendar(identifier: .gregorian)
}
extension Date {
    var startOfDayApp: Date { Calendar.app.startOfDay(for: self) }
    func addingDays(_ n: Int) -> Date { Calendar.app.date(byAdding: .day, value: n, to: self)! }
}

struct DateRangeFields: View {
    @Binding var departure: Date
    @Binding var returning: Date
    
    var earliestDeparture: Date = Date().startOfDayApp
    var latest: Date = Calendar.app.date(byAdding: .year, value: 1, to: Date())!
    var minimumNights: Int = 0
    
    private var earliestReturn: Date { departure.startOfDayApp.addingDays(minimumNights) }
    
    init(departure: Binding<Date>, returning: Binding<Date>, minimumNights: Int = 1) {
        self._departure = departure
        self._returning = returning
        self.minimumNights = minimumNights
    }
    
    var body: some View {
        HStack(spacing: 12) {
            DateField(
                label: "Departure",
                date: $departure,
                range: earliestDeparture.startOfDayApp ... latest
            )
            DateField(
                label: "Return",
                date: $returning,
                range: earliestReturn ... latest
            )
        }
        .onChange(of: departure) { _, newValue in
            let newDeparture = newValue.startOfDayApp.addingDays(minimumNights)
            if returning < newDeparture { returning = newDeparture }
        }
        .onChange(of: returning) { _, newValue in
            if newValue < departure { departure = newValue }
        }
    }
}

struct DateField: View {
    let label: String
    @Binding var date: Date
    var range: ClosedRange<Date>
    
    @State private var showing = false
    
    var body: some View {
        Button {
            showing = true
        } label: {
            HStack {
                Text(label).foregroundStyle(.secondary)
                    .lineLimit(1)
                    .layoutPriority(0)
                Spacer()
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .layoutPriority(1)
            }
            .padding(12)
            .frame(height: 48)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showing, arrowEdge: .bottom) {
            DatePicker(label, selection: $date, in: range, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
        }
        // Date.distantPast...Date.distantFuture
    }
}

#Preview {
    @Previewable @State var dep: Date = Date().addingDays(-10)
    @Previewable @State var ret: Date = Date().addingDays(3)
    DateRangeFields(departure: $dep, returning: $ret)
}
