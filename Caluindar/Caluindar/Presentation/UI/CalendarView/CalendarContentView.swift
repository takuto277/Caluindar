//
//  CalendarContentView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import SwiftUI
import FSCalendar
import UIKit
import CalculateCalendarLogic
import Combine

struct CalendarContentView: UIViewRepresentable {
    var events: [Date: [String]]
    var viewModel: CalendarViewModel
    var selectedDateSubject: PassthroughSubject<Date, Never>
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        updateAppearance(for: calendar)
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        context.coordinator.events = events
        updateAppearance(for: uiView)
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateAppearance(for calendar: FSCalendar) {
        let appearance = calendar.appearance
        if colorScheme == .dark {
            appearance.titleDefaultColor = .white
            appearance.weekdayTextColor = .lightGray
            appearance.headerTitleColor = .white
            appearance.todayColor = .darkGray
            appearance.selectionColor = .lightGray
            calendar.backgroundColor = .black
        } else {
            appearance.titleDefaultColor = .black
            appearance.weekdayTextColor = .darkGray
            appearance.headerTitleColor = .black
            appearance.todayColor = .blue
            appearance.selectionColor = .gray
            calendar.backgroundColor = .white
        }
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarContentView
        var events: [Date: [String]] = [:]

        init(_ parent: CalendarContentView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position) as! CustomCalendarCell
            cell.configure(with: events[date])
            return cell
        }

        // FSCalendarDataSourceおよびFSCalendarDelegateのメソッドを実装
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            // 日付ごとのイベント数を返す
            return 0
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            // 日付が選択されたときの処理
            print("Selected date: \(date)")
            parent.selectedDateSubject.send(date)
        }
        
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            Task {
                await parent.viewModel.loadEvents(for: calendar.currentPage)
            }
        }

        // 土日祝のテキストカラーを変更
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let weekday = Calendar.current.component(.weekday, from: date)
            if weekday == 7 {
                return UIColor.blue
            } else if weekday == 1 || isHoliday(date: date) { // 日曜日または祝日
                return UIColor.red
            }
            return nil
        }

        func isHoliday(date: Date) -> Bool {
            let calendar = Calendar(identifier: .gregorian)
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)

            let holidayLogic = CalculateCalendarLogic()
            return holidayLogic.judgeJapaneseHoliday(year: year, month: month, day: day)
        }
    }
}
