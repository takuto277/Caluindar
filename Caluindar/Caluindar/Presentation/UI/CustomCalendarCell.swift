//
//  CustomCalendarCell.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import UIKit
import FSCalendar

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
