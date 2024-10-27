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
import CalculateCalendarLogic

class EventManager {
    private let store = EKEventStore()
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestAccess(to: .event) { granted, error in
            if let error = error {
                print("Failed to request access: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents
        
        do {
            try store.save(event, span: .thisEvent, commit: true)
            completion(true)
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
            completion(false)
        }
    }
}

class CalendarViewModel: ObservableObject {
    @Published var events: [Date: [String]] = [:]
    private let eventStore = EKEventStore()
    private let eventManager = EventManager()
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
            .sink { [weak self] newEvents in
                self?.events = newEvents
            }
            .store(in: &cancellables)
    }
    
    private func requestAccessToCalendar() -> Future<Bool, Never> {
        return Future { promise in
            self.eventStore.requestAccess(to: .event) { granted, _ in
                promise(.success(granted))
            }
        }
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date) {
        eventManager.createEvent(title: title, startDate: startDate, endDate: endDate) { [weak self] success in
            if success {
                self?.loadEvents()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] newEvents in
                        self?.events = newEvents
                    }
                    .store(in: &self!.cancellables)
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
    @State private var showAddEventSheet = false
    
    var body: some View {
        VStack {
            CalendarView(events: viewModel.events)
                .edgesIgnoringSafeArea(.all)
            Button("Add Event") {
                showAddEventSheet = true
            }
            .sheet(isPresented: $showAddEventSheet) {
                AddEventView(viewModel: viewModel)
            }
        }
        .padding(.top)
        .background(Color(UIColor.systemBackground))
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
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
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

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CalendarViewModel
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $title)
                    .foregroundColor(Color.primary)
                DatePicker("Start Date", selection: $startDate)
                DatePicker("End Date", selection: $endDate)
            }
            .navigationTitle("Add Event")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addEvent(title: title, startDate: startDate, endDate: endDate)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
            label.textColor = UIColor.label
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
            label.textColor = UIColor.label
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
