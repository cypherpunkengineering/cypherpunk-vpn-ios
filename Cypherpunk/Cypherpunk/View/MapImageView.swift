//
//  MapImageView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/5/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import QuartzCore
import RealmSwift
import simd

class MapImageView: UIView {
    static let mapPanDuration = 1.75 // duration of the map animation when it pans/zooms
    var parentMidYOffset: CGFloat = 110 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var parentMidXOffset: CGFloat = UIScreen.main.bounds.width / 4

    var isMapInBackground = false {
        didSet {
            if isMapInBackground {
                self.markerLayer.foregroundColor = UIColor(hex: "#448888")?.cgColor
                shiftMapToRight()
            }
            else {
                self.markerLayer.foregroundColor = UIColor(red: 136.0 / 255.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
//                shiftMapToLeft()
            }
        }
    }
    
    private let locationColor = UIColor.init(hex: "#01adad")!.cgColor
    private let locationBorderColor = UIColor(red: 0, green: 118 / 255.0, blue: 118 / 255.0, alpha: 1.0).cgColor
    private let locationColorDark = UIColor(red: 0, green: 83 / 255.0, blue: 83 / 255.0, alpha: 1.0).cgColor
    private let locationBorderColorDark = UIColor.init(hex: "#004444")!.cgColor
    private let markerLayer = CATextLayer()
    private let mapLayer = CALayer()
    private let markerHeightOffset: CGFloat = 17.0
    private let markerWidthOffset: CGFloat = 5.0
    private var scaleTransform: CATransform3D? = nil
    private var mapScale: CGFloat = 1.0
    private var lastPosition: CGPoint? = nil
    
    // used for zooming out when cyhperplay is selected
    private let centerLat = 42.9719
    private let centerLong = 12.5674
    private let centerDisplayScale: CGFloat = 0.35
    
    // variables used when zooming to locations
    private static let markerAnimationDuration = 2.0
    private static let markerPanStartRelativeTiming: NSNumber = 0.2 // time in which marker finish going up and is ready to pan
    private static let markerPanEndRelativeTiming: NSNumber = 0.8 // time in which marker is done panning and is ready to go down
    private static let mapMoveDelay = markerAnimationDuration * markerPanStartRelativeTiming.doubleValue // map should only start moving after marker has gone up
    private let mapMoveDuration = markerAnimationDuration * markerPanEndRelativeTiming.doubleValue - mapMoveDelay // time the map is animating
    private let mapPinJumpHeight: CGFloat = 20.0
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMap()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMap()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        // recompute this incase the rotation changed
        parentMidXOffset = UIScreen.main.bounds.width / 4
        
        if layer == self.layer {
            // set frame for all map sublayers
            self.mapLayer.frame = self.bounds
            
            let sublayers = self.mapLayer.sublayers
            sublayers?.forEach({ (sublayer) in
                sublayer.frame = self.bounds
            })
            
            if let superView = self.superview {
                let superViewFrame = superView.frame
                let xCoord = isMapInBackground ? superViewFrame.midX + parentMidXOffset : superViewFrame.midX
                self.markerLayer.position = CGPoint(x: xCoord, y: superViewFrame.midY + parentMidYOffset - markerHeightOffset)
                
                if UI_USER_INTERFACE_IDIOM() == .pad {
                    zoomToLastSelected() // TODO figure out how to detect rotation and do this
                }
            }
        }
    }
    
    private func createTransparentMapImage() -> UIImage? {
        var transparentImage: UIImage?
        let originalImage = R.image.worldmap_2000()
        if let image = originalImage {
            transparentImage = image.image(alpha: 0.3)
        }
        return transparentImage
    }
    
