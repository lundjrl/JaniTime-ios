//
//  Extension.swift
//  Janitime
//
//  Created by test on 27/11/18.
//  Copyright © 2018 Sidharth J Dev. All rights reserved.
//

import Foundation
import UIKit
import Lottie

var isLoaderAnimationRunning = false
var loaderAnimationProgressLabel = UILabel()
var linkaOperationDuration: CGFloat?
var animationView: LOTAnimationView?


// MARK: Textfeild Underline and Placeholder Color
extension UITextField {
    func underlined() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
}

// MARK: Gradient to View
extension UIView {
    func setGradientBackground(colorFrom: UIColor, colorTo: UIColor, borderColor: CGColor = UIColor.clear.cgColor, isTopDown: Bool = false, inverseColor: Bool = false, clippingRadius: CGFloat = 0, gradient: CAGradientLayer) {
        //gradient = CAGradientLayer()
        gradient.frame = self.bounds
        if inverseColor {
            gradient.colors = [colorTo.cgColor, colorFrom.cgColor]
        } else {
            gradient.colors = [colorFrom.cgColor, colorTo.cgColor]
        }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        if isTopDown{
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        }
        self.layer.insertSublayer(gradient, at: 0)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        //setting border
        self.layer.borderColor = borderColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = clippingRadius
        
    }
    

    
    func setGradientWith(colors: [CGColor], angle: Float = 0) {
        let gradientLayerView: UIView = UIView(frame: CGRect(x:0, y: 0, width: bounds.width, height: bounds.height))
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gradientLayerView.bounds
        gradient.colors = colors
        
        let alpha: Float = angle / 360
        let startPointX = powf(
            sinf(2 * Float.pi * ((alpha + 0.75) / 2)),
            2
        )
        let startPointY = powf(
            sinf(2 * Float.pi * ((alpha + 0) / 2)),
            2
        )
        let endPointX = powf(
            sinf(2 * Float.pi * ((alpha + 0.25) / 2)),
            2
        )
        let endPointY = powf(
            sinf(2 * Float.pi * ((alpha + 0.5) / 2)),
            2
        )
        
        gradient.endPoint = CGPoint(x: CGFloat(endPointX),y: CGFloat(endPointY))
        gradient.startPoint = CGPoint(x: CGFloat(startPointX), y: CGFloat(startPointY))
        
        gradientLayerView.layer.insertSublayer(gradient, at: 0)
        layer.insertSublayer(gradientLayerView.layer, at: 0)
    }
    
    func makeCapsuleShape(color : UIColor, borderWidth: CGFloat = 0.5) {
        let layer = self.layer
        layer.borderWidth = borderWidth
        layer.borderColor = color.cgColor
        layer.cornerRadius = layer.frame.size.height/2
        layer.masksToBounds = true
        self.clipsToBounds = true
        
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    

    func cornerRadius(corners: UIRectCorner, radius: CGFloat) {
            
            let rectShape = CAShapeLayer()
            clipsToBounds = true
            rectShape.bounds = bounds
            rectShape.position = center
            rectShape.bounds.size.width = bounds.size.width
            rectShape.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
                //UIBezierPath(roundedRect: bounds,    byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius)).cgPath
            layer.mask = rectShape
        }
    
}


@IBDesignable class circularLabelView: UILabel{
    @IBInspectable var borderColor:UIColor = UIColor.white {
        willSet {
            layer.borderColor = newValue.cgColor
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/2
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
    }
}

// MARK: Colors used in this project
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

// MARK: Trimming space in text
extension String {
    func trimmedText() -> String {
        if self != ""
        {
            let currentText = self
            let trimmedText = currentText.replacingOccurrences(of: " ", with: "")
            return trimmedText
        }
        else
        {
            return ""
        }
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}


// MARK: Alert
extension UIViewController: UIGestureRecognizerDelegate {
    func showAlert(title: String, message: String, actionButtons: [UIAlertAction] = [UIAlertAction(title: "OK", style: UIAlertAction.Style.default)]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actionButtons {
                alert.addAction(action)
            }
            self.present(alert, animated: true)
        }
    }
}


// MARK: For custom loading
extension UIView {
    
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blurView"
    }
    
