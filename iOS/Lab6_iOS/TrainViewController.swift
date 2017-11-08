//
//  TrainViewController.swift
//  
//
//  Created by Paul Herz on 2017-11-08.
//

import UIKit

class TrainViewController: UIViewController {

	@IBOutlet weak var drawView: DrawView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		drawView.delegate = self
		drawView.style = .inverted
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TrainViewController: DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView) {
		print("[TrainViewController] didPressSendButton")
		
	}
}