    private func setupMap() {
        if UI_USER_INTERFACE_IDIOM() == .phone && UIScreen.main.bounds.height < 520 {
            parentMidYOffset = 115
        }
        
        let mapImage = createTransparentMapImage()
        self.mapLayer.contents = mapImage?.cgImage
        self.mapLayer.contentsScale = UIScreen.main.scale
        self.mapLayer.frame = CGRect(x: 0, y: 0, width: (mapImage?.size.width)!, height: (mapImage?.size.height)!)
        self.mapLayer.contentsGravity = kCAGravityBottomLeft
        self.layer.addSublayer(self.mapLayer)
        
        self.contentMode = .center
        self.layer.needsDisplayOnBoundsChange = true
        
        drawLocationsOnMap()
        

        let font = UIFont.fontAwesome(ofSize: 40)
        let markerString = String.fontAwesomeIcon(name: .mapMarker)
        let markerRect = (markerString as NSString).boundingRect(with: CGSize(), options: NSStringDrawingOptions.truncatesLastVisibleLine, attributes: [NSFontAttributeName: font], context: nil)
        self.markerLayer.font = font
        self.markerLayer.fontSize = 40
        self.markerLayer.string = markerString
        self.markerLayer.alignmentMode = kCAAlignmentCenter
        self.markerLayer.frame = markerRect
        self.markerLayer.foregroundColor = UIColor(red: 136.0 / 255.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        self.markerLayer.opacity = 1.0
        self.markerLayer.contentsScale = UIScreen.main.scale
        self.markerLayer.isHidden = true

        self.layer.addSublayer(self.markerLayer)
    }
    
    func drawLocationsOnMap() {
        let realm = try! Realm()
        let locations = realm.objects(Region.self)
        locations.forEach { (region) in
            drawLocationOnMap(lat: region.latitude, long: region.longitude, regionId: region.id)
        }
    }
    
    func drawLocationOnMap(lat: Double, long: Double, regionId: String) {
        let imageCoordinates = transformToXY(lat: lat, long: long)
        let dotPath = UIBezierPath(ovalIn: CGRect(x: imageCoordinates.x - 3, y: imageCoordinates.y - 3, width: 6, height: 6))

        let layer = CAShapeLayer()
        layer.borderWidth = 6.0
        layer.path = dotPath.cgPath
        layer.setValue(regionId, forKey: "regionId")
        layer.contentsScale = UIScreen.main.scale
        
        setLocationLayerColors(shapeLayer: layer, selected: mainStore.state.regionState.lastSelectedRegionId == regionId)
        
        self.mapLayer.addSublayer(layer)
    }
    
    func zoomToLastSelected() {
        if let lastSelected = mainStore.state.regionState.lastSelectedRegionId {
            // zoom/pan to this region id
            let realm = try! Realm()
            if mainStore.state.regionState.cypherplayOn {
                zoomOut()
            }
            else if let selectedRegion = realm.object(ofType: Region.self, forPrimaryKey: lastSelected) {
                zoomToRegion(region: selectedRegion)
            }
        }
    }
    
    func zoomToRegion(region: Region) {
        if self.markerLayer.isHidden {
            zoomInToLatLong(lat: region.latitude, long: region.longitude, locationDisplayScale: region.locDisplayScale)
        }
        else {
            self.markerLayer.isHidden = false
            self.markerLayer.opacity = 1.0
            self.zoomToLatLong(lat: region.latitude, long: region.longitude, locationDisplayScale: region.locDisplayScale, yCoordOffset: self.parentMidYOffset)
        }
        
        let sublayers = self.mapLayer.sublayers
        sublayers?.forEach({ (sublayer) in
            let shapeLayer = sublayer as! CAShapeLayer
            let regionId = shapeLayer.value(forKey: "regionId") as! String
            setLocationLayerColors(shapeLayer: shapeLayer, selected: regionId == region.id)
        })
    }
    
    func zoomToRegion(regionId: String) {
        let realm = try! Realm()
        if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
            zoomToRegion(region: region)
        }
    }
    