    private (set) var blurView: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName
                ) as? BlurView {
                return blurView
            }
            self.blurView = BlurView(to: self)
            return self.blurView
        }
        set(blurView) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName,
                blurView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    class BlurView {
        
        private var superview: UIView
        private var blur: UIVisualEffectView?
        private var editing: Bool = false
        private (set) var blurContentView: UIView?
        private (set) var vibrancyContentView: UIView?
        
        var animationDuration: TimeInterval = 0.1
        
        /**
         * Blur style. After it is changed all subviews on
         * blurContentView & vibrancyContentView will be deleted.
         */
        var style: UIBlurEffect.Style = .light {
            didSet {
                guard oldValue != style,
                    !editing else { return }
                applyBlurEffect()
            }
        }
        /**
         * Alpha component of view. It can be changed freely.
         */
        var alpha: CGFloat = 0 {
            didSet {
                guard !editing else { return }
                if blur == nil {
                    applyBlurEffect()
                }
                let alpha = self.alpha
                UIView.animate(withDuration: animationDuration) {
                    self.blur?.alpha = alpha
                }
            }
        }
        
        init(to view: UIView) {
            self.superview = view
        }
        
        func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
            self.editing = true
            
            self.style = style
            self.alpha = alpha
            
            self.editing = false
            
            return self
        }
        
        func enable(isHidden: Bool = false) {
            if blur == nil {
                applyBlurEffect()
            }
            
            self.blur?.isHidden = isHidden
        }
        
        private func applyBlurEffect() {
            blur?.removeFromSuperview()
            
            applyBlurEffect(
                style: style,
                blurAlpha: alpha
            )
        }
        
        private func applyBlurEffect(style: UIBlurEffect.Style,
                                     blurAlpha: CGFloat) {
            superview.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            blurEffectView.alpha = blurAlpha
            
            superview.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.addAlignedConstrains()
            vibrancyView.addAlignedConstrains()
            
            self.blur = blurEffectView
            self.blurContentView = blurEffectView.contentView
            self.vibrancyContentView = vibrancyView.contentView
        }
    }
    
    private func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }
    
    private func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
}


extension UITextField {
    override open var intrinsicContentSize: CGSize {
        
        if isEditing {
            let string = (text ?? "") as NSString
            let stringSize:CGSize = string.size(withAttributes:
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize:
                    19.0)])
            if self.frame.minX > 71.0 {
                return stringSize
            }
        }
        
        return super.intrinsicContentSize
    }

}


extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: size).image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
    
    func resizedWith(percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    
}


extension UIView {
    
    func showLoaderAnimation(loaderType: JaniTime.animationLoaderType, message: String = "Loading..", bgColor: UIColor = UIColor.black, fullScreenImage: UIImage? = nil, title: String = "", playOnce: Bool = false, dismissAfterAnimation: Bool = true, animationSpeed: CGFloat = 1, animationProgress: CGFloat = 0, exitButtonTitle: String = "", animationViewSizeMultiplier: CGFloat = 1, showBlurredView: Bool = true, hintRequired: Bool = false, completionHandler: ((Double) -> ())? = nil) {
        
        guard let lotAnimationDataFile = JaniTime.lottieFiles[loaderType] else {
            return
        }
        let displayColor = bgColor
        var animationDuration:CGFloat = 0
        
        
        
        DispatchQueue.main.async {
            
            if !isLoaderAnimationRunning {
                isLoaderAnimationRunning = true
                
                if fullScreenImage != nil {
                    
                    
                    
                    //Setting up background view
                    let backgroundView = UIView(frame: self.frame)
                    backgroundView.backgroundColor = displayColor
                    backgroundView.tag = 10101
                    
                    //Setting up image view
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 20, width: self.frame.width, height: self.frame.height/3))
                    imageView.center.x = self.center.x
                    imageView.center.y = 150
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = fullScreenImage
                    
                    //Setting up title label
                    let titleLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + 50, width: self.frame.width - 40, height: 30))
                    titleLabel.numberOfLines = 0
                    titleLabel.center.x = self.center.x
                    titleLabel.textColor = UIColor.white
                    titleLabel.lineBreakMode = .byWordWrapping
                    titleLabel.textAlignment = .center
                    titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                    titleLabel.text = title
                    
