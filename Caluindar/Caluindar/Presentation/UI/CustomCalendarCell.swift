//
//  CustomCalendarCell.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import UIKit
import FSCalendar
import SwiftUICore

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
        let padding: CGFloat = 1
        let verticalOffset: CGFloat = 15
        for (index, label) in eventLabels.enumerated() {
            label.frame = CGRect(
                x: padding,
                y: contentView.bounds.height - CGFloat(index + 1) * labelHeight + padding + verticalOffset,
                width: contentView.bounds.width - 2 * padding,
                height: labelHeight - 2 * padding
            )
        }
    }
    
    func configure(with events: [EventData]) {
        // 既存のラベルをクリア
        eventLabels.forEach { $0.removeFromSuperview() }
        eventLabels.removeAll()
        
        // 新しいイベントラベルを追加
        let displayedEvents = events.prefix(3)
        for event in displayedEvents {
            let label = UILabel()
            label.textColor = textColor(for: event.color)
            label.font = UIFont.systemFont(ofSize: 10)
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            label.text = event.title
            label.backgroundColor = event.color
            label.layer.cornerRadius = 4
            label.layer.masksToBounds = true
            contentView.addSubview(label)
            eventLabels.append(label)
        }
        
        if events.count > 3 {
            let moreLabel = UILabel()
            moreLabel.font = UIFont.systemFont(ofSize: 10)
            moreLabel.textColor = UIColor(named: "Basic")
            moreLabel.numberOfLines = 1
            moreLabel.lineBreakMode = .byTruncatingTail
            moreLabel.text = "..."
            contentView.addSubview(moreLabel)
            eventLabels.insert(moreLabel, at: 0)
        }
        
        setNeedsLayout()
    }
    
    private func textColor(for color: UIColor?) -> UIColor {
        guard let color = color else { return .white }
        return color.isLight ? .black : .white
    }
}