    private func zoomInToLatLong(lat: Double, long: Double, locationDisplayScale: CGFloat) {
        if let superView = self.superview {
            let superviewFrame = superView.frame
            let superViewFrameMidX = isMapInBackground ? superviewFrame.midX + parentMidXOffset : superviewFrame.midX
            let superViewFrameMidY = superviewFrame.midY + self.parentMidYOffset
            
            let scale = translateScaleToiOS(regionScale: locationDisplayScale, superviewFrame: superviewFrame)
            
            let coords = transformToXY(lat: lat, long: long)
            let newMapLayerPosition = CGPoint(x: superViewFrameMidX - CGFloat(coords.x) * scale, y: superViewFrameMidY - CGFloat(coords.y) * scale)
            
            // scale animation
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = self.mapScale
            scaleAnimation.toValue = scale
            scaleAnimation.duration = mapMoveDuration
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = kCAFillModeForwards
            
            // move the map
            let positionAnimation = CABasicAnimation(keyPath: "position")
//            positionAnimation.fromValue = self.mapLayer.position
            positionAnimation.toValue = newMapLayerPosition
            positionAnimation.duration = mapMoveDuration
            positionAnimation.isRemovedOnCompletion = false
            positionAnimation.fillMode = kCAFillModeForwards
            
            if let currentPosition = self.lastPosition {
                positionAnimation.fromValue = currentPosition
            }
            else {
                positionAnimation.fromValue = CGPoint(x: superViewFrameMidX, y: superViewFrameMidY)
            }
            
            // animation the position of the marker
            let appearAnimation = CABasicAnimation(keyPath: "opacity")
            appearAnimation.beginTime = CACurrentMediaTime() + mapMoveDuration
            appearAnimation.fromValue = 0
            appearAnimation.toValue = 1.0
            appearAnimation.fillMode = kCAFillModeBoth
            appearAnimation.duration = 0.5
            
            let startPostion = CGPoint(x: superviewFrame.midX, y: superViewFrameMidY - markerHeightOffset - mapPinJumpHeight)
            let endPosition = CGPoint(x: superviewFrame.midX, y: superViewFrameMidY - markerHeightOffset)
            
            let dropAnimation = CAKeyframeAnimation(keyPath: "position")
            dropAnimation.beginTime = CACurrentMediaTime() + mapMoveDuration
            dropAnimation.duration = 1.0
            dropAnimation.keyTimes = [0.0, 0.3, 1.0]
            dropAnimation.values = [startPostion, startPostion, endPosition]
            
            self.mapScale = scale
            self.lastPosition = newMapLayerPosition
            self.mapLayer.position = newMapLayerPosition
            self.markerLayer.isHidden = false
            self.markerLayer.position = endPosition
            self.markerLayer.opacity = 1.0
            
            self.mapLayer.add(positionAnimation, forKey: "position")
            self.mapLayer.add(scaleAnimation, forKey: "transform.scale")
            
            self.markerLayer.add(appearAnimation, forKey: "opacity")
            self.markerLayer.add(dropAnimation, forKey: "position")
        }
    }
    
