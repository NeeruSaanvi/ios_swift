//
//  MBSliderView.swift
//  iFocusTour
//
//  Created by Muneeb Ahmed Anwar on 26/06/2016.
//  Copyright © 2016 MysticBots. All rights reserved.
//

import UIKit

@objc protocol MBSliderDelegate {
    @objc optional func sliderViewScrubbingDidBegin(_ sliderView: MBSliderView)
    @objc optional func sliderViewScrubbingDidEnd(_ sliderView: MBSliderView)
    
    func sliderView(_ sliderView: MBSliderView, valueDidChange value: Float)
}

class MBSliderView: UIView {
    
    // MARK: - private properties
    fileprivate let slider = UISlider()
    fileprivate let lblMin = UILabel()
    fileprivate let lblMax = UILabel()
    fileprivate let lblCurrent = UILabel()
    
    fileprivate let paddingX : CGFloat = 20.0
    fileprivate let paddingY : CGFloat = 10.0
    
    fileprivate var previousValue : Float = 0.0
    
    // MARK: - public properties
    @IBOutlet weak var delegate: MBSliderDelegate?
    
    @IBInspectable var animateLabel = true
    
    @IBInspectable var ignoreDecimals : Bool {
        didSet {
            self.setValue(minValue, withUnits: self.units, forLabel: lblMin, ignoreDecimals: ignoreDecimals)
            self.setValue(maxValue, withUnits: self.units, forLabel: lblMax, ignoreDecimals: ignoreDecimals)
        }
    }
    
    @IBInspectable var minValue: Float {
        didSet {
            slider.minimumValue = minValue
            self.setValue(minValue, withUnits: self.units, forLabel: self.lblMin, ignoreDecimals: ignoreDecimals)
        }
    }
    
    @IBInspectable var maxValue: Float {
        didSet {
            slider.maximumValue = maxValue
            self.setValue(maxValue, withUnits: self.units, forLabel: self.lblMax, ignoreDecimals: ignoreDecimals)
        }
    }
    
    @IBInspectable var currentValue: Float {
        didSet {
            self.slider.value = self.currentValue
            self.updateFrameForSlider(self.slider)
        }
    }
    
    @IBInspectable var step: Float {
        didSet {
            step = (step >= 0) ? step : 0.0
        }
    }
    
    @IBInspectable var units: String {
        didSet {
            self.setValue(minValue, withUnits: self.units, forLabel: lblMin, ignoreDecimals: ignoreDecimals)
            self.setValue(maxValue, withUnits: self.units, forLabel: lblMax, ignoreDecimals: ignoreDecimals)
        }
    }
    
