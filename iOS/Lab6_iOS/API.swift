//
//  API.swift
//  Lab6_iOS
//
//  Created by Justin Wilson on 11/8/17.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//

import UIKit
import CoreML

// Implicitly Assigned Raw Values
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-ID535
enum NumberLabel: Int {
	case zero = 0, one, two, three, four, five, six, seven, eight, nine
}

// This version of our API performs classification locally with CoreML
class API {
	
	static let shared = API()
	lazy var model = DigitRecognizer()
	
	private init() {}
	
	// given an arbitrary image, resize to 28x28, grayscale PNG data
	private func prepare(image: UIImage) -> MLMultiArray? {
		var newImage = ImageTools.resize(image: image, to: (28,28))
		newImage = ImageTools.convertAlpha(image: newImage!, toMatte: .white)

		return ImageTools.convertToGrayscale(image: newImage!)
		//let data: NSData? = newImage?.cgImage?.dataProvider?.data
	}

	func classify(
		image: UIImage,
		callback: @escaping (NumberLabel?,Error?) -> ()
	) {
		print("classify(image: ...))")

		guard let imageArray = prepare(image: image) else {
			print("Could not prepare image.")
			callback(nil, nil)
			return
		}
		
		//print(imageArray)
		let imageInput: DigitRecognizerInput = DigitRecognizerInput(input: imageArray)
		
		do {
			let output = try model.prediction(input: imageInput)
			print(output.classLabel)
			let label = NumberLabel(rawValue: Int(output.classLabel))
			callback(label, nil)
		} catch {
			print("model.prediction error: \(error)")
			callback(nil, error)
			return
		}
	}
	
}