    private func zoomToLatLong(lat: Double, long: Double, locationDisplayScale: CGFloat, yCoordOffset: CGFloat) {
        if let superView = self.superview {
            let superviewFrame = superView.frame
            let superViewFrameMidX = isMapInBackground ? superviewFrame.midX + parentMidXOffset : superviewFrame.midX
            let superViewFrameMidY = superviewFrame.midY + yCoordOffset
            
            let scale = translateScaleToiOS(regionScale: locationDisplayScale, superviewFrame: superviewFrame)
            
            let coords = transformToXY(lat: lat, long: long)
            let newMapLayerPosition = CGPoint(x: superViewFrameMidX - CGFloat(coords.x) * scale, y: superViewFrameMidY - CGFloat(coords.y) * scale)
            
            // scale animation
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = self.mapScale
            scaleAnimation.toValue = scale
            scaleAnimation.beginTime = CACurrentMediaTime() + MapImageView.mapMoveDelay
            scaleAnimation.duration = mapMoveDuration
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = kCAFillModeForwards

            // move the map
            let positionAnimation = CABasicAnimation(keyPath: "position")
            
            if let currentPosition = self.lastPosition {
                positionAnimation.fromValue = currentPosition
            }
            else {
                positionAnimation.fromValue = CGPoint(x: superViewFrameMidX, y: superViewFrameMidY)
            }
            positionAnimation.toValue = newMapLayerPosition
            positionAnimation.beginTime = CACurrentMediaTime() + MapImageView.mapMoveDelay
            positionAnimation.duration = mapMoveDuration
            positionAnimation.isRemovedOnCompletion = false
            positionAnimation.fillMode = kCAFillModeForwards
            
            // animation the position of the marker
            let currPostionY = self.markerLayer.position.y
            let currPostionX = self.markerLayer.position.x
            
            let bounceAnimation = CAKeyframeAnimation(keyPath: "position.y")
            bounceAnimation.keyTimes = [0.0, MapImageView.markerPanStartRelativeTiming, MapImageView.markerPanEndRelativeTiming, 1.0]
            bounceAnimation.values = [currPostionY, currPostionY - mapPinJumpHeight, superViewFrameMidY - markerHeightOffset - mapPinJumpHeight, superViewFrameMidY - markerHeightOffset]
            
            let markerXAnimation = CAKeyframeAnimation(keyPath: "position.x")
            markerXAnimation.keyTimes = [0.0, MapImageView.markerPanStartRelativeTiming, MapImageView.markerPanEndRelativeTiming]
            markerXAnimation.values = [currPostionX, currPostionX, superviewFrame.midX]
            
            self.mapScale = scale
            self.lastPosition = newMapLayerPosition
            self.mapLayer.position = newMapLayerPosition
            self.markerLayer.position = CGPoint(x: superviewFrame.midX, y: superviewFrame.midY + parentMidYOffset - markerHeightOffset)
            
            self.mapLayer.add(positionAnimation, forKey: "position")
            self.mapLayer.add(scaleAnimation, forKey: "transform.scale")
            
            let markerAnimationGroup = CAAnimationGroup()
            markerAnimationGroup.animations = [markerXAnimation, bounceAnimation]
            markerAnimationGroup.duration = MapImageView.markerAnimationDuration
            self.markerLayer.add(markerAnimationGroup, forKey: "markerAnim")
        }
    }
    
    func zoomOut() {
        self.markerLayer.opacity = 0.0
        self.markerLayer.isHidden = true
        
        // 41.8719° N, 12.5674° E - approx center of the map
        self.zoomToLatLong(lat: centerLat, long: centerLong, locationDisplayScale: centerDisplayScale, yCoordOffset: 0)

        let sublayers = self.mapLayer.sublayers
        sublayers?.forEach({ (sublayer) in
            let shapeLayer = sublayer as! CAShapeLayer
            setLocationLayerColors(shapeLayer: shapeLayer, selected: false)
        })
    }
    
    private func setLocationLayerColors(shapeLayer: CAShapeLayer, selected: Bool) {
        if selected {
            shapeLayer.fillColor = locationColor
            shapeLayer.borderColor = locationBorderColor
            shapeLayer.strokeColor = locationBorderColor
            
            shapeLayer.shadowColor = UIColor.locShadowColor.cgColor
            shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
            shapeLayer.shadowRadius = 4.0
            shapeLayer.shadowOpacity = 0.7
            shapeLayer.shadowPath = shapeLayer.path?.copy()!
            shapeLayer.setNeedsDisplay()
            
            shapeLayer.zPosition = 1000
        }
        else {
            shapeLayer.fillColor = locationColorDark
            shapeLayer.borderColor = locationBorderColorDark
            shapeLayer.strokeColor = locationBorderColorDark
            
            shapeLayer.shadowColor = UIColor.clear.cgColor
            
            shapeLayer.zPosition = 100
        }
    }
    
    private func translateScaleToiOS(regionScale: CGFloat, superviewFrame: CGRect) -> CGFloat {
        // scale values were based on 350x500 res, need to compute the right values for iOS
        let height = superviewFrame.height
        
        let iOSAdjustment: CGFloat = 1.25
        
        // scale it based on the height
        let scale = height / 500 * iOSAdjustment * regionScale
        
        return scale
    }
    
