//
//  ViewController.swift
//  HTTPSwiftExample
//
//  Created by Eric Larson on 3/30/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

// This exampe is meant to be run with the python example:
//              tornado_example.py 
//              from the course GitHub repository: tornado_bare, branch sklearn_example


// if you do not know your local sharing server name try:
//    ifconfig |grep inet   
// to see what your public facing IP address is, the ip address can be used here

//let SERVER_URL = "http://129.119.235.12:8000" // localhost
let SERVER_URL = "http://104.236.107.228:8000" // digital ocean

import UIKit

class TrainViewController: UIViewController, URLSessionDelegate {
	
    var session = URLSession()
    let operationQueue = OperationQueue()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.dsidPicker.delegate = self
		self.dsidPicker.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = 0.5
        
        
        // setup core motion handlers
        startMotionUpdates()
        
        dsid = 2 // set this and it will update UI
		dsidPicker.reloadAllComponents()
}


//extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//
//	func numberOfComponents(in pickerView: UIPickerView) -> Int {
//		return 1
//	}
//
//	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//		return dsids.count
//	}
//
//	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//		return "\(dsids[row])"
//	}
//
//	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//		self.dsid = dsids[row]
//	}
//}





