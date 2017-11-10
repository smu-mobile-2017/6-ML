//
//  TestViewController.swift
//  Lab6_iOS
//
//  Created by Paul Herz on 2017-11-08.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

	@IBOutlet weak var drawView: DrawView!
	@IBOutlet weak var modelSwitch: UISwitch!
	@IBOutlet weak var accuracyLabel: UILabel!
	@IBOutlet weak var parameterTextField: UITextField!
	
	let knnParameter = "neighbors (5)"
	let sgdParameter = "α (.0001)"
	
	var currentClassifier: APIClassifier = .kNearestNeighbors
	
    override func viewDidLoad() {
        super.viewDidLoad()
		drawView.delegate = self
		parameterTextField.delegate = self
		setSwitch(to: currentClassifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setSwitch(to classifier: APIClassifier) {
		var param = ""
		switch classifier {
		case .kNearestNeighbors:
			modelSwitch.isOn = true
			param = knnParameter
		case .stochasticGradientDescent:
			modelSwitch.isOn = false
			param = sgdParameter
		}
		DispatchQueue.main.async {
			self.parameterTextField.placeholder = param
		}
	}
	
	@IBAction func modelSwitchDidChange(_ sender: Any) {
		var param = ""
		if modelSwitch.isOn {
			currentClassifier = .kNearestNeighbors
			param = knnParameter
		} else {
			currentClassifier = .stochasticGradientDescent
			param = sgdParameter
		}
		DispatchQueue.main.async {
			self.parameterTextField.placeholder = param
		}
	}
	
	@IBAction func didPressTrainModelButton(_ sender: Any) {
		DispatchQueue.main.async {
			self.accuracyLabel.text = "Accuracy: —"
		}
		var labelText = ""
		API.shared.retrain(
			usingClassifier: currentClassifier,
			parameter: self.parameterTextField.text
		) { accuracy, error in
			guard error == nil else {
				print(error!)
				return
			}
			guard let accuracy = accuracy else {
				
				labelText = "Accuracy: —"
				print("nil accuracy!")
				return
			}
			labelText = "Accuracy: \(accuracy)"
			print("ACCURACY: \(accuracy)")
			
			DispatchQueue.main.async {
				self.accuracyLabel.text = labelText
			}
		}
	}
}

extension TestViewController: DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView) {
		let image = drawView.currentImage
		let param = self.parameterTextField.text
		API.shared.classify(
			image: image,
			usingClassifier: currentClassifier,
			parameter: param
		) { label, error in
			if error != nil { print(error!) }
			if let label = label {
				drawView.labelText = "It's probably a \(label.rawValue)"
			} else {
				drawView.labelText = "I'm not sure what that is!"
			}
		}
	}
	
	func didPressEraseButton(_ drawView: DrawView) {
		drawView.labelText = ""
	}
}

extension TestViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return true
	}
}