    private func shiftMapToRight() {
        if let lastSelected = mainStore.state.regionState.lastSelectedRegionId, !mainStore.state.regionState.cypherplayOn {
            // zoom/pan to this region id
            let realm = try! Realm()
            if let region = realm.object(ofType: Region.self, forPrimaryKey: lastSelected) {
                let coords = transformToXY(lat: region.latitude, long: region.longitude)
                
                if let superView = self.superview {
                    let superviewFrame = superView.frame
                    let superViewFrameMidX = isMapInBackground ? superviewFrame.midX + parentMidXOffset : superviewFrame.midX
                    let superViewFrameMidY = superviewFrame.midY + markerHeightOffset // center vertically when map is shifted to the right
                    
                    let scale = translateScaleToiOS(regionScale: region.locDisplayScale, superviewFrame: superviewFrame)
                    
                    let position = CGPoint(x: superViewFrameMidX - CGFloat(coords.x) * scale, y: superViewFrameMidY - CGFloat(coords.y) * scale)
                    
                    let animationDuration = 0.4
                    
                    // scale animation
                    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                    scaleAnimation.fromValue = self.mapScale
                    scaleAnimation.toValue = scale
                    
                    // move the map
                    let positionAnimation = CABasicAnimation(keyPath: "position")
                    
                    if let currentPosition = self.lastPosition {
                        positionAnimation.fromValue = currentPosition
                    }
                    else {
                        positionAnimation.fromValue = CGPoint(x: superViewFrameMidX, y: superViewFrameMidY)
                    }
                    positionAnimation.toValue = position
                    
                    // animation group
                    let animationGroup = CAAnimationGroup()
                    animationGroup.duration = animationDuration
                    animationGroup.fillMode = kCAFillModeForwards
                    animationGroup.isRemovedOnCompletion = false
                    animationGroup.animations = [positionAnimation, scaleAnimation]
                    
                    // animate the position of the marker
                    let xCoord = isMapInBackground ? superviewFrame.midX + parentMidXOffset : superviewFrame.midX
                    let markerPosition = CGPoint(x: xCoord, y: superviewFrame.midY) // y-coord should be centered
                    
                    let markerPositionAnimation = CABasicAnimation(keyPath: "position")
                    // use the position in the presentation layer because another animation might be in progress
                    markerPositionAnimation.fromValue = self.markerLayer.presentation()?.position
                    markerPositionAnimation.toValue = markerPosition
                    markerPositionAnimation.duration = animationDuration
                    
                    self.mapScale = scale
                    self.lastPosition = position
                    self.mapLayer.position = position
                    self.markerLayer.position = markerPosition
                    
                    // remove any existing animations
                    self.markerLayer.removeAllAnimations()
                    
                    self.mapLayer.add(animationGroup, forKey: "panAndZoom")
                    self.markerLayer.add(markerPositionAnimation, forKey: "markerPosition")
                    
                    let sublayers = self.mapLayer.sublayers
                    sublayers?.forEach({ (sublayer) in
                        let shapeLayer = sublayer as! CAShapeLayer
                        let regionId = shapeLayer.value(forKey: "regionId") as! String
                        setLocationLayerColors(shapeLayer: shapeLayer, selected: regionId == region.id)
                    })
                }
            }
        }
    }
    
