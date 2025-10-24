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
    
    var earliest: Date = Date()                                   // min allowed departure
    var latest: Date = Calendar.app.date(byAdding: .year, value: 1, to: Date())!
    var minimumNights: Int = 0                                     // set to 1 if you require overnight
    
    private var minReturn: Date { departure.startOfDayApp.addingDays(minimumNights) }
    
    var body: some View {
        HStack(spacing: 12) {
            DateField(
                label: "Departure",
                date: $departure,
                range: earliest.startOfDayApp ... latest
            )
            DateField(
                label: "Return",
                date: $returning,
                range: minReturn ... latest
            )
        }
        // Keep the invariant at all times
        .onChange(of: departure) { _, newValue in
            let minEnd = newValue.startOfDayApp.addingDays(minimumNights)
            if returning < minEnd { returning = minEnd }
        }
        .onChange(of: returning) { _, newValue in
            if newValue < departure { departure = newValue }
        }
    }
}

struct DateField: View {
    let label: String
    @Binding var date: Date
    var range: ClosedRange<Date>?
    @State private var showing = false
    
    var body: some View {
        Button {
            showing = true
        } label: {
            HStack {
                Text(label).foregroundStyle(.secondary)
                Spacer()
                Text(date.formatted(date: .abbreviated, time: .omitted))
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showing, arrowEdge: .bottom) {
            DatePicker(label, selection: $date, in: range ?? Date.distantPast...Date.distantFuture, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .presentationDetents([.medium])
        }
    }
}
