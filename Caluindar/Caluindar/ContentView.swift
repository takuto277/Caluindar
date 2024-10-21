//
//  ContentView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/20.
//

import SwiftUI
import FSCalendar

struct ContentView: View {
    var body: some View {
        CalendarView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct CalendarView: UIViewRepresentable {
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 必要に応じてカレンダーの更新を行う
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarView
        private var events: [Date: [String]] = [
            // サンプルデータ
            Date(): ["会議があるよ"],
    Calendar.current.date(byAdding: .day, value: 1, to: Date())!: ["長い予定のタイトルがここに表示されます"],
    Calendar.current.date(from: DateComponents(year: 2024, month: 10, day: 16))!: ["特別なイベント", "イベント", "特別なント", "特別なイト"]
]
    
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