                    //Setting up message label
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: titleLabel.frame.maxY - 20, width: self.frame.width - 40, height: 100))
                    messageLabel.numberOfLines = 0
                    messageLabel.text = message
                    messageLabel.sizeToFit()
                    messageLabel.center.x = self.center.x
                    messageLabel.textColor = UIColor.white
                    messageLabel.lineBreakMode = .byWordWrapping
                    messageLabel.textAlignment = .center
                    
                    
                    //Setting up progress label
                    let progressLabel = UILabel(frame: CGRect(x: 0, y: messageLabel.frame.maxY, width: self.frame.width - 40, height: 30))
                    progressLabel.numberOfLines = 0
                    progressLabel.center.x = messageLabel.center.x
                    progressLabel.textColor = UIColor.white
                    progressLabel.lineBreakMode = .byWordWrapping
                    progressLabel.textAlignment = .center
                    progressLabel.text = ""
                    loaderAnimationProgressLabel = progressLabel
                    
                    if exitButtonTitle != "" {
                        let button = UIButton(frame:  CGRect(x: 0, y: self.frame.maxY - 50, width: self.frame.width, height: 50))
                        button.setTitleColor(UIColor.white, for: .normal)
                        button.setTitle(exitButtonTitle, for: .normal)
                        button.center.x = backgroundView.center.x
                        button.backgroundColor = UIColor.clear
                        button.addTarget(self, action: #selector(self.tappedAnimationView), for: .touchUpInside)
                        backgroundView.addSubview(button)
                    } else {
                        //Setting up hint label
                        let bottomLabel = UILabel(frame: CGRect(x: 0, y: self.frame.maxY - 70, width: self.frame.width, height: 50))
                        bottomLabel.textColor = UIColor.white.withAlphaComponent(0.3)
                        bottomLabel.numberOfLines = 2
                        bottomLabel.lineBreakMode = .byWordWrapping
                        bottomLabel.textAlignment = .center
                        bottomLabel.center.x = backgroundView.center.x
                        bottomLabel.font = bottomLabel.font.withSize(15)
                        bottomLabel.text = "triple tap to dismiss"
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                            backgroundView.addSubview(bottomLabel)
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedAnimationView))
                            tapGesture.numberOfTapsRequired = 3
                            backgroundView.addGestureRecognizer(tapGesture)
                        })
                    }
                    
                    //Adding all subviews to respective views
                    backgroundView.addSubview(imageView)
                    backgroundView.addSubview(titleLabel)
                    backgroundView.addSubview(messageLabel)
                    backgroundView.addSubview(loaderAnimationProgressLabel)
                    
                    self.addSubview(backgroundView)
                    backgroundView.alpha = 0
                    //                    UIView.animate(withDuration: 0.5, animations: {
                    //                        backgroundView.alpha = 1
                    //                    })
                } else {
                    let imageSize: CGFloat = 150
                    
                    //Setting up lottie
                    
                    if var topController = UIApplication.shared.keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        for eachView in self.subviews {
                            if eachView.tag == 10101 {
                                eachView.alpha = 0
                                eachView.removeFromSuperview()
                            }
                        }
                    }
                    
                    animationView = LOTAnimationView(name: lotAnimationDataFile)
                    Logger.print(lotAnimationDataFile)
                    animationView?.frame.size = CGSize(width: animationView!.frame.size.width * animationViewSizeMultiplier, height: animationView!.frame.size.height * animationViewSizeMultiplier)
                    
                    
                    if playOnce {
                        animationView?.loopAnimation = false
                        if dismissAfterAnimation {
                            DispatchQueue.main.asyncAfter(deadline: (.now() + Double((animationView?.animationDuration)!)), execute: {
                                self.hideLoaderAnimation()
                            })
                        }
                    } else {
                        animationView?.loopAnimation = true
                    }
                    animationView?.animationSpeed = animationSpeed
                    animationDuration = (animationView?.animationDuration)!
                    animationView?.animationProgress = animationProgress
                    animationView?.play()
                    
                    //Setting up background view
                    
                    let backgroundView = UIView(frame: self.frame)
                    backgroundView.backgroundColor = displayColor
                    
                    animationView?.center = CGPoint(x: backgroundView.center.x, y: backgroundView.center.y - (imageSize / 4) - 10)
                    
                    //Setting up message label
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width / 2, height: 100))
                    label.textColor = UIColor.white //Mole.colors.darkBlue
                    label.numberOfLines = 5
                    label.text = message
                    label.sizeToFit()
                    label.lineBreakMode = .byWordWrapping
                    label.textAlignment = .center
                    label.center.x = backgroundView.center.x
                    label.frame.origin.y = (animationView?.frame.maxY)!
                    label.glow(120)
                    
                    //Setting up progress label
                    let progressLabel = UILabel(frame: CGRect(x: 0, y: label.frame.maxY, width: self.frame.width - 40, height: 30))
                    progressLabel.numberOfLines = 0
                    progressLabel.center.x = label.center.x
                    progressLabel.textColor = UIColor.black
                    progressLabel.lineBreakMode = .byWordWrapping
                    progressLabel.textAlignment = .center
                    progressLabel.text = ""
                    loaderAnimationProgressLabel = progressLabel
                    
                    //Setting up blurred view
                    
                    //                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
                    //                    let blurredView = UIVisualEffectView(effect: blurEffect)
                    //                    blurredView.effect = blurEffect
                    //                    blurredView.contentView.addSubview(backgroundView)
                    
                    let blurredView = UIView()
                    blurredView.blurView.setup(style: UIBlurEffect.Style.extraLight, alpha: 0.7).enable()
                    
                    blurredView.frame = self.bounds
                    blurredView.tag = 10101
                    
                    blurredView.alpha = 0.7
                    //Adding all subviews to respective views
                    
                    blurredView.addSubview(backgroundView)
                    backgroundView.addSubview(animationView!)
                    backgroundView.addSubview(label)
                    backgroundView.addSubview(loaderAnimationProgressLabel)
                    
                    if exitButtonTitle != "" {
                        let button = UIButton(frame:  CGRect(x: 0, y: self.frame.maxY - 50, width: self.frame.width, height: 50))
                        button.setTitleColor(UIColor.white, for: .normal)
                        button.setTitle(exitButtonTitle, for: .normal)
                        button.center.x = backgroundView.center.x
                        button.backgroundColor = UIColor.clear
                        button.addTarget(self, action: #selector(self.tappedAnimationView), for: .touchUpInside)
                        backgroundView.addSubview(button)
                    } else if hintRequired {
                        //Setting up hint label
                        
                        let bottomLabel = UILabel(frame: CGRect(x: 0, y: self.frame.maxY - 70, width: self.frame.width, height: 50))
                        bottomLabel.textColor = UIColor.white.withAlphaComponent(0.3)
                        bottomLabel.numberOfLines = 2
                        bottomLabel.lineBreakMode = .byWordWrapping
                        bottomLabel.textAlignment = .center
                        bottomLabel.center.x = backgroundView.center.x
                        bottomLabel.font = bottomLabel.font.withSize(15)
                        bottomLabel.text = "triple tap to dismiss"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                            backgroundView.addSubview(bottomLabel)
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedAnimationView))
                            tapGesture.numberOfTapsRequired = 3
                            blurredView.addGestureRecognizer(tapGesture)
                        })
                    }
                    if showBlurredView {
                        self.addSubview(blurredView)
                    } else {
                        self.addSubview(backgroundView)
                    }
                    completionHandler?(Double(animationDuration))
                }
            }
        }
    }
    
    @objc func tappedAnimationView() {
        hideLoaderAnimation()
    }
    
    func hideLoaderAnimation() {
        DispatchQueue.main.async {
            for eachView in self.subviews {
                if eachView.tag == 10101 {
                    UIView.animate(withDuration: 0.5, animations: {
                        eachView.alpha = 0
                    }, completion: { (_) in
                        eachView.removeFromSuperview()
                    })
                    break
                }
            }
            isLoaderAnimationRunning = false
        }
    }
}


