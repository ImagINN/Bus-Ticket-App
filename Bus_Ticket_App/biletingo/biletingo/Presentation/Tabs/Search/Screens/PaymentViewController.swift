//
//  PaymentViewController.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

final class PaymentViewController: UIViewController, ContactInfoCardDelegate, PassengerInfoCardDelegate, PaymentInfoCardDelegate {
    
    var ticket: Ticket!

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let tripCard = TripInfoCard()
    private let priceCard = PriceInfoCard()
    private let contactCard = ContactInfoCard()
    private let passengerCard = PassengerInfoCard()
    private let paymentCard = PaymentInfoCard()

    private var contactPhone: String = ""
    private var contactEmail: String = ""
    private var passengers: [PassengerInfo] = []
    
    private lazy var payButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Ödeme Yap", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .mainGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Ödeme"

        contactCard.delegate = self
        passengerCard.delegate = self
        paymentCard.delegate = self

        setupUI()

        tripCard.bind(ticket: ticket)
        priceCard.bind(totalPrice: ticket.totalPrice)
        passengerCard.configure(seatNumbers: ticket.seatNumbers)

        // Dışarı dokununca klavye kapanması
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingNow))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        scrollView.keyboardDismissMode = .interactive
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillChange(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [tripCard, priceCard, contactCard, passengerCard, paymentCard, payButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(16, after: paymentCard)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    // MARK: Delegates
    func contactChanged(phone: String, email: String) {
        contactPhone = phone; contactEmail = email
    }
    
    func passengerListChanged(_ passengers: [PassengerInfo]) {
        self.passengers = passengers
    }
    
    func paymentChanged(number: String, expiry: String, cvc: String) { }
    
    // MARK: Actions
    @objc private func kbWillChange(_ note: Notification) {
        guard
            let info = note.userInfo,
            let endFrameVal = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let kbFrameInView = view.convert(endFrameVal, from: nil)
        let overlap = view.bounds.intersection(kbFrameInView).height
        let bottomInset = max(0, overlap - view.safeAreaInsets.bottom)

        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.scrollView.contentInset.bottom = bottomInset
            self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            self.scrollActiveFieldIntoView()
        }, completion: nil)
    }

    private func scrollActiveFieldIntoView(padding: CGFloat = 16) {
        guard let firstResponder = view.findFirstResponder() as? UIView else { return }
        let rect = firstResponder.convert(firstResponder.bounds, to: scrollView)
            .insetBy(dx: 0, dy: -padding)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    private func validateForm() -> Bool {
        // 1) İletişim
        let (phoneDigitsOk, emailOk) = (validatePhone(contactPhone), validateEmail(contactEmail))
        guard phoneDigitsOk else { return fail("Lütfen geçerli bir telefon numarası girin.") }
        guard emailOk else { return fail("Lütfen geçerli bir e-posta adresi girin.") }

        // 2) Yolcular
        let pax = passengerCard.snapshotPassengers()
        guard pax.count == ticket.seatNumbers.count else {
            return fail("Yolcu sayısı koltuk sayısıyla uyuşmuyor.")
        }
        for (i, p) in pax.enumerated() {
            let idx = i + 1
            guard !p.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return fail("\(idx). yolcu için Ad Soyad zorunlu.") }

            if p.isForeign {
                guard !p.nationality.isEmpty else { return fail("\(idx). yolcu için Uyruk seçiniz.") }
                guard !p.passportNo.trimmingCharacters(in: .whitespaces).isEmpty
                else { return fail("\(idx). yolcu için Pasaport Numarası zorunlu.") }
            } else {
                // TC
                let digits = p.nationalId.filter(\.isNumber)
                guard digits.count == 11 else { return fail("\(idx). yolcu için T.C. Kimlik No 11 haneli olmalıdır.") }
            }
        }

        // 3) Ödeme
        let pay = paymentCard.getValues()
        let numberDigits = pay.number
        guard (13...19).contains(numberDigits.count) else { return fail("Kart numarası geçersiz görünüyor.") }
        guard validateExpiry(pay.expiry) else { return fail("Son kullanma tarihi (AA/YY) geçersiz.") }
        guard (3...4).contains(pay.cvc.count) else { return fail("CVC2 3 veya 4 haneli olmalıdır.") }

        return true
    }

    private func validatePhone(_ raw: String) -> Bool {
        let digits = raw.filter(\.isNumber)
        return digits.count >= 10
    }
    private func validateEmail(_ s: String) -> Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return s.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }
    private func validateExpiry(_ s: String) -> Bool {
        // Beklenen "MM/YY"
        let comps = s.split(separator: "/")
        guard comps.count == 2, comps[0].count == 2, comps[1].count == 2,
              let mm = Int(comps[0]), let yy = Int(comps[1]), (1...12).contains(mm) else { return false }

        // Geçmiş tarih kontrolü
        let cal = Calendar.current
        let now = Date()
        let curYY = cal.component(.year, from: now) % 100
        let curMM = cal.component(.month, from: now)

        if yy > curYY { return true }
        if yy == curYY { return mm >= curMM }
        return false
    }

    @discardableResult
    private func fail(_ message: String) -> Bool {
        let ac = UIAlertController(title: "Eksik / Hatalı Bilgi", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
        return false
    }

    @objc private func endEditingNow() { view.endEditing(true) }
    
    @objc private func payTapped() {
        view.endEditing(true)

        guard validateForm() else { return }

        let createVC = CreateTicketViewController()
        createVC.hidesBottomBarWhenPushed = true
        createVC.ticket = ticket
        createVC.passengers = passengerCard.snapshotPassengers()
        createVC.contactPhone = contactPhone
        createVC.contactEmail = contactEmail

        navigationController?.pushViewController(createVC, animated: true)
    }

}

private extension UIView {
    func findFirstResponder() -> UIResponder? {
        if isFirstResponder { return self }
        for sub in subviews {
            if let r = sub.findFirstResponder() { return r }
        }
        return nil
    }
}
