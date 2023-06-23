//
//  ColorPickerViewController.swift
//  ToDoList
//
//  Created by Аброрбек on 22.06.2023.
//

import UIKit

final class ColorPickerViewController: UIViewController {
    
    var colorPaletteView: UIImageView!
    var selectedColorView: UIView!
    var brightnessSlider: UISlider!
    var colorCodeLabel: UILabel!
    
    var selectedColor: UIColor = .white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "#3AFDFF")
        
        // Create color palette view
        
        colorPaletteView = UIImageView(frame: CGRect(x: 100, y: 250, width: 200, height: 200))
        colorPaletteView.backgroundColor = .white
        colorPaletteView.layer.borderColor = UIColor.black.cgColor
        colorPaletteView.layer.borderWidth = 1
        colorPaletteView.image = UIImage(named: "colorPallet")
        colorPaletteView.isUserInteractionEnabled = true
        view.addSubview(colorPaletteView)
        
        // Add gesture recognizer to the color palette view
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        colorPaletteView.addGestureRecognizer(panGestureRecognizer)
        
        // Create selected color view
        selectedColorView = UIView(frame: CGRect(x: 50, y: 130, width: 100, height: 100))
        selectedColorView.backgroundColor = selectedColor
        selectedColorView.layer.borderColor = UIColor.black.cgColor
        selectedColorView.layer.borderWidth = 1
        view.addSubview(selectedColorView)
        
        // Create brightness slider
        brightnessSlider = UISlider(frame: CGRect(x: 100, y: 480, width: 200, height: 30))
        brightnessSlider.minimumValue = 0.0
        brightnessSlider.maximumValue = 1.0
        brightnessSlider.value = 1.0
        brightnessSlider.addTarget(self, action: #selector(brightnessSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(brightnessSlider)
        
        // Create color code label
        colorCodeLabel = UILabel(frame: CGRect(x: 170, y: 160, width: 200, height: 30))
        colorCodeLabel.textAlignment = .center
        colorCodeLabel.textColor = .black
        
        updateColorPicker()
        view.addSubview(colorCodeLabel)
    }
    
    // Handle pan gesture on the color palette view
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let location = gestureRecognizer.location(in: colorPaletteView)
        // Update selected color based on the location of the finger on the color palette
        if location.x >= 0 && location.x <= colorPaletteView.bounds.width &&
            location.y >= 0 && location.y <= colorPaletteView.bounds.height {
            let hue = location.x / colorPaletteView.bounds.width
            let saturation = 1.0 - (location.y / colorPaletteView.bounds.height)
            selectedColor = UIColor(hue: hue, saturation: saturation, brightness: CGFloat(brightnessSlider.value), alpha: 1.0)
            
            // Update color picker UI
            updateColorPicker()
        }
    }
    
    // Handle brightness slider value change
    @objc func brightnessSliderValueChanged(_ sender: UISlider) {
        // Update selected color based on the brightness slider value
        selectedColor = selectedColor.withBrightness(CGFloat(sender.value))
        
        // Update color picker UI
        updateColorPicker()
    }
    
    // Update color picker UI
    func updateColorPicker() {
        // Update selected color view
        selectedColorView.backgroundColor = selectedColor
        
        // Update color code label
        let colorComponents = selectedColor.rgbComponents()
        let colorCode = String(format: "#%02X%02X%02X", Int(colorComponents.red * 255), Int(colorComponents.green * 255), Int(colorComponents.blue * 255))
        colorCodeLabel.text = colorCode
    }
}

extension UIColor {
    // Get the RGB components of a color
    func rgbComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue)
    }
    
    // Create a new color with the specified brightness
    func withBrightness(_ brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}
