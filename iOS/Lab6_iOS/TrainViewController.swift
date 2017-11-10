//
//  TrainViewController.swift
//  
//
//  Created by Paul Herz on 2017-11-08.
//

import UIKit

class TrainViewController: UIViewController {

	@IBOutlet weak var drawView: DrawView!
	
	var currentNumberClass: NumberLabel! {
		didSet {
			drawView.labelText = "Draw a \(currentNumberClass.rawValue)"
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		drawView.delegate = self
		drawView.style = .inverted
		setNextNumberClass()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setNextNumberClass() {
		self.currentNumberClass = NumberLabel.random()
	}
}

extension TrainViewController: DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView) {
		print("[TrainViewController] didPressSendButton")
		let image = drawView.currentImage
		API.shared.send(image: image, withLabel: currentNumberClass)
		drawView.erase()
		setNextNumberClass()
	}
	
	func didPressEraseButton(_ drawView: DrawView) {}
}
