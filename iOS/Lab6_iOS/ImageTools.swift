//
//  ImageTools.swift
//  Lab6_iOS
//
//  Created by Paul Herz on 2017-11-08.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//

import UIKit
import AVFoundation

// [CITE] http://nshipster.com/image-resizing/
class ImageTools {
	static func scale(image: UIImage, toFitInside container: CGSize) -> UIImage? {
		let aspect = AVMakeRect(
			aspectRatio: image.size,
			insideRect: CGRect(origin: .zero, size: container)
		)
		let ratio = aspect.standardized.size.width / image.size.width
		return scale(image: image, by: ratio)
	}
	
	static func scale(image: UIImage, by scaleFactor: CGFloat) -> UIImage? {
		let xyFactor = CGSize(width: scaleFactor, height: scaleFactor)
		return scale(image: image, by: xyFactor)
	}
	
	static func scale(image: UIImage, by scaleFactor: CGSize) -> UIImage? {
		guard let cg = image.cgImage else {
			print("[ImageTools.scale(image:by:)] failed to get CGImage.")
			return nil
		}
		
		let width = Int(CGFloat(cg.width) * scaleFactor.width)
		let height = Int(CGFloat(cg.height) * scaleFactor.height)
		
		return scale(image: image, toExactly: (width,height))
	}
	
	static func scale(image: UIImage, toExactly size: (width: Int, height: Int)) -> UIImage? {
		guard let cg = image.cgImage else {
			print("[ImageTools.scale(image:toExactly:)] failed to get CGImage.")
			return nil
		}
		
		guard let ctx = CGContext(
			data: nil,
			width: Int(size.width),
			height: Int(size.height),
			bitsPerComponent: cg.bitsPerComponent,
			bytesPerRow: cg.bytesPerRow,
			space: cg.colorSpace!,
			bitmapInfo: cg.bitmapInfo.rawValue
		) else {
			print("[ImageTools.scale(image:toExactly:)] could not initialize CGContext.")
			return nil
		}
		
		ctx.interpolationQuality = .high
		let size = CGSize(width: size.width, height: size.height)
		ctx.draw(cg, in: CGRect(origin: .zero, size: size))
		
		return ctx.makeImage().flatMap { UIImage(cgImage: $0) }
	}
}