// MARK: Glow effect to Label
extension UILabel {
    func glow(_ stopAfter: Double? = 2) {
        let labelTransparency: CGFloat = 0.1
        let labelWidth: CGFloat = self.frame.size.width
        
        let glowSize: CGFloat = 40 / labelWidth
        
        let startingLocations: NSArray = [NSNumber.init(value: 0.0), NSNumber.init(value: ((Float)(glowSize / 2))), NSNumber.init(value: ((Float)(glowSize) / 1))]
        
        let endingLocations = [(1.0 - glowSize), (1.0 - (glowSize / 2)), 1.0] as NSArray
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
        let glowMask: CAGradientLayer = CAGradientLayer.init()
        glowMask.frame = self.bounds
        
        let gradient = UIColor.init(white: 0.5, alpha: labelTransparency)
        glowMask.colors = [gradient.cgColor, UIColor.white.cgColor, gradient.cgColor]
        glowMask.locations = startingLocations as? [NSNumber]
        glowMask.startPoint = CGPoint(x: 0 - (glowSize * 2), y: 1)
        glowMask.endPoint = CGPoint(x: 1 + glowSize, y: 1)
        self.layer.mask = glowMask
        
        animation.fromValue = startingLocations
        animation.toValue = endingLocations
        animation.repeatCount = Float.infinity
        animation.duration = 1.6
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        glowMask.add(animation, forKey: "gradientAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + stopAfter!) {
            glowMask.removeAllAnimations()
            self.layer.mask = nil
        }
    }
}


