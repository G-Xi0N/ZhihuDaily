//
//  FKNavigationBar.swift
//  UIViewController+NavigationBar
//
//  Created by GorXion on 2018/3/28.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit

open class FKNavigationBar: UINavigationBar {

    private var _alpha: CGFloat = 1
    
    /// Default is false. If set true, navigation bar will not restore when the UINavigationController call viewWillLayoutSubviews
    open var isUnrestoredWhenViewWillLayoutSubviews = false
    
    open override var alpha: CGFloat {
        get {
            return super.alpha
        }
        set {
            _alpha = newValue
            if let background = subviews.first {
                background.alpha = newValue
            }
        }
    }
    
    open override var barTintColor: UIColor? {
        didSet {
            if let visualEffectView = subviews.first?.subviews.last as? UIVisualEffectView {
                visualEffectView.contentView.backgroundColor = barTintColor
            }
        }
    }
    
    /// map to barTintColor
    open override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            barTintColor = newValue
        }
    }
    
    public convenience init(navigationItem: UINavigationItem) {
        self.init()
        setItems([navigationItem], animated: false)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let background = subviews.first else { return }
        background.alpha = _alpha
        background.frame = CGRect(x: 0,
                                  y: -UIApplication.shared.statusBarFrame.maxY,
                                  width: bounds.width,
                                  height: bounds.height + UIApplication.shared.statusBarFrame.maxY)
        if let visualEffectView = background.subviews.last as? UIVisualEffectView {
            visualEffectView.contentView.backgroundColor = barTintColor
        }
    }
}
