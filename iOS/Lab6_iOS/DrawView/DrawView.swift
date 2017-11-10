//
//  DrawView.swift
//  Lab6_iOS
//
//  Created by Paul Herz on 2017-11-08.
//  Copyright © 2017 Justin Wilson. All rights reserved.
//

import UIKit
import TouchDraw

protocol DrawViewDelegate {
	func didPressSendButton(_ drawView: DrawView)
	func didPressEraseButton(_ drawView: DrawView)
}

enum DrawViewStyle {
	case normal, inverted
}

class DrawView: UIView {
	
	var delegate: DrawViewDelegate? = nil
	
	var labelText: String? {
		get {
			return drawLabel.text
		}
		set {
			DispatchQueue.main.async {
				self.drawLabel.text = newValue
			}
		}
	}
	
	var style: DrawViewStyle = .normal {
		didSet {
			setStyle(style)
		}
	}
	
	var currentImage: UIImage {
		get {
			return touchDrawView.exportDrawing()
		}
	}
	
	@IBOutlet private var contentView: UIView!
	
	@IBOutlet private weak var touchDrawView: TouchDrawView!
	@IBOutlet private weak var drawLabel: UILabel!
	@IBOutlet private weak var clearButton: UIButton!
	@IBOutlet private weak var sendButton: UIButton!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		loadContentView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		loadContentView()
	}
	
	private func loadContentView() {
		Bundle.main.loadNibNamed("DrawView", owner: self, options: nil)
		addSubview(contentView)
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.constrainEdgesToSuperview()
		
		setStyle(.normal)
		labelText = nil
	}
	
	private func setStyle(_ style: DrawViewStyle) {
		switch style {
		case .normal:
			drawLabel.textColor = .black
			touchDrawView.backgroundColor = UIColor(white: 0.9451, alpha: 1.0)
		case .inverted:
			drawLabel.textColor = .white
			touchDrawView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
		}
	}
	
	func erase() {
		touchDrawView.clearDrawing()
	}
	
	@IBAction private func didPressClearButton(_ sender: Any) {
		erase()
		delegate?.didPressEraseButton(self)
	}
	
	@IBAction private func didPressSendButton(_ sender: Any) {
		delegate?.didPressSendButton(self)
	}
}