    func shiftMapToLeft() {
        if let lastSelected = mainStore.state.regionState.lastSelectedRegionId {
            // zoom/pan to this region id
            let realm = try! Realm()
            if let region = realm.object(ofType: Region.self, forPrimaryKey: lastSelected) {
                let coords = transformToXY(lat: region.latitude, long: region.longitude)
                
                if let superView = self.superview {
                    let superviewFrame = superView.frame
                    let superViewFrameMidX = superviewFrame.midX
                    let superViewFrameMidY = superviewFrame.midY + parentMidYOffset
                    
                    let scale = translateScaleToiOS(regionScale: region.locDisplayScale, superviewFrame: superviewFrame)
                    
                    let position = CGPoint(x: superViewFrameMidX - CGFloat(coords.x) * scale, y: superViewFrameMidY - CGFloat(coords.y) * scale)
                    
                    // scale animation
                    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                    scaleAnimation.fromValue = self.mapScale
                    scaleAnimation.toValue = scale
                    
                    // move the map
                    let positionAnimation = CABasicAnimation(keyPath: "position")
                    
                    if let currentPosition = self.lastPosition {
                        positionAnimation.fromValue = currentPosition
                    }
                    else {
                        positionAnimation.fromValue = CGPoint(x: superViewFrameMidX, y: superViewFrameMidY)
                    }
                    positionAnimation.toValue = position
                    
                    // animation group
                    let animationGroup = CAAnimationGroup()
                    animationGroup.duration = MapImageView.mapPanDuration / 2
                    animationGroup.fillMode = kCAFillModeForwards
                    animationGroup.isRemovedOnCompletion = false
                    animationGroup.animations = [positionAnimation, scaleAnimation]
                    
                    // animate the position of the marker
                    let xCoord = isMapInBackground ? superviewFrame.midX + parentMidXOffset : superviewFrame.midX
                    let markerPosition = CGPoint(x: xCoord, y: superviewFrame.midY + parentMidYOffset - markerHeightOffset)
                    
                    let markerPositionAnimation = CABasicAnimation(keyPath: "position")
                    markerPositionAnimation.fromValue = self.markerLayer.position
                    markerPositionAnimation.toValue = markerPosition
                    markerPositionAnimation.duration = MapImageView.mapPanDuration / 2
                    
                    self.mapScale = scale
                    self.lastPosition = position
                    self.mapLayer.position = position
                    self.markerLayer.position = markerPosition
                    self.mapLayer.add(animationGroup, forKey: "panAndZoom")
                    self.markerLayer.add(markerPositionAnimation, forKey: "markerPosition")
                    
                    let sublayers = self.mapLayer.sublayers
                    sublayers?.forEach({ (sublayer) in
                        let shapeLayer = sublayer as! CAShapeLayer
                        let regionId = shapeLayer.value(forKey: "regionId") as! String
                        setLocationLayerColors(shapeLayer: shapeLayer, selected: regionId == region.id)
                    })
                }
            }
        }
    }
    
    // MARK: - Map Helpers
    let mapSize = 1000.0 // width, image is 2000 pixels but in points it will be 1000
    let longOffset: Double = 11
    let pi = Double.pi
    let halfPi = Double.pi / 2
    let epsilon = Double.ulpOfOne
    
    // accepts radians
    private func vanDerGrinten3Raw(lambda: Double, phi: Double) -> (x: Double, y: Double) {
        if (abs(phi) < epsilon) {
            return (x: lambda, y: 0)
        }
        
        let sinTheta = phi / halfPi
        let theta = asin(sinTheta)
        
        if (abs(lambda) < epsilon || abs(abs(phi) - halfPi) < epsilon) {
            return (x: 0, y: pi * tan(theta / 2))
        }
        
        let A = (pi / lambda - lambda / pi) / 2
        let y1 = sinTheta / (1 + cos(theta))
        
        return (x: pi * (sign(lambda) * sqrt(A * A + 1 - y1 * y1) - A), y: pi * y1)
    }
    
    // GPS coordinates in degrees
    func transformToXY(lat: Double, long: Double) -> (x: Double, y: Double) {
        let coords = vanDerGrinten3Raw(lambda: (long - longOffset) * pi / 180, phi: lat * pi / 180)
        
        let temp: Double = mapSize / 920.0
        let xCoord = (coords.x * 150.0 + (920 / 2)) * temp
        let yCoord = (-coords.y * 150 + (500 / 2 + 500 * 0.15)) * temp
        
        return (x: xCoord, y: yCoord)
    }
}
