//
//  ContactInfoCard.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

protocol ContactInfoCardDelegate: AnyObject {
    func contactChanged(phone: String, email: String)
}

final class ContactInfoCard: CardContainerView, UITextFieldDelegate {
    
    private let phoneTF: UITextField
    private let emailTF: UITextField
    
    private lazy var selectedDial: DialCountry = dialCountries.first { $0.iso == "TR" } ?? dialCountries[0]
    private let dialCountries: [DialCountry] = [
        .init(name: "Türkiye", iso: "TR", dial: "+90", pattern: [3,3,2,2]),
        .init(name: "Amerika Birleşik Devletleri", iso: "US", dial: "+1", pattern: [3,3,4]),
        .init(name: "Almanya", iso: "DE", dial: "+49", pattern: [3,3,4]),
        .init(name: "Birleşik Krallık", iso: "GB", dial: "+44", pattern: [4,3,4]),
        .init(name: "Fransa", iso: "FR", dial: "+33", pattern: [1,2,2,2,2])
    ]
    
    private let dialButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("TR +90", for: .normal)
        b.setTitleColor(.label, for: .normal)
        b.layer.cornerRadius = 8
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.systemGray3.cgColor
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let dialPicker = UIPickerView()
    private let dialHost = UITextField()
    
    weak var delegate: ContactInfoCardDelegate?

    override init(title: String = "İletişim Bilgileri") {
        phoneTF = TextFieldFactory.make(
            placeholder: "Telefon Numarası",
            contentType: .telephoneNumber,
            keyboard: .phonePad,
            returnKey: .next
        )
        emailTF = TextFieldFactory.make(
            placeholder: "E-posta Adresi",
            contentType: .emailAddress,
            keyboard: .emailAddress,
            returnKey: .done
        )
        super.init(title: title)

        emailTF.autocapitalizationType = .none
        emailTF.addTarget(self, action: #selector(lowercaseEmail), for: .editingChanged)
        
        dialButton.addTarget(self, action: #selector(openDialPicker), for: .touchUpInside)

        dialPicker.dataSource = self
        dialPicker.delegate = self
        
        dialHost.inputView = dialPicker
        dialHost.inputAccessoryView = makePickerAccessory(title: "ÜLKE KODU")
        dialButton.setTitle("\(selectedDial.iso) \(selectedDial.dial)", for: .normal)
        
        dialHost.isHidden = false
        dialHost.isUserInteractionEnabled = false
        dialHost.alpha = 0.01
        dialHost.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(dialHost)
        NSLayoutConstraint.activate([
            dialHost.topAnchor.constraint(equalTo: topAnchor),
            dialHost.leadingAnchor.constraint(equalTo: leadingAnchor),
            dialHost.widthAnchor.constraint(equalToConstant: 1),
            dialHost.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Telefon satırı
        let phoneRow = UIStackView(arrangedSubviews: [dialButton, phoneTF])
        phoneRow.axis = .horizontal
        phoneRow.spacing = 8
        phoneRow.alignment = .fill
        dialButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        phoneTF.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Yazdıkça formatla & delegate zaten self
        phoneTF.addTarget(self, action: #selector(phoneChanged), for: .editingChanged)


        phoneTF.delegate = self
        emailTF.delegate = self
        
        addBody([phoneRow, emailTF])
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func lowercaseEmail() {
        let sel = emailTF.selectedTextRange
        emailTF.text = emailTF.text?.lowercased()
        if let s = sel { emailTF.selectedTextRange = s }
        delegate?.contactChanged(phone: phoneTF.text ?? "", email: emailTF.text ?? "")
    }
    
    @objc private func openDialPicker() {
        if let row = dialCountries.firstIndex(where: { $0.iso == selectedDial.iso }) {
            dialPicker.selectRow(row, inComponent: 0, animated: false)
        }
        dialHost.becomeFirstResponder()
    }

    @objc private func phoneChanged() {
        let digits = (phoneTF.text ?? "").filter(\.isNumber)
        let maxLocal = selectedDial.pattern.reduce(0,+)
        let clipped = String(digits.prefix(maxLocal))
        phoneTF.text = formatLocal(clipped, pattern: selectedDial.pattern)
        notify() // delegate’e geri bildir
    }

    private func formatLocal(_ digits: String, pattern: [Int]) -> String {
        var parts: [String] = []
        var idx = digits.startIndex
        for len in pattern {
            guard idx < digits.endIndex else { break }
            let end = digits.index(idx, offsetBy: len, limitedBy: digits.endIndex) ?? digits.endIndex
            parts.append(String(digits[idx..<end]))
            idx = end
        }
        return parts.joined(separator: " ")
    }

    private func notify() {
        // Tam numarayı "+90 5xx ..." formatında gönderiyoruz
        let localDigits = (phoneTF.text ?? "").filter(\.isNumber)
        delegate?.contactChanged(phone: "\(selectedDial.dial) \(localDigits)", email: emailTF.text ?? "")
    }

    // Return key flow
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTF { emailTF.becomeFirstResponder() }
        else { textField.resignFirstResponder() }
        delegate?.contactChanged(phone: phoneTF.text ?? "", email: emailTF.text ?? "")
        return true
    }

    func getValues() -> (phone: String, email: String) {
        (phoneTF.text ?? "", emailTF.text ?? "")
    }
    
    // ContactInfoCard içinde
    private func makePickerAccessory(title: String) -> UIView {
        let bar = UIToolbar()
        bar.sizeToFit()

        let titleItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        titleItem.isEnabled = false

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeDialPicker))

        bar.items = [titleItem, flex, done]
        return bar
    }

    @objc private func closeDialPicker() {
        endEditing(true)
    }

}

extension ContactInfoCard: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { dialCountries.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(dialCountries[row].name) (\(dialCountries[row].dial))"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDial = dialCountries[row]
        dialButton.setTitle("\(selectedDial.iso) \(selectedDial.dial)", for: .normal)
        phoneChanged()
    }
}
