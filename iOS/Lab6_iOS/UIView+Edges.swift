//
//  UIView+Edges.swift
//  Lab6_iOS
//
//  Created by Paul Herz on 2017-11-02.
//  Copyright © 2017 Centigrade. All rights reserved.
//

import UIKit

extension UIView {
	func constrainEdges(to other: UIView, inset: CGFloat = 0.0) {
		self.topAnchor.constraint(equalTo: other.topAnchor, constant: inset).isActive = true
		self.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -1.0*inset).isActive = true
		self.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -1.0*inset).isActive = true
		self.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: inset).isActive = true
	}
	
	func constrainEdgesToSuperview(inset: CGFloat = 0.0) {
		constrainEdges(to: self.superview!, inset: inset)
	}
}

