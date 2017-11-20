//
//  ImageTools.swift
//  Lab6_iOS
//
//  Created by Paul Herz on 2017-11-08.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//
//  Modified to support MLMultiarray conversion
// Justin Wilson, Pual Herz, Jake Rowland

import UIKit
import AVFoundation
import CoreML

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
		
		return resize(image: image, to: (width,height))
	}
	
	static func resize(image: UIImage, to size: (width: Int, height: Int)) -> UIImage? {
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
	
	static func convertAlpha(image: UIImage, toMatte matte: UIColor) -> UIImage? {
		guard let cg = image.cgImage else {
			print("[ImageTools.scale(image:toExactly:)] failed to get CGImage.")
			return nil
		}
		
		guard let ctx = CGContext(
			data: nil,
			width: cg.width,
			height: cg.height,
			bitsPerComponent: cg.bitsPerComponent,
			bytesPerRow: cg.bytesPerRow,
			space: cg.colorSpace!,
			bitmapInfo: cg.bitmapInfo.rawValue
		) else {
			print("[ImageTools.scale(image:toExactly:)] could not initialize CGContext.")
			return nil
		}
		
		ctx.interpolationQuality = .high
		let size = CGSize(width: cg.width, height: cg.height)
		let sizeRect = CGRect(origin: .zero, size: size)
		
		ctx.setFillColor(matte.cgColor)
		ctx.fill(sizeRect)
		ctx.draw(cg, in: sizeRect)
		
		return ctx.makeImage().flatMap { UIImage(cgImage: $0) }
	}
	
	static func convertToGrayscale(image: UIImage) -> UIImage? {
		guard let cg = image.cgImage else {
			print("[ImageTools.convertToGrayscale(image:)] failed to get CGImage.")
			return nil
		}
		
		let rect = CGRect(origin: .zero, size: CGSize(width: cg.width, height: cg.height))
		let grayscale = CGColorSpace(name: CGColorSpace.linearGray)!
		
		guard let ctx = CGContext(
			data: nil,
			width: cg.width,
			height: cg.height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: grayscale,
			bitmapInfo: CGImageAlphaInfo.none.rawValue
		) else {
			print("[ImageTools.scale(image:toExactly:)] could not initialize CGContext.")
			return nil
		}
		//set64 bits get data and copy
		ctx.draw(cg, in: rect)
		
		return ctx.makeImage().flatMap { UIImage(cgImage: $0) }
	}
	
	static func convertToGrayscale(image: UIImage) -> MLMultiArray? {
		guard let cg = image.cgImage else {
			print("[ImageTools.convertToGrayscale(image:)] failed to get CGImage.")
			return nil
		}
		
		let rect = CGRect(origin: .zero, size: CGSize(width: cg.width, height: cg.height))
		let grayscale = CGColorSpace(name: CGColorSpace.linearGray)!
		
		guard let ctx = CGContext(
			data: nil,
			width: cg.width,
			height: cg.height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: grayscale,
			bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
				print("[ImageTools.scale(image:toExactly:)] could not initialize CGContext.")
				return nil
			}
		
		
		
		ctx.draw(cg, in: rect)
		
		var imageData = Data.init(bytes: ctx.data!, count: cg.width * cg.height).map { Double($0) }
		imageData = imageData.map{abs($0 - 255.0)}
		print(imageData)
		var imageMultiArray: MLMultiArray? = nil
		
		imageData.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) -> Void in
			do {
				//let rawPointer = pointer.baseAddress
				imageMultiArray = try MLMultiArray(
					dataPointer: pointer.baseAddress!,
					shape: [28, 28],
					dataType: .double,
					strides: [1, 1],
					deallocator: nil //Could lead to a memory hole
				)
			} catch {
				print("Cannot generate MLMultiArray from image. Stopping.")
			}
		}
		
		return imageMultiArray
	}
}
