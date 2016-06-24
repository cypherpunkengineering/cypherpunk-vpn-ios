//
//  CKNavDrawerController.swift
//  AndroidLikeNavDrawer
//
//  Created by corosuke_k on 2015/01/22.
//  Copyright (c) 2015年 corosuke_k. All rights reserved.
//

import UIKit

public struct CKNavDrawerActionNotification
{
    static let Open = "CKNavDrawerActionNotification.Open"
    static let Close = "CKNavDrawerActionNotification.Close"
    static let StateChange = "CKNavDrawerActionNotification.StateChange"
    
    private static let OpenActionSelector = #selector(CKNavDrawerController.navDrawerOpenFromNotification(_:))
    private static let CloseActionSelector = #selector(CKNavDrawerController.navDrawerCloseFromNotification(_:))
    private static let StateChangeActionSelector = #selector(CKNavDrawerController.toggleNavDrawerActionFromNotification(_:))
}

public struct CKNavDrawerPanMode : OptionSetType
{
    public typealias RawValue = UInt
    private var value: UInt = 0
    
    init(_ value: RawValue) { self.value = value }
    public init(rawValue value: RawValue) { self.value = value }
    public init(nilLiteral: ()) { self.value = 0  }
    
    public static var allZeros: CKNavDrawerPanMode { return self.init(0) }
    static func fromMask(raw: RawValue) -> CKNavDrawerPanMode { return self.init(raw) }
    public var rawValue: RawValue { return self.value }
    
    // In future, PanMode Will be have 3 mode
    static var Default: CKNavDrawerPanMode { return self.init(1 << 0) }
}

public enum CKNavDrawerState
{
    case Closed
    case Open
}

@objc(CKNavDrawerSettings)
public class CKNavDrawerSettings : NSObject
{
    // MARK: IBInspectable Properties
    @IBInspectable public var widthPercentage : CGFloat = 0.75
    @IBInspectable public var animDuration: Float = 0.3
    @IBInspectable public var animDelay: Float = 0.0
    @IBInspectable public var isPannable: Bool = true

    // あとで対応させる
    @IBInspectable private var animationOption = UIViewKeyframeAnimationOptions.CalculationModeCubic
    
    // MARK: Accessable Properties
    public var panMode : CKNavDrawerPanMode{
        get{
            if isPannable {
                return .Default
            }else{
                return []
            }
        }
    }
    
    public var drawerAnimationDuration: NSTimeInterval{
        get{
            return NSTimeInterval(animDuration)
        }
        set(newValue){
            animDuration = Float(newValue)
        }
    }
    
    public var drawerAnimationDelay: NSTimeInterval{
        get{
            return NSTimeInterval(animDelay)
        }
        set(newValue){
            animDelay = Float(newValue)
        }
    }

    public var drawerAnimationOption: UIViewKeyframeAnimationOptions{
        get{
            return animationOption
        }
        set(newValue){
            animationOption = drawerAnimationOption
        }
    }
    
}

public class CKNavDrawerIBSettings: NSObject{
    @IBInspectable public var centerSbname: String? = nil
    @IBInspectable public var centerID: String? = nil
    @IBInspectable public var drawerSbname: String? = nil
    @IBInspectable public var drawerID: String? = nil
}

public class CKNavDrawerController: UIViewController, UIGestureRecognizerDelegate
{
        
    private var navDrawerContainerView = UIView()
    public var navDrawer : UIViewController? = nil{
        didSet{
            if hasFinishedSetup {
                self.setupNavDrawer()
                self.addNavDrawerGestureRecognizer()
            }
        }
    }
    
    private var centerContainerView = UIView()
    public var center : UIViewController? = nil{
        didSet{
            if hasFinishedSetup {
                self.setupCenter()
                self.addCenterGestureRecognizer()
            }
        }
    }
    
    private var centerOverrayView = UIView()
    public var overrayColor: UIColor = UIColor(white: 0, alpha: 0.5){
        didSet{
            if hasFinishedSetup {
                self.setupCenter()
                self.addCenterGestureRecognizer()
            }
        }
    }

    
    public var drawerState : CKNavDrawerState = .Closed{
        didSet{
            if .Closed == drawerState {
                self.navDrawerClose(true)
            }else {
                self.navDrawerOpen(true)
            }
        }
    }

    @IBOutlet public var drawerSettings : CKNavDrawerSettings! = CKNavDrawerSettings(){
        didSet{
            if hasFinishedSetup {
                self.setupNavDrawer()
            }
        }
    }
    
    @IBOutlet public var drawerIBSettings: CKNavDrawerIBSettings? = nil