    // MARK: - Init
    convenience init() {
        self.init(frame: CGRect.zero, minValue: 0.0, maxValue: 1.0, currentValue: 0.5, step: 0.1, units: "", ignoreDecimals: false, animateLabel: true, delegate: nil)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: CGRect.zero, minValue: 0.0, maxValue: 1.0, currentValue: 0.5, step: 0.1, units: "", ignoreDecimals: false, animateLabel: true, delegate: nil)
    }
    
    convenience init(minValue: Float, maxValue: Float, currentValue: Float, step: Float, units: String?, ignoreDecimals: Bool, animateLabel: Bool, delegate: MBSliderDelegate?) {
        self.init(frame: CGRect.zero, minValue: minValue, maxValue: maxValue, currentValue: currentValue, step: step, units: units, ignoreDecimals: ignoreDecimals, animateLabel: animateLabel, delegate: nil)
    }
    
    init(frame: CGRect, minValue: Float, maxValue: Float, currentValue: Float, step: Float, units: String?, ignoreDecimals: Bool, animateLabel: Bool, delegate: MBSliderDelegate?) {
        
        self.ignoreDecimals = ignoreDecimals
        self.animateLabel = animateLabel
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = currentValue
        self.step = step
        self.units = (units != nil) ? units! : ""
        
        self.delegate = delegate
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        // default values
        ignoreDecimals = false
        animateLabel = true
        minValue = 0.0
        maxValue = 1.0
        currentValue = 0.5
        step = 0.1
        units = ""
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overriden methods
    override var frame: CGRect {
        didSet {
            self.setupUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
    }
    
    // MARK: - Event Listeners
    func sliderPressed(_ sender: UISlider) {
        
        DispatchQueue.main.async {
            self.delegate?.sliderViewScrubbingDidBegin?(self)
        }
        
        if animateLabel {
            self.updateCurrentLabelFrame()
            
            UIView.animate(withDuration: 0.3) {
                
                let ty = self.lblCurrent.frame.size.height
                let t1 = CGAffineTransform(translationX: 0, y: -ty)
                let t2 = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.lblCurrent.transform = t1.concatenating(t2)
                
                self.lblCurrent.textColor = UIColor.white
                self.lblCurrent.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
            }
        }
    }
    
    func sliderReleased(_ sender: UISlider) {
        
        DispatchQueue.main.async {
            self.delegate?.sliderViewScrubbingDidEnd?(self)
        }
        
        if animateLabel {
            lblCurrent.sizeToFit()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.lblCurrent.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { (done) in
                self.lblCurrent.textColor = UIColor.black
                self.lblCurrent.backgroundColor = UIColor.clear
            }
        }
    }
    
    func sliderValueChanged(_ sender: UISlider) {
        
        currentValue = sender.value // rest of the magic is in didSet of currentValue :)
        self.updateCurrentLabelFrame()
        
        DispatchQueue.main.async {
            if let value = Float(self.lblCurrent.text!) {
                if self.previousValue != value {
                    self.previousValue = value
                    self.delegate?.sliderView(self, valueDidChange: value)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func resetAllLabels() {
        self.setFrames()
        
        previousValue = currentValue
        
        slider.value = currentValue
        self.updateFrameForSlider(slider)
        self.setValue(minValue, withUnits: self.units, forLabel: lblMin, ignoreDecimals: ignoreDecimals)
        self.setValue(maxValue, withUnits: self.units, forLabel: lblMax, ignoreDecimals: ignoreDecimals)
    }
    
    fileprivate func setupUI () {
        slider.addTarget(self, action: #selector(MBSliderView.sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(MBSliderView.sliderPressed(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(MBSliderView.sliderReleased(_:)), for: .touchUpInside)

        slider.maximumTrackTintColor = UIColor.init(red: 121/255.0, green: 45/255.0, blue: 218/255.0, alpha: 1)
        slider.minimumTrackTintColor = UIColor.init(red: 121/255.0, green: 45/255.0, blue: 218/255.0, alpha: 1)
        self.setFrames()
        
        slider.autoresizingMask = .flexibleWidth
        self.addSubview(slider)
        
        lblCurrent.textColor = UIColor.black
        lblCurrent.font = UIFont.init(name: "Roboto-Regular", size: 15)
        lblCurrent.textAlignment = .center
        lblCurrent.backgroundColor = UIColor.clear
        self.addSubview(lblCurrent)
        
        lblMin.textColor = UIColor.black
        lblMin.font = UIFont.init(name: "Roboto-Regular", size: 15)
        lblMin.textAlignment = .left
        lblMin.backgroundColor = UIColor.clear
        self.addSubview(lblMin)
        
        lblMax.autoresizingMask = .flexibleWidth
        lblMax.textColor = UIColor.black
        lblMax.font = UIFont.init(name: "Roboto-Regular", size: 15)
        lblMax.textAlignment = .right
        lblMax.backgroundColor = UIColor.clear
        self.addSubview(lblMax)
        
        self.bringSubview(toFront: slider)
        self.bringSubview(toFront: lblCurrent)
        
        self.resetAllLabels()
    }
    
    fileprivate func updateCurrentLabelFrame() {
        lblCurrent.sizeToFit()
        lblCurrent.frame = CGRect(x: lblCurrent.frame.origin.x - paddingX,
                                  y: lblCurrent.frame.origin.y - paddingY,
                                  width: lblCurrent.frame.size.width + paddingX,
                                  height: lblCurrent.frame.size.height + paddingY)
    }
    
    fileprivate func setFrames() {
        DispatchQueue.main.async {
            self.slider.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: 30.0)
            self.lblCurrent.frame = CGRect(x: self.slider.frame.origin.x, y: 0.0, width: self.slider.frame.size.width, height: 20.0)
            self.lblMin.frame = CGRect(x: 0.0, y: 30.0, width: self.frame.size.width / 2.0, height: 20.0)
            self.lblMax.frame = CGRect(x: self.lblMin.frame.size.width, y: 30.0, width: self.lblMin.frame.size.width, height: 20.0)
        }
    }
    
    fileprivate func setValue(_ value: Float, withUnits units: String, forLabel label: UILabel, ignoreDecimals: Bool) {
        
        var text : String
        if ignoreDecimals {
            text = String(format: "%0.0f %@", value, units)
        } else {
            text = String(format: "%0.2f %@", value, units)
        }
        text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        DispatchQueue.main.async {
            label.text = text
        }
    }
    
    fileprivate func updateFrameForSlider(_ sender: UISlider) {
        DispatchQueue.main.async {
            if self.step > 0.0 {
                let newStep = roundf((sender.value) / self.step)
                sender.value = newStep * self.step
            }
            
            let trackRect = sender.trackRect(forBounds: sender.bounds)
            let thumbRect = sender.thumbRect(forBounds: sender.bounds, trackRect: trackRect, value: sender.value)
            self.lblCurrent.center = CGPoint(x: thumbRect.origin.x + sender.frame.origin.x + 15.0, y: sender.frame.origin.y + 15.0)
            self.setValue(sender.value, withUnits: "", forLabel: self.lblCurrent, ignoreDecimals: self.ignoreDecimals)
        }
    }
}
