//
//  ContentView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/20.
//

import SwiftUI
import FSCalendar
import EventKit
import Combine

class CalendarViewModel: ObservableObject {
    @Published var events: [Date: [String]] = [:]
    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        requestAccessToCalendar()
            .flatMap { [unowned self] granted -> AnyPublisher<[Date: [String]], Never> in
                if granted {
                    return self.loadEvents()
                } else {
                    return Just([:]).eraseToAnyPublisher()
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$events)
    }

    private func requestAccessToCalendar() -> Future<Bool, Never> {
        return Future { promise in
            self.eventStore.requestAccess(to: .event) { granted, _ in
                promise(.success(granted))
            }
        }
    }
    
    private func loadEvents() -> AnyPublisher<[Date: [String]], Never> {
        return Future { promise in
            let calendars = self.eventStore.calendars(for: .event)
            let oneMonthAgo = Date().addingTimeInterval(-30*24*3600)
            let oneMonthAfter = Date().addingTimeInterval(30*24*3600)
            let predicate = self.eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: calendars)

            let ekEvents = self.eventStore.events(matching: predicate)
            var newEvents: [Date: [String]] = [:]

            for event in ekEvents {
                let startDate = Calendar.current.startOfDay(for: event.startDate)
                if newEvents[startDate] != nil {
                    newEvents[startDate]?.append(event.title)
                } else {
                    newEvents[startDate] = [event.title]
                }
            }

            promise(.success(newEvents))
        }
        .eraseToAnyPublisher()
    }
}



struct ContentView: View {
    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        CalendarView(events: viewModel.events)
            .edgesIgnoringSafeArea(.all)
    }
}

struct CalendarView: UIViewRepresentable {
    var events: [Date: [String]]
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        context.coordinator.events = events
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarView
    var events: [Date: [String]] = [:]
    
        init(_ parent: CalendarView) {
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
        }
    }
}

class CustomCalendarCell: FSCalendarCell {
    private var eventLabels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
    super.layoutSubviews()
        let labelHeight: CGFloat = 15
        for (index, label) in eventLabels.enumerated() {
            label.frame = CGRect(x: 0, y: contentView.bounds.height - CGFloat(index + 1) * labelHeight, width: contentView.bounds.width, height: labelHeight)
        }
    }

    func configure(with events: [String]?) {
        // 既存のラベルをクリア
        eventLabels.forEach { $0.removeFromSuperview() }
        eventLabels.removeAll()

        // 新しいイベントラベルを追加
        events?.forEach { event in
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .black
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            label.text = event
            contentView.addSubview(label)
            eventLabels.append(label)
        }
        setNeedsLayout()
    }
}

#Preview {
    ContentView()
}
