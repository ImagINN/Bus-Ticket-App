//
//  PaymentInfoCard.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

protocol PaymentInfoCardDelegate: AnyObject {
    func paymentChanged(number: String, expiry: String, cvc: String)
}

final class PaymentInfoCard: CardContainerView, UITextFieldDelegate {

    // MARK: - UI
    private let cardNumberTF = TextFieldFactory.make(
        placeholder: "#### #### #### ####",
        contentType: .creditCardNumber,
        keyboard: .numberPad,
        returnKey: .next
    )
    
    private let expiryTF = TextFieldFactory.make(
        placeholder: "AA/YY",
        keyboard: .numberPad,
        returnKey: .next
    )
    
    private let cvcTF = TextFieldFactory.make(
        placeholder: "CVC2",
        keyboard: .numberPad,
        returnKey: .done
    )
    
    private let brandImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "creditcard"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .secondaryLabel
        iv.widthAnchor.constraint(equalToConstant: 48).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return iv
    }()

    weak var delegate: PaymentInfoCardDelegate?

    override init(title: String = "Ödeme Bilgileri") {
        super.init(title: title)

        [cardNumberTF, expiryTF, cvcTF].forEach { $0.delegate = self }

        cardNumberTF.inputAccessoryView = makeToolbar(title: "Kart Numarası", showsNext: true)
        expiryTF.inputAccessoryView     = makeToolbar(title: "Son Kullanma (AA/YY)", showsNext: true)
        cvcTF.inputAccessoryView        = makeToolbar(title: "CVC2", showsDone: true)

        func styleUnderline(_ tf: UITextField) -> UIStackView {
            tf.borderStyle = .none
            tf.heightAnchor.constraint(equalToConstant: 36).isActive = true
            let underline = UIView(); underline.backgroundColor = .separator
            underline.translatesAutoresizingMaskIntoConstraints = false
            underline.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
            let v = UIStackView(arrangedSubviews: [tf, underline])
            v.axis = .vertical; v.spacing = 6
            return v
        }
        
        cvcTF.isSecureTextEntry = true
        
        let numberCaption = UILabel()
        numberCaption.text = "KART NUMARASI"
        numberCaption.font = .systemFont(ofSize: 12, weight: .semibold)
        numberCaption.textColor = .secondaryLabel
        
        let numberRow = UIStackView(arrangedSubviews: [styleUnderline(cardNumberTF), brandImageView])
        numberRow.axis = .horizontal
        numberRow.alignment = .center
        numberRow.spacing = 8

        let numberBlock = UIStackView(arrangedSubviews: [numberCaption, numberRow])
        numberBlock.axis = .vertical
        numberBlock.spacing = 8
        
        let sktCaption = UILabel()
        sktCaption.text = "SKT"
        sktCaption.font = .systemFont(ofSize: 12, weight: .semibold)
        sktCaption.textColor = .secondaryLabel
        
        let sktBlock = UIStackView(arrangedSubviews: [sktCaption, styleUnderline(expiryTF)])
        sktBlock.axis = .vertical; sktBlock.spacing = 4
        
        let cvcCaption = UILabel()
        cvcCaption.text = "CVC2"
        cvcCaption.font = .systemFont(ofSize: 12, weight: .semibold)
        cvcCaption.textColor = .secondaryLabel
        
        let cvcBlock = UIStackView(arrangedSubviews: [cvcCaption, styleUnderline(cvcTF)])
        cvcBlock.axis = .vertical; cvcBlock.spacing = 4
        
        let vDivider = UIView()
        vDivider.backgroundColor = .separator
        vDivider.translatesAutoresizingMaskIntoConstraints = false
        vDivider.widthAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        
        let bottomRow = UIStackView(arrangedSubviews: [sktBlock, vDivider, cvcBlock])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .fill
        bottomRow.spacing = 12
        bottomRow.distribution = .fill
        
        sktBlock.widthAnchor.constraint(equalTo: cvcBlock.widthAnchor).isActive = true
        
        addBody([
            numberBlock,
            UIView.separator(),
            bottomRow
        ])
        
        updateBrandIcon(for: digitsOnly(cardNumberTF.text))
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public
    func getValues() -> (number: String, expiry: String, cvc: String) {
        (digitsOnly(cardNumberTF.text), expiryTF.text ?? "", digitsOnly(cvcTF.text))
    }

    // MARK: - Toolbar
    private func makeToolbar(title: String, showsNext: Bool = false, showsDone: Bool = false) -> UIView {
        let bar = UIToolbar(); bar.sizeToFit()
        let titleItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        titleItem.isEnabled = false
        var items: [UIBarButtonItem] = [titleItem, .flexibleSpace()]
        if showsNext {
            items.append(UIBarButtonItem(title: "İleri", style: .plain, target: self, action: #selector(toolbarNextTapped)))
        }
        if showsDone {
            items.append(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDoneTapped)))
        }
        bar.items = items
        return bar
    }

    @objc private func toolbarNextTapped() {
        if cardNumberTF.isFirstResponder {
            expiryTF.becomeFirstResponder()
        } else if expiryTF.isFirstResponder {
            cvcTF.becomeFirstResponder()
        }
    }
    
    @objc private func toolbarDoneTapped() { endEditing(true) }

    // MARK: - Formatting & Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ortak: mevcut metin
        let current = textField.text ?? ""
        guard let r = Range(range, in: current) else { return false }
        let newText = current.replacingCharacters(in: r, with: string)

        if textField === cardNumberTF {
            let formatted = formatCardNumber(newText)
            textField.text = formatted
            updateBrandIcon(for: digitsOnly(formatted))
            notifyChange()
            return false
        } else if textField === expiryTF {
            let formatted = formatExpiry(newText)
            textField.text = formatted
            notifyChange()
            return false
        } else if textField === cvcTF {
            let digits = digitsOnly(newText)
            // 3–4 hane
            let clipped = String(digits.prefix(4))
            textField.text = clipped
            notifyChange()
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === cardNumberTF { expiryTF.becomeFirstResponder() }
        else if textField === expiryTF { cvcTF.becomeFirstResponder() }
        else { textField.resignFirstResponder() }
        notifyChange()
        return true
    }

    // MARK: - Helpers
    private enum CardBrand { case visa, master, amex, unknown }

    private func detectBrand(_ digits: String) -> CardBrand {
        if digits.hasPrefix("4") { return .visa }
        if let i = Int(digits.prefix(4)), (2221...2720).contains(i) { return .master }
        if let i2 = Int(digits.prefix(2)), (51...55).contains(i2) { return .master }
        if digits.hasPrefix("34") || digits.hasPrefix("37") { return .amex }
        return .unknown
    }

    private func updateBrandIcon(for digits: String) {
        switch detectBrand(digits) {
        case .visa:
            brandImageView.image = UIImage(named: "cc_visa") ?? UIImage(systemName: "v.circle")
            brandImageView.tintColor = .label
        case .master:
            brandImageView.image = UIImage(named: "cc_mastercard") ?? UIImage(systemName: "m.circle")
            brandImageView.tintColor = .label
        case .amex:
            brandImageView.image = UIImage(named: "cc_amex") ?? UIImage(systemName: "a.circle")
            brandImageView.tintColor = .label
        case .unknown:
            brandImageView.image = UIImage(systemName: "creditcard")
            brandImageView.tintColor = .secondaryLabel
        }
    }
    
    private func notifyChange() {
        delegate?.paymentChanged(
            number: digitsOnly(cardNumberTF.text),
            expiry: expiryTF.text ?? "",
            cvc: digitsOnly(cvcTF.text)
        )
    }

    private func digitsOnly(_ s: String?) -> String {
        (s ?? "").filter(\.isNumber)
    }

    // 16-19 hane, 4’lü gruplama: "#### #### #### ####"
    private func formatCardNumber(_ raw: String) -> String {
        let digits = digitsOnly(raw).prefix(19)
        var groups: [String] = []
        var i = digits.startIndex
        while i < digits.endIndex {
            let next = digits.index(i, offsetBy: 4, limitedBy: digits.endIndex) ?? digits.endIndex
            groups.append(String(digits[i..<next]))
            i = next
        }
        return groups.joined(separator: " ")
    }

    // "AA/YY" otomatik slash + ay aralığı
    private func formatExpiry(_ raw: String) -> String {
        let digits = digitsOnly(raw).prefix(4) // AAYY
        var result = ""
        for (idx, ch) in digits.enumerated() {
            if idx == 0 {
                // Ay ilk hanesi: 0-1; 2-9 yazılırsa başına '0' ekle
                if ch > "1" { result.append("0"); result.append(ch); result.append("/") ; return result }
                result.append(ch)
            } else if idx == 1 {
                // Ay ikinci hanesi 0-9 ama 00 olmasın
                if result.first == "0", ch == "0" { result.append("1") } else { result.append(ch) }
                result.append("/")
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
