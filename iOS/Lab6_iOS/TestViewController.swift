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
	
	var currentClassifier: APIClassifier = .kNearestNeighbors
	
    override func viewDidLoad() {
        super.viewDidLoad()
		drawView.delegate = self
		setSwitch(to: currentClassifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setSwitch(to classifier: APIClassifier) {
		switch classifier {
		case .kNearestNeighbors:
			modelSwitch.isOn = true
		case .supportVectorMachine:
			modelSwitch.isOn = false
		}
	}
	
	@IBAction func modelSwitchDidChange(_ sender: Any) {
		if modelSwitch.isOn {
			currentClassifier = .kNearestNeighbors
		} else {
			currentClassifier = .supportVectorMachine
		}
	}
	
	@IBAction func didPressTrainModelButton(_ sender: Any) {
		API.shared.retrain(usingClassifier: currentClassifier)
	}
}

extension TestViewController: DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView) {
		let image = drawView.currentImage
		API.shared.classify(image: image, usingClassifier: currentClassifier)
		{ label, error in
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
