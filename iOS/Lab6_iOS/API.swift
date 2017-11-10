//
//  API.swift
//  Lab6_iOS
//
//  Created by Justin Wilson on 11/8/17.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//

import UIKit

// https://gist.github.com/phrz/823afe778556113cbe79c6e8c87ce554
fileprivate func random(in r: ClosedRange<Int>) -> Int {
	let span = abs(r.upperBound-r.lowerBound)
	return Int(arc4random_uniform(UInt32(span)))+r.lowerBound
}

// Implicitly Assigned Raw Values
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-ID535
enum NumberLabel: Int {
	case zero = 0, one, two, three, four, five, six, seven, eight, nine
	
	static func random() -> NumberLabel {
		return NumberLabel(rawValue: Lab6_iOS.random(in: 0...9))!
	}
}

public enum APIClassifier: String {
	case kNearestNeighbors = "KNN"
	case supportVectorMachine = "SVM"
}

class API: NSObject, URLSessionDelegate {
	
	static let shared = API()
	
	// static let API.serverURL = "http://129.119.235.12:8000" // local development
	static let serverURL = "http://104.236.107.228:8000" // DigitalOcean
	
	typealias JSONDictionary = [String: Any]
	
	private var session: URLSession!
	private let sessionQueue = OperationQueue()
	
	private override init() {
		super.init()
		
		let config: URLSessionConfiguration = {
			let c = URLSessionConfiguration.ephemeral
			c.timeoutIntervalForRequest = 5.0
			c.timeoutIntervalForResource = 8.0
			c.httpMaximumConnectionsPerHost = 1
			return c
		}()
		
		self.session = URLSession(
			configuration: config,
			delegate: self,
			delegateQueue: self.sessionQueue
		)
	}
	
	// given an arbitrary image, resize to 28x28, grayscale PNG data
	private func prepare(image: UIImage) -> Data? {
		var newImage = ImageTools.resize(image: image, to: (28,28))
		newImage = ImageTools.convertAlpha(image: newImage!, toMatte: .white)
		newImage = ImageTools.convertToGrayscale(image: newImage!)
		
		return UIImagePNGRepresentation(newImage!)
	}

	func send(image: UIImage, withLabel label: NumberLabel) {
		
		print("send(image: ..., withLabel: \(label.rawValue))")
		
		// Resize, matte, and grayscale the image
		// then convert to PNG data
		guard let imageData = prepare(image: image) else {
			print("Could not prepare image.")
			return
		}
		let base64 = imageData.base64EncodedString()
		
		let url = URL(string: "\(API.serverURL)/AddDataPoint")
		var request = URLRequest(url: url!)
	
		// data to send in body of post request (send arguments as json)
		let submission: JSONDictionary = [
			"image": base64,
			"label": "\(label)"
		]
		
		guard let body = jsonEncode(dictionary: submission) else {
			print("[API.send(features:withLabel:)] Could not encode data.")
			return
		}
	
		request.httpMethod = "POST"
		request.httpBody = body
	
		let task = self.session.dataTask(with: request)
		{ data, response, error in
			guard error == nil else { print(error!); return }
			guard let data = data else { print("No data"); return }
			
			guard let dictionary = self.jsonDecode(data: data) else {
				print("[API.send(features:withLabel:)] Could not decode server response:")
				print(String(data: data, encoding: .utf8) ?? "(nil)")
				return
			}
			
			print(dictionary["feature"]!)
			print(dictionary["label"]!)
		}
	
		task.resume()
	}

	func classify(image: UIImage, usingClassifier classifier: APIClassifier) -> NumberLabel? {
		
		print("classify(image: ..., usingClassifier: \(classifier.rawValue))")
		
		let url = URL(string: "\(API.serverURL)/PredictOne")
		var request = URLRequest(url: url!)
		
		// Resize, matte, and grayscale the image
		// then convert to PNG data
		guard let imageData = prepare(image: image) else {
			print("Could not prepare image.")
			return nil
		}
		let base64 = imageData.base64EncodedString()
		
		// data to send in body of post request (send arguments as json)
		let submission: JSONDictionary = [
			"image": base64,
			"classifier": classifier.rawValue
		]
		
		guard let body = jsonEncode(dictionary: submission) else {
			print("[API.getPrediction(_:)] Could not encode data.")
			return nil
		}
		
		request.httpMethod = "POST"
		request.httpBody = body
		
		let task = self.session.dataTask(with: request)
		{ data, response, error in
			guard error == nil else { print(error!); return }
			guard let data = data else { print("No data"); return }
			
			guard let dictionary = self.jsonDecode(data: data) else {
				print("[API.getPrediction(_:)] Could not decode server response:")
				print(String(data: data, encoding: .utf8) ?? "(nil)")
				return
			}
			
			let labelResponse = dictionary["prediction"]!
			print(labelResponse)
		}
		
		task.resume()
		
		print("Warning: classify(features:) is a stub and always returns nil")
		return nil
	}



	func retrain() {
		
		let url = URL(string: "\(API.serverURL)/UpdateModel")
		let request: URLRequest = URLRequest(url: url!)
		
		let task = self.session.dataTask(with: request)
		{ data, response, error in
			guard error == nil else { print(error!); return }
			guard let data = data else { print("No data"); return }
			
			guard let dictionary = self.jsonDecode(data: data) else {
				print("[API.makeModel(_:)] Could not decode server response:")
				print(String(data: data, encoding: .utf8) ?? "(nil)")
				return
			}
			
			if let resubAcc = dictionary["resubAccuracy"] {
				print("Resubstitution Accuracy is", resubAcc)
			}
		}
		
		task.resume()
	}
	
	func jsonEncode(dictionary: JSONDictionary) -> Data? {
		do {
			let data = try JSONSerialization.data(
				withJSONObject: dictionary,
				options: .prettyPrinted
			)
			return data
		} catch {
			print("json error: \(error.localizedDescription)")
			return nil
		}
	}

	func jsonDecode(data: Data) -> JSONDictionary? {
		do {
			let dictionary: [String: Any]? = try JSONSerialization.jsonObject(
				with: data,
				options: .mutableContainers
			) as? JSONDictionary
			return dictionary
		} catch {
			print("json error: \(error.localizedDescription)")
			return nil
		}
	}
}
