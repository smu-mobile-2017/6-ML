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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		drawView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TestViewController: DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView) {
		let image = drawView.currentImage
		
		API.shared.classify(image: image) { label, error in
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
