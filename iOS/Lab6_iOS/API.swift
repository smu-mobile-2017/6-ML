//
//  API.swift
//  Lab6_iOS
//
//  Created by Justin Wilson on 11/8/17.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//

import Foundation

class API {

//MARK: Comm with Server
	func sendFeatures(_ array:[Double], withLabel label:CalibrationStage){
		let baseURL = "\(SERVER_URL)/AddDataPoint"
		let postUrl = URL(string: "\(baseURL)")
	
		// create a custom HTTP POST request
		var request = URLRequest(url: postUrl!)
	
		// data to send in body of post request (send arguments as json)
		let jsonUpload:NSDictionary = ["feature":array,
									   "label":"\(label)",
			"dsid":self.dsid]
	
	
		let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
	
		request.httpMethod = "POST"
		request.httpBody = requestBody
	
		let postTask : URLSessionDataTask = self.session.dataTask(with: request,
																  completionHandler:{(data, response, error) in
																	if(error != nil){
																		if let res = response{
																			print("Response:\n",res)
																		}
																	}
																	else{
																		let jsonDictionary = self.convertDataToDictionary(with: data)
																		
																		print(jsonDictionary["feature"]!)
																		print(jsonDictionary["label"]!)
																	}
																	
		})
	
		postTask.resume() // start the task
	}

	func getPrediction(_ array:[Double]){
		let baseURL = "\(SERVER_URL)/PredictOne"
		let postUrl = URL(string: "\(baseURL)")
		
		// create a custom HTTP POST request
		var request = URLRequest(url: postUrl!)
		
		// data to send in body of post request (send arguments as json)
		let jsonUpload:NSDictionary = ["feature":array, "dsid":self.dsid]
		
		
		let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
		
		request.httpMethod = "POST"
		request.httpBody = requestBody
		
		let postTask : URLSessionDataTask = self.session.dataTask(with: request)
		{ data, response, error in
			if error = error){
				if let res = response{
					print("Response:\n",res)
				}
			}
			else{
				let jsonDictionary = self.convertDataToDictionary(with: data)
				
				let labelResponse = jsonDictionary["prediction"]!
				print(labelResponse)
				self.displayLabelResponse(labelResponse as! String)
				
			}
																	
		}
		
		postTask.resume() // start the task
	}



	@IBAction func makeModel(_ sender: AnyObject) {
		
		// create a GET request for server to update the ML model with current data
		let baseURL = "\(SERVER_URL)/UpdateModel"
		let query = "?dsid=\(self.dsid)"
		
		let getUrl = URL(string: baseURL+query)
		let request: URLRequest = URLRequest(url: getUrl!)
		let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
																  completionHandler:{(data, response, error) in
																	// handle error!
																	if (error != nil) {
																		if let res = response{
																			print("Response:\n",res)
																		}
																	}
																	else{
																		let jsonDictionary = self.convertDataToDictionary(with: data)
																		
																		if let resubAcc = jsonDictionary["resubAccuracy"]{
																			print("Resubstitution Accuracy is", resubAcc)
																		}
																	}
																	
		})
		
		dataTask.resume() // start the task
		
	}

	//MARK: JSON Conversion Functions
	func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
		do { // try to make JSON and deal with errors using do/catch block
			let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
			return requestBody
		} catch {
			print("json error: \(error.localizedDescription)")
			return nil
		}
	}

	func convertDataToDictionary(with data:Data?)->NSDictionary{
		do { // try to parse JSON and deal with errors using do/catch block
			let jsonDictionary: NSDictionary =
				try JSONSerialization.jsonObject(with: data!,
												 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
			
			return jsonDictionary
			
		} catch {
			print("json error: \(error.localizedDescription)")
			return NSDictionary() // just return empty
		}
	}
}
