//
//  DateFormView.swift
//  biletingo
//
//  Created by Gokhan on 10.09.2025.
//

import UIKit

final class DateFormView: UIView {
    
    var onDateTap: (() -> Void)?
    
    private let dateRow = FieldRowView()
    
    public var currentDate: Date {
        return selectedDate
    }
    
    private let separator: UIView = {
        let sep = UIView()
        sep.backgroundColor = .separator
        sep.layer.opacity = 0.3
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return sep
    }()
    
    private let todayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Bugün", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let tomorrowButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Yarın", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        if #available(iOS 14.0, *) {
            dp.preferredDatePickerStyle = .inline
        }
        dp.minimumDate = .now
        dp.maximumDate = Calendar.current.date(byAdding: .year, value: 1, to: .now)
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let formatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "tr_TR")
        df.dateFormat = "d MMMM EEEE"
        return df
    }()
    
    private var selectedDate: Date = Date() {
        didSet {
            dateRow.setValue(formatter.string(from: selectedDate))
            if datePicker.date != selectedDate {
                datePicker.date = selectedDate
            }
            updatePresetButtons()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    private func build() {
        backgroundColor = .systemBackground
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 6
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = .init(width: 0, height: 2)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        container.addSubview(verticalStack)
        
        verticalStack.addArrangedSubview(dateRow)
        verticalStack.addArrangedSubview(separator)
        buttonsStack.addArrangedSubview(todayButton)
        buttonsStack.addArrangedSubview(tomorrowButton)
        verticalStack.addArrangedSubview(buttonsStack)
        verticalStack.addArrangedSubview(datePicker)
        
        dateRow.configure(title: "GİDİŞ TARİHİ", value: nil, symbolName: "calendar")
        selectedDate = Date()
        
        datePicker.locale = Locale(identifier: "tr_TR")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.timeZone = .current
        datePicker.tintColor = .mainRed
        datePicker.setContentCompressionResistancePriority(.required, for: .vertical)
        datePicker.setContentHuggingPriority(.required, for: .vertical)
        //datePicker.heightAnchor.constraint(greaterThanOrEqualToConstant: 352).isActive = true
        
        todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
        tomorrowButton.addTarget(self, action: #selector(tomorrowTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
        
        updatePresetButtons()
    }
    
    // MARK: - Actions
    
    @objc private func todayTapped() {
        selectedDate = Date()
    }
    
    @objc private func tomorrowTapped() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    // MARK: - UI Helpers
    
    private func updatePresetButtons() {
        let cal = Calendar.current
        let isToday = cal.isDateInToday(selectedDate)
        let isTomorrow = cal.isDateInTomorrow(selectedDate)
        
        style(button: todayButton, selected: isToday)
        style(button: tomorrowButton, selected: isTomorrow)
    }
    
    private func style(button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = .mainRed
            button.setTitleColor(.white, for: .normal)
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.label, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mainGrey.cgColor
        }
    }
}