    private var hasFinishedSetup = false
    private var panGestureOrigin = CGPointZero
    
    var centerEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer! = nil

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector:CKNavDrawerActionNotification.CloseActionSelector, name: CKNavDrawerActionNotification.Close, object: nil)
        defaultCenter.addObserver(self, selector:CKNavDrawerActionNotification.OpenActionSelector, name: CKNavDrawerActionNotification.Open, object: nil)
        defaultCenter.addObserver(self, selector:CKNavDrawerActionNotification.StateChangeActionSelector, name: CKNavDrawerActionNotification.StateChange, object: nil)

        self.setupFromStoryboardSettings()

    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasFinishedSetup == false {
            self.setupCenter()
            self.setupNavDrawer()
            self.setupOverray()
            self.setupGestureRecognizer()

            self.view.addSubview(centerContainerView)
            self.view.addSubview(centerOverrayView)
            self.view.addSubview(navDrawerContainerView)

            self.centerOverrayView.alpha = 0.0
            
            hasFinishedSetup = true
        }
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK: - Public Actions
public extension CKNavDrawerController
{
    
    public func toggleNavDrawerAction(){
        if .Closed != drawerState {
            drawerState = .Closed
        }else{
            drawerState = .Open
        }
    }
}

// MARK: - Private Actions

private extension CKNavDrawerController
{
    
    private func navDrawerOpen(animated : Bool) {
        
        self.centerOverrayView.hidden = false

        let animation = { () -> Void in
            let frame = self.navDrawerContainerView.frame
            let newFrame = CGRect(origin: CGPoint(x: 0,y: 0), size: frame.size)
            self.navDrawerContainerView.frame = newFrame
            self.centerOverrayView.alpha = 1.0
        }
        
        if animated {
            UIView.animateKeyframesWithDuration(self.drawerSettings.drawerAnimationDuration,
                delay: self.drawerSettings.drawerAnimationDelay,
                options: self.drawerSettings.drawerAnimationOption,
                animations: animation,
                completion: nil)
        }else{
            animation()
        }
    }
    
    private func navDrawerClose(animated : Bool) {
        
        let animation = { () -> Void in
            let frame = self.navDrawerContainerView.frame
            let newFrame = CGRect(origin: CGPoint(x: -frame.width,y: 0), size: frame.size)
            self.navDrawerContainerView.frame = newFrame
            self.centerOverrayView.alpha = 0.0
        }
        
        let completion =  { (finished: Bool) -> Void in
            if finished {
                self.centerOverrayView.hidden = true
            }
        }
        
        if animated {
            UIView.animateKeyframesWithDuration(self.drawerSettings.drawerAnimationDuration,
                delay: self.drawerSettings.drawerAnimationDelay,
                options: self.drawerSettings.drawerAnimationOption,
                animations: animation,
                completion: completion)
        }else{
            animation()
            completion(true)
        }
    }

}

// MARK: - Internal Notification Actions
internal extension CKNavDrawerController
{
    internal func toggleNavDrawerActionFromNotification(notification: NSNotification)
    {
        self.toggleNavDrawerAction()
    }
    
    internal func navDrawerOpenFromNotification(notification : NSNotification) {
        if self.drawerState == .Closed {
            self.drawerState = .Open
        }
    }

    internal func navDrawerCloseFromNotification(notification : NSNotification) {
        if self.drawerState == .Open {
            self.drawerState = .Closed
        }
    }
}

// MARK: - Private Setup Methods
private extension CKNavDrawerController
{
    
    private func setupFromStoryboardSettings()
    {
        if let IBSettings = self.drawerIBSettings {
            if let centerID = IBSettings.centerID {
                if let centerSbName = IBSettings.centerSbname {
                    let storyboard = UIStoryboard(name: centerSbName, bundle: nil)
                    self.center = storyboard.instantiateViewControllerWithIdentifier(centerID)
                }else{
                    self.center = self.storyboard?.instantiateViewControllerWithIdentifier(centerID)
                }
            }
            
            if let drawerId = IBSettings.drawerID {
                if let drawerSbName = IBSettings.drawerSbname {
                    let storyboard = UIStoryboard(name: drawerSbName, bundle: nil)
                    self.navDrawer = storyboard.instantiateViewControllerWithIdentifier(drawerId)
                }else{
                    self.navDrawer = self.storyboard?.instantiateViewControllerWithIdentifier(drawerId)
                }
            }
        }
    }
    
