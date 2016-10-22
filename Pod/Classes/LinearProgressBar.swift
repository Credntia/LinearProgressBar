//
//  LinearProgressBar.swift
//  CookMinute
//
//  Created by Philippe Boisney on 18/11/2015.
//  Copyright © 2015 CookMinute. All rights reserved.
//
//  Google Guidelines: https://www.google.com/design/spec/components/progress-activity.html#progress-activity-types-of-indicators
//

import UIKit

private var screenSize: CGRect {
	return UIScreen.mainScreen().bounds
}

private let bar: LinearProgressBar = LinearProgressBar()
private var sDuration: NSTimeInterval = 0.5
private var dDuration: NSTimeInterval = 0.5

public class LinearProgressBar: UIView {
	
	public class var shared: LinearProgressBar {
		return bar
	}
	
	// MARK: - Private Variables
	
	private var isAnimationRunning = false
	
	private lazy var progressBarIndicator: UIView = {
		let frame = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 0, height: self.progressBarHeight))
		return UIView(frame: frame)
	}()
	
	
	// MARK: Public Variables
	
	/// The height for the progress bar
	public var progressBarHeight: CGFloat
	
	/// Background color for the progress bar
	public var progressBarColor: UIColor = UIColor(red:0.12, green:0.53, blue:0.90, alpha:1.0)
	
	/// Used to determine how much variation the progress bar should animate
	public var widthRatioOffset: CGFloat = 0.7
	
	/// The offset used to determine how far offscreen the progress bar should start and finish animation
	public var xOffset: CGFloat = 0
	
	/// The progress bar animation duration
	public var keyframeDuration: NSTimeInterval = 1.0
	
	/// Default Show Duration
	public var showDuration: TimeInterval {
		get {return sDuration}
		set {sDuration = newValue}
	}
	
	/// Default Dismiss Duration
	public var dismissDuration: TimeInterval {
		get {return dDuration}
		set {dDuration = newValue}
	}
	
	
	// MARK: Deprecated
	
	@available(*, deprecated, message = "Please use backgroundColor instead", renamed = "backgroundColor")
	var backgroundProgressBarColor: UIColor = UIColor.whiteColor()
	
	@available(*, deprecated, message = "Please use progressBarHeight instead", renamed = "progressBarHeight")
	var heightForLinearBar: CGFloat = 5
	
	@available(*, deprecated, message = "Please adjust frame.size.width instead")
	var widthForLinearBar: CGFloat = 0
	
	
	// MARK: Inits
	
	public convenience init() {
		self.init(height: 5)
	}
	
	public convenience init(height: CGFloat) {
		self.init(frame: CGRect(origin: CGPoint(x: 0,y :20), size: CGSize(width: screenSize.width, height: height)))
	}
	
	override public init(frame: CGRect) {
		progressBarHeight = frame.height
		var frame = frame
		frame.size.height = 0
		super.init(frame: frame)
		self.clipsToBounds = true
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - Public Functions
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		
		var rect = self.frame
		
		if rect.width == 0 || rect.width == screenSize.height {
			rect.size.width = screenSize.width
		}
		
		self.frame = rect
	}
	
	/**
	Shows the view, if not currently shown, then starts the animation
	
	- parameters:
	- duration: The animation duration for showing the view. Defaults to `0.5`
	- delay: The delay for showing the view. Defaults to `0.0`
	*/
	public func show(duration duration: NSTimeInterval = sDuration, delay: NSTimeInterval = 0) {
		
		self.display()
		
		guard !isAnimationRunning else {return}
		self.isAnimationRunning = true
		
		var rect = self.frame
		rect.size.height = self.progressBarHeight
		
		UIView.animateWithDuration(duration, delay: delay, options: [], animations: {
			self.frame = rect
		}) { animationFinished in
			self.addSubview(self.progressBarIndicator)
			self.configureAnimations()
		}
	}
	
	/**
	Shows the view, if not currently shown, then displays a specific progress value. This is useful for displaying progress of a task.
	
	- parameters:
	- progress: The progress of the task. Should be a value between `0.0` & `1.0`
	- duration: The animation duration for showing the view. Defaults to `0.5`
	*/
	public func showProgress(progress: CGFloat, duration: NSTimeInterval = sDuration) {
		
		self.display()
		
		self.isAnimationRunning = false
		
		var rect = self.frame
		rect.size.height = self.progressBarHeight
		
		var progressRect = self.progressBarIndicator.frame
		progressRect.origin = CGPoint.zero
		self.progressBarIndicator.frame = progressRect
		
		progressRect.size.width = self.frame.width * progress
		
		UIView.animateWithDuration(duration, delay: 0, options: [], animations: {
			self.frame = rect
		}) { animationFinished in
			self.addSubview(self.progressBarIndicator)
			UIView.animateWithDuration(duration) {
				self.progressBarIndicator.frame = progressRect
			}
		}
	}
	
	/**
	Dismisses the view, if currently shown.
	
	- parameters:
	- duration: The animation duration for dismissing the view. Defaults to `0.5`
	*/
	public func dismiss(duration duration: NSTimeInterval = dDuration) {
		
		self.isAnimationRunning = false
		
		var rect = self.frame
		rect.size.height = 0
		
		UIView.animateWithDuration(duration, animations: {
			self.frame = rect
		}) { (finished: Bool) in
			self.progressBarIndicator.removeFromSuperview()
			if self == bar {
				self.removeFromSuperview()
			}
		}
	}
	
	
	//MARK: Private Functions
	
	private func display() {
		self.progressBarIndicator.backgroundColor = self.progressBarColor
		self.layoutIfNeeded()
		
		guard let view = UIApplication.sharedApplication().keyWindow?.visibleViewController?.view where (self.superview == nil || self == bar) else {return}
		view.addSubview(self)
	}
	
	private func configureAnimations() {
		
		guard let _ = self.superview else {
			dismiss()
			return
		}
		
		guard self.isAnimationRunning else {return}
		
		self.progressBarIndicator.frame = CGRect(origin: CGPoint(x: 0, y :0), size: CGSize(width: 0, height: progressBarHeight))
		
		UIView.animateKeyframesWithDuration(keyframeDuration, delay: 0, options: [], animations: {
			
			UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: self.keyframeDuration/2) {
				self.progressBarIndicator.frame = CGRect(x: -self.xOffset, y: 0, width: self.frame.width * self.widthRatioOffset, height: self.progressBarHeight)
			}
			
			UIView.addKeyframeWithRelativeStartTime(self.keyframeDuration/2, relativeDuration: self.keyframeDuration/2) {
				self.progressBarIndicator.frame = CGRect(x: self.frame.width, y: 0, width: self.xOffset, height: self.progressBarHeight)
			}
			
		}) { (completed) in
			guard self.isAnimationRunning else {return}
			self.configureAnimations()
		}
	}
	
	
	// MARK: Deprecated
	
	@available(*, deprecated, message = "Please use show() instead", renamed = "show")
	func startAnimation() {
		self.show()
	}
	
	@available(*, deprecated, message = "Please use dismiss() instead", renamed = "dismiss")
	func stopAnimation() {
		self.dismiss()
	}
}


// MARK: -

private extension UIWindow {
	
	/**
	Returns the currently visible view controller
	
	- returns: The visible view controller
	*/
	var visibleViewController: UIViewController? {
		return getVisibleViewController(forRootController: rootViewController)
	}
	
	/**
	Returns the visible view controller
	
	- parameters:
	- currentRootViewController: Current Root View Controller
	- returns: The visible view controller
	*/
	func getVisibleViewController(forRootController currentRootViewController: UIViewController?) -> UIViewController? {
		
		guard let controller = currentRootViewController else {return nil}
		
		switch controller {
			
		case let navVC as UINavigationController:
			return getVisibleViewController(forRootController: navVC.viewControllers.last)
			
		case let tabVC as UITabBarController:
			return getVisibleViewController(forRootController: tabVC.selectedViewController)
			
		case let controller where controller.presentedViewController != nil:
			return getVisibleViewController(forRootController: controller.presentedViewController)
			
		default:
			return controller
		}
	}
}
