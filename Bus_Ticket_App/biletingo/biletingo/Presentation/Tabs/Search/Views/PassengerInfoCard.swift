//
//  PassengerInfoCard.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

protocol PassengerInfoCardDelegate: AnyObject {
    func passengerListChanged(_ passengers: [PassengerInfo])
}

final class PassengerInfoCard: CardContainerView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    // Public
    weak var delegate: PassengerInfoCardDelegate?

    // Data
    private var passengers: [PassengerInfo] = []
    private var selectedIndex: Int = 0 { didSet { bindForm(); tabs.reloadData() } }
    private var seatNumbers: [Int] = []
    
    // UI
    private let tabs: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumInteritemSpacing = 8
        l.minimumLineSpacing = 8
        l.sectionInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: l)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    private let nameTF = TextFieldFactory.make(placeholder: "Ad Soyad", contentType: .name, returnKey: .next)
    private let tcTF   = TextFieldFactory.make(placeholder: "T.C. Kimlik No", keyboard: .numberPad, returnKey: .done)
    private let foreignSwitch = UISwitch()
    private let countryTF = TextFieldFactory.make(placeholder: "Uyruk seçiniz")
    private let passportTF = TextFieldFactory.make(placeholder: "Pasaport Numarası", keyboard: .asciiCapable)
    private let countryPicker = UIPickerView()
    private var countries: [String] = []

    private let tcRow   = UIStackView()
    private let foreignGroup = UIStackView()

    // Init
    override init(title: String = "Yolcu Bilgileri") {
        super.init(title: title)

        // Tabs
        tabs.dataSource = self; tabs.delegate = self
        tabs.register(PassengerTabCell.self, forCellWithReuseIdentifier: "PassengerTabCell")
        tabs.heightAnchor.constraint(equalToConstant: 40).isActive = true

        // TC row (TC + yabancı switch)
        let right = UIStackView()
        right.axis = .horizontal; right.spacing = 8; right.alignment = .center
        let lbl = UILabel(); lbl.text = "T.C. Vatandaşı değilim"; lbl.font = .systemFont(ofSize: 14)
        right.addArrangedSubview(lbl); right.addArrangedSubview(foreignSwitch)

        tcRow.axis = .horizontal; tcRow.spacing = 12; tcRow.distribution = .fillProportionally
        tcRow.addArrangedSubview(tcTF); tcRow.addArrangedSubview(right)

        foreignSwitch.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        foreignSwitch.addTarget(self, action: #selector(foreignChanged), for: .valueChanged)

        // Country picker
        countryTF.tintColor = .clear
        countryPicker.dataSource = self; countryPicker.delegate = self
        countryTF.inputView = countryPicker
        countryTF.inputAccessoryView = pickerAccessory(title: "UYRUK SEÇİNİZ")

        // Foreign group
        // Foreign group
        foreignGroup.axis = .vertical
        foreignGroup.spacing = 8

        let nationalityRow = makeFieldRow(title: "Uyruk", rightView: countryTF)
        foreignGroup.addArrangedSubview(nationalityRow)
        foreignGroup.addArrangedSubview(makeSeparator())
        foreignGroup.addArrangedSubview(passportTF)

        // Body
        addBody([tabs, nameTF, makeSeparator(), tcRow, foreignGroup])

        // Delegates
        nameTF.delegate = self; tcTF.delegate = self

        // Countries
        buildCountries()

        // Defaults
        passportTF.autocapitalizationType = .allCharacters
        updateForeignVisibility(animated: false)
    }

    required init?(coder: NSCoder) { fatalError() }

    // Public API
    func configure(seatNumbers: [Int]) {
        self.seatNumbers = seatNumbers
        let c = max(1, seatNumbers.count)
        passengers = Array(repeating: PassengerInfo(), count: c)
        selectedIndex = 0
        bindForm()
        tabs.reloadData()
        delegate?.passengerListChanged(passengers)
    }

    // MARK: Data bind
    private func bindForm() {
        guard passengers.indices.contains(selectedIndex) else { return }
        let p = passengers[selectedIndex]
        nameTF.text = p.fullName
        tcTF.text   = p.nationalId
        foreignSwitch.isOn = p.isForeign
        countryTF.text = p.nationality
        passportTF.text = p.passportNo

        updateForeignVisibility(animated: false)

        if let idx = countries.firstIndex(of: p.nationality) {
            countryPicker.selectRow(idx, inComponent: 0, animated: false)
        }
    }

    private func saveForm() {
        guard passengers.indices.contains(selectedIndex) else { return }
        passengers[selectedIndex].fullName   = nameTF.text ?? ""
        passengers[selectedIndex].nationalId = tcTF.text ?? ""
        passengers[selectedIndex].isForeign  = foreignSwitch.isOn
        passengers[selectedIndex].nationality = countryTF.text ?? ""
        passengers[selectedIndex].passportNo  = passportTF.text ?? ""
        delegate?.passengerListChanged(passengers)
    }

    // MARK: Actions
    @objc private func foreignChanged() {
        saveForm()
        updateForeignVisibility(animated: true)
        bindForm()
    }

    private func updateForeignVisibility(animated: Bool) {
        let isForeign = foreignSwitch.isOn
        tcTF.isEnabled = !isForeign
        tcTF.alpha = isForeign ? 0.5 : 1.0
        foreignGroup.isHidden = !isForeign
        if animated { UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() } }
    }

    // MARK: Countries
    private func buildCountries() {
        if #available(iOS 16.0, *) {
            countries = Locale.Region.isoRegions
                .compactMap { Locale.current.localizedString(forRegionCode: $0.identifier) }
                .sorted()
        } else {
            countries = Locale.isoRegionCodes
                .compactMap { Locale.current.localizedString(forRegionCode: $0) }
                .sorted()
        }
    }

    private func pickerAccessory(title: String) -> UIView {
        let bar = UIToolbar(); bar.sizeToFit()
        let t = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        t.isEnabled = false
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditingNow))
        bar.items = [t, flex, done]
        return bar
    }

    @objc private func endEditingNow() { endEditing(true) }

    // MARK: UICollectionView
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { passengers.count }
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "PassengerTabCell", for: indexPath) as! PassengerTabCell
        let seatText = seatNumbers.indices.contains(indexPath.item) ? " (Koltuk No: \(seatNumbers[indexPath.item]))" : ""
        let title = "\(indexPath.item + 1). Yolcu\(seatText)"
        cell.configure(title: title, isSelectedTab: selectedIndex == indexPath.item)
        return cell
    }
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else { return }
        saveForm()
        selectedIndex = indexPath.item
    }
    func collectionView(_ cv: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let seatText = seatNumbers.indices.contains(indexPath.item) ? " (Koltuk No: \(seatNumbers[indexPath.item]))" : ""
        let title = "\(indexPath.item + 1). Yolcu\(seatText)"
        let w = (title as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]).width + 24
        return CGSize(width: w, height: 32)
    }

    // MARK: Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { countries.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { countries[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { countryTF.text = countries[row] }

    // MARK: Return key flow
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF { tcTF.becomeFirstResponder() }
        else { textField.resignFirstResponder() }
        saveForm()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === tcTF {
            let current = textField.text ?? ""
            guard let r = Range(range, in: current) else { return false }
            let newText = current.replacingCharacters(in: r, with: string)
            let digits = newText.filter(\.isNumber)
            let clipped = String(digits.prefix(11))
            textField.text = clipped
            
            saveForm()
            return false
        }
        
        return true
    }
    
    func snapshotPassengers() -> [PassengerInfo] {
        endEditing(true)
        
        if (0..<passengers.count).contains(selectedIndex) {
            passengers[selectedIndex].fullName   = nameTF.text ?? ""
            passengers[selectedIndex].nationalId = tcTF.text ?? ""
            passengers[selectedIndex].isForeign  = foreignSwitch.isOn
            passengers[selectedIndex].nationality = countryTF.text ?? ""
            passengers[selectedIndex].passportNo  = passportTF.text ?? ""
        }
        return passengers
    }

}
