//
//  BusFrontColumnCell.swift
//  biletingo
//
//  Created by Gokhan on 14.09.2025.
//

import UIKit

final class BusFrontColumnCell: UICollectionViewCell {
    private let emptySlot = UIView()
    private let exitSlot = UIView()
    private let corridorSlot = UIView()
    private let wheelSlot = UIView()

    private let exitImg = UIImageView(image: UIImage(systemName:"door.right.hand.open"))
    private let corridorImg = UIImageView(image: UIImage(systemName:"arrow.left.arrow.right"))
    private let wheelImg = UIImageView(image: UIImage(named:"SteeringWheel") ?? UIImage(systemName:"steeringwheel"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        [exitImg, corridorImg, wheelImg].forEach {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .black
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        exitSlot.addSubview(exitImg)
        corridorSlot.addSubview(corridorImg)
        wheelSlot.addSubview(wheelImg)

        let v = UIStackView(arrangedSubviews: [exitSlot, emptySlot, corridorSlot, wheelSlot])
        v.axis = .vertical
        v.spacing = 8
        v.alignment = .fill
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray2.cgColor
        contentView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            emptySlot.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            exitSlot.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            wheelSlot.heightAnchor.constraint(equalTo: contentView.widthAnchor),
            corridorSlot.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            exitImg.centerXAnchor.constraint(equalTo: exitSlot.centerXAnchor),
            exitImg.centerYAnchor.constraint(equalTo: exitSlot.centerYAnchor),
            exitImg.widthAnchor.constraint(equalToConstant: 30),
            exitImg.heightAnchor.constraint(equalToConstant: 30),
            
            corridorImg.centerXAnchor.constraint(equalTo: corridorSlot.centerXAnchor),
            corridorImg.centerYAnchor.constraint(equalTo: corridorSlot.centerYAnchor),
            corridorImg.widthAnchor.constraint(equalToConstant: 20),
            corridorImg.heightAnchor.constraint(equalToConstant: 20),
            
            wheelImg.centerXAnchor.constraint(equalTo: wheelSlot.centerXAnchor),
            wheelImg.centerYAnchor.constraint(equalTo: wheelSlot.centerYAnchor),
            wheelImg.widthAnchor.constraint(equalToConstant: 30),
            wheelImg.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension BusFrontColumnCell {
    static let reuse = "BusFrontColumnCell"
}
