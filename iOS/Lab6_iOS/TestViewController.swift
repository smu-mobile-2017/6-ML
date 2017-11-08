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
		print("[TestViewController] didPressSendButton")
	}
}