public extension UIView {
    // to set background image for a view:
    func setBackground(_ imageName: String) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "\(imageName)")
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
    
    func shake(_ color: UIColor? = nil, height: CGFloat? = nil, duration: Double = 0.08, additionalViewToChangeColor: UIView? = nil) {
        self.superview?.isUserInteractionEnabled = false
        let additionalViewColor = additionalViewToChangeColor?.backgroundColor
        let originalColor = self.backgroundColor
        let originalHeight = self.frame.size.height
        let originalCenterX = self.center.x
        
        self.backgroundColor = color != nil ? color : originalColor
        UIView.animate(withDuration: 0.5) {
            additionalViewToChangeColor?.backgroundColor = color != nil ? color : originalColor
        }
        
        self.frame.size.height = (height != nil ? height : self.frame.size.height + 2)!
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .autoreverse], animations: {
            self.center.x = originalCenterX + 4
        }) { (true) in
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .autoreverse], animations: {
                self.center.x = originalCenterX - 7
            }) { (true) in
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .autoreverse], animations: {
                    self.center.x = originalCenterX + 6
                }) { (true) in
                    UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .autoreverse], animations: {
                        self.center.x = originalCenterX - 5
                    }) { (true) in
                        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .autoreverse], animations: {
                            self.center.x = originalCenterX
                        }) { (true) in
                            self.frame.size.height = originalHeight
                            self.backgroundColor = originalColor
                            UIView.animate(withDuration: 0.5) {
                                additionalViewToChangeColor?.backgroundColor = additionalViewColor
                            }
                            self.superview?.isUserInteractionEnabled = true
                        }
                    }
                }
            }
        }
    }
}

extension Int {
    func toTime() -> String {
        if self > 60 {
            if self > 3600 {
                if self%3600 == 0 {
                    return "\(self/3600) H"
                } else {
                    return "\(self/3600) H:\(self/60) m:\(self%3600) s"
                }
            }
            else {
                if self%60 == 0 {
                    return "\(self/60) m"
                } else {
                    return "\(self/60) m:\(self%60)s"
                }
            }
        } else {
            return "\(self) s"
        }
        
    }
}
