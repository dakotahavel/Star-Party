//
//  Extensions.swift
//  Space Report
//
//  Created by Dakota Havel on 1/13/23.
//

import UIKit

// MARK: - Initable

protocol Initable {
    init()
}

// MARK: - axes

enum axes {
    case horizontal
    case vertical
    case both
}

extension UIButton {
    class func configured(type buttonType: UIButton.ButtonType, closure: (UIButton) -> Void) -> UIButton {
        let i = self.init(type: buttonType)
        closure(i)
        return i
    }

    func onTouchUpInside(_ target: Any?, selector: Selector) {
        addTarget(target, action: selector, for: .touchUpInside)
    }

    class func configured(type buttonType: UIButton.ButtonType, target: Any?, selector: Selector, event: UIControl.Event = .touchUpInside, closure: (UIButton) -> Void) -> UIButton {
        let i = self.init(type: buttonType)
        i.addTarget(target, action: selector, for: event)
        closure(i)
        return i
    }
}

extension UIStackView {
    class func configured(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, _ closure: (UIStackView) -> Void) -> UIStackView {
        let i = UIStackView(arrangedSubviews: arrangedSubviews)
        i.axis = axis
        closure(i)
        return i
    }
}

extension UIBarButtonItem {
    class func configured(_ closure: (UIBarButtonItem) -> Void) -> UIBarButtonItem {
        let i = self.init()
        closure(i)
        return i
    }
}

// MARK: - UIView + Initable

extension UIView: Initable {
    class func configured<T: Initable>(_ configure: (T) -> Void) -> T {
        let instance = self.init() as! T
        configure(instance)
        return instance
    }

    func border(color: UIColor, width: CGFloat, radius: CGFloat = 0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = radius
    }

    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
    }

    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil)
    {
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }

    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }

    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false

        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true

        if let leftAnchor = leftAnchor, let padding = paddingLeft {
            self.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        }
    }

    func setDimensions(width: CGFloat?, height: CGFloat?) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }

    func fillView(_ view: UIView, axis: axes = .both, safe: Bool = true) {
        translatesAutoresizingMaskIntoConstraints = false
        switch (axis, safe) {
        case (.horizontal, false):
            anchor(left: view.leftAnchor, right: view.rightAnchor)
        case (.vertical, false):
            anchor(top: view.topAnchor, bottom: view.bottomAnchor)
        case (.both, false):
            anchor(top: view.topAnchor, left: view.leftAnchor,
                   bottom: view.bottomAnchor, right: view.rightAnchor)
        case (.horizontal, true):
            anchor(left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
        case (.vertical, true):
            anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor)
        case (.both, true):
            anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor,
                   bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
        }
    }

    func fillHorizontal(_ view: UIView, safe: Bool = true) {
        fillView(view, axis: .horizontal, safe: safe)
    }

    func fillVertical(_ view: UIView, safe: Bool = true) {
        fillView(view, axis: .vertical, safe: safe)
    }
}

// MARK: - UIColor

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...255),
            green: .random(in: 0...255),
            blue: .random(in: 0...255)
        )
    }

    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }

    static func hex(hex: Int) -> UIColor {
        return UIColor(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }
}
