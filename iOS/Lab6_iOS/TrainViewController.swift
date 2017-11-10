//
//  TrainViewController.swift
//  
//
//  Created by Paul Herz on 2017-11-08.
//

import UIKit

// 0, 0, 0, 1, 1, 1, 2, 2, 2, ...
struct NumberLabelGenerator: Sequence, IteratorProtocol {
	private var state: Int?
	private var repeats: Int = 0
	typealias Element = NumberLabel
	
	mutating func next() -> NumberLabelGenerator.Element? {
		// nil case (first time)
		if state == nil {
			state = 0
			repeats = 0
		}
			// repeat case
		else if state != nil, repeats < 2 {
			repeats += 1
		}
			// increment case
		else {
			state = (state! + 1) % 10
			repeats = 0
		}
		
		return NumberLabel(rawValue: state!)
	}
}

class TrainViewController: UIViewController {

	@IBOutlet weak var drawView: DrawView!
	
	var labelGenerator = NumberLabelGenerator()
	
	var currentNumberLabel: NumberLabel! {
		didSet {
			drawView.labelText = "Draw a \(currentNumberLabel.rawValue)"
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		drawView.delegate = self
		drawView.style = .inverted
		setNextNumberLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setNextNumberLabel() {
		self.currentNumberLabel = labelGenerator.next()!
	}
}

extension TrainViewController: DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView) {
		print("[TrainViewController] didPressSendButton")
		let image = drawView.currentImage
		API.shared.send(image: image, withLabel: currentNumberLabel)
		drawView.erase()
		setNextNumberLabel()
	}
	
	func didPressEraseButton(_ drawView: DrawView) {}
}