    private func setupNavDrawer()
    {
        let width = self.view.frame.size.width * self.drawerSettings.widthPercentage
        let point = CGPointMake(-width, 0)
        let size = CGSizeMake(width, self.view.frame.height)

        navDrawerContainerView.frame = CGRect(origin: point, size:size)
        navDrawer?.view.frame = navDrawerContainerView.bounds
        
        navDrawerContainerView.subviews.last?.removeFromSuperview()
        navDrawer?.willMoveToParentViewController(nil)
        navDrawer?.removeFromParentViewController()
        
        if let vc = navDrawer {
            navDrawerContainerView.addSubview(vc.view)
            self.addChildViewController(vc)
        }
        
    }
    
    private func setupCenter()
    {
        centerContainerView.frame = self.view.frame
        center?.view.frame = centerContainerView.bounds
        
        centerContainerView.subviews.last?.removeFromSuperview()
        center?.willMoveToParentViewController(nil)
        center?.removeFromParentViewController()

        if let vc = center {
            centerContainerView.addSubview(vc.view)
            self.addChildViewController(vc)
        }
        
    }
    
    private func setupOverray()
    {
        centerOverrayView.frame = centerContainerView.frame
        centerOverrayView.backgroundColor = self.overrayColor
    }
    
    private func setupGestureRecognizer()
    {
        self.addCenterGestureRecognizer()
        self.addNavDrawerGestureRecognizer()
        self.addOverrayGestureRecognizer()
    }
    
}

// MARK: - Private Setup Gesture Recognizer Methods
private extension CKNavDrawerController
{
    private func addCenterGestureRecognizer()
    {
        if (self.center != nil) {
            centerEdgePanGestureRecognizer = self.edgePanGestureRecognizer()
            self.center?.view.addGestureRecognizer(self.edgePanGestureRecognizer())
            self.centerContainerView.addGestureRecognizer(centerEdgePanGestureRecognizer)
        }
    }
    
    private func addNavDrawerGestureRecognizer()
    {
        if (self.navDrawer != nil) {
            self.navDrawerContainerView.addGestureRecognizer(self.panGestureRecognizer())
        }
    }
    
    private func addOverrayGestureRecognizer()
    {
        self.centerOverrayView.addGestureRecognizer(self.centerTapGestureRecognizer())
    }
    
    private func edgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer
    {
        let edgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(CKNavDrawerController.panGestureAction(_:)))

        edgeRecognizer.edges = UIRectEdge.Left
        edgeRecognizer.delegate = self
        edgeRecognizer.maximumNumberOfTouches = 1
        return edgeRecognizer
    }
    
    private func panGestureRecognizer() -> UIPanGestureRecognizer
    {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CKNavDrawerController.panGestureAction(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        return panGestureRecognizer
    }
    
    private func centerTapGestureRecognizer() -> UITapGestureRecognizer
    {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CKNavDrawerController.centerTapAction(_:)))
        tapGestureRecognizer.delegate = self
        return tapGestureRecognizer
    }
    
    @objc @IBAction func panGestureAction(recognizer: UIPanGestureRecognizer){
        
        if self.navDrawer == nil { return }
        
        let translated = recognizer.translationInView(recognizer.view!)

        switch (recognizer.state){
        case .Began:
            self.panGestureOrigin = self.navDrawerContainerView.frame.origin
            
            if self.drawerState == .Closed {
                self.centerOverrayView.hidden = false
             }
            
        case .Ended, .Cancelled:
            let velocity = recognizer.velocityInView(recognizer.view!)
            let viewWidth = view.frame.size.width

            if self.drawerState == CKNavDrawerState.Closed {
                let finalX = translated.x + (0.35 * velocity.x);
                
                let showDrawer = (finalX > viewWidth / 2) || (finalX > self.navDrawerContainerView.frame.size.width / 2)
                if showDrawer {
                    self.drawerState = .Open
                } else {
                    self.navDrawerClose(true)
                }
            }else {
                let finalX = translated.x + (0.35 * velocity.x);

                let hideDrawer = (finalX < -viewWidth / 2) || (finalX < -self.navDrawerContainerView.frame.size.width / 2)
                if hideDrawer {
                    self.drawerState = .Closed
                } else {
                    self.navDrawerOpen(true)
                }
            }
            
        default:
            let width = self.navDrawerContainerView.frame.size.width
            let newX = max(min(self.panGestureOrigin.x + translated.x, 0),-width)
            
            let newPoint = CGPointMake(newX, self.panGestureOrigin.y)
            self.navDrawerContainerView.frame = CGRect(origin: newPoint, size: self.navDrawerContainerView.frame.size)
            
            centerOverrayView.alpha = (width + newX) / width

            return
        }
    }
    
    @objc @IBAction func centerTapAction(recognizer: UITapGestureRecognizer){
        if .Open == self.drawerState {
            self.drawerState = .Closed
        }
    }
}
