//
//  MapImageView.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/5/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import RealmSwift
import simd

class MapImageView: UIView {
    static let mapPanDuration = 1.25 // duration of the map animation when it pans/zooms
    private let locationColor = UIColor.init(hex: "#008888")!.cgColor
    private let locationBorderColor = UIColor.init(hex: "#004444")!.cgColor
    private let markerLayer = CALayer()
    private let mapLayer = CALayer()
    private var scaleTransform: CATransform3D? = nil
    private var mapScale: CGFloat = 1.0
    private var lastPosition: CGPoint? = nil

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
        if layer == self.layer {
            // set frame for all map sublayers
            self.mapLayer.frame = self.bounds
            let sublayers = self.mapLayer.sublayers
            sublayers?.forEach({ (sublayer) in
                sublayer.frame = self.bounds
            })
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
        let mapImage = createTransparentMapImage()
        self.mapLayer.contents = mapImage?.cgImage
        self.mapLayer.contentsScale = UIScreen.main.scale
        self.mapLayer.frame = CGRect(x: 0, y: 0, width: (mapImage?.size.width)!, height: (mapImage?.size.height)!)
        self.mapLayer.contentsGravity = kCAGravityBottomLeft
        self.layer.addSublayer(self.mapLayer)
        
        self.contentMode = .center
        self.layer.needsDisplayOnBoundsChange = true
        
        drawLocationsOnMap()
        
        let markerImage = UIImage.fontAwesomeIcon(name: .mapMarker, textColor: UIColor(red: 136.0 / 255.0, green: 1.0, blue: 1.0, alpha: 1.0), size: CGSize(width: 50, height: 50))
        print(markerImage.size)
        self.markerLayer.contents = markerImage.cgImage
        self.markerLayer.contentsScale = UIScreen.main.scale
        self.markerLayer.frame = CGRect(x: 50, y: 100, width: 50, height: 50)
        self.markerLayer.contentsGravity = kCAGravityCenter
        self.markerLayer.opacity = 1.0
        self.layer.addSublayer(self.markerLayer)
//        self.markerLayer.isHidden = true
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
        let dotPath = UIBezierPath(ovalIn: CGRect(x: imageCoordinates.x - 2.5, y: imageCoordinates.y - 2.5, width: 5, height: 5))

        let layer = CAShapeLayer()
        layer.path = dotPath.cgPath
        layer.fillColor = locationColor
        layer.strokeColor = locationBorderColor
        
        layer.setValue(regionId, forKey: "regionId")
        layer.contentsScale = UIScreen.main.scale
        
        self.mapLayer.addSublayer(layer)
    }
    
//    func zoomToScale(_ scale: CGFloat) {
//        UIView.animate(withDuration: MapImageView.mapPanDuration) {
//            self.mapLayer.setAffineTransform(CGAffineTransform.init(scaleX: scale, y: scale))
//        }
//    }
    
    func zoomToLastSelected() {
        if let lastSelected = mainStore.state.regionState.lastSelectedRegionId {
            // zoom/pan to this region id
            let realm = try! Realm()
            if let selectedRegion = realm.object(ofType: Region.self, forPrimaryKey: lastSelected) {
                zoomToRegion(region: selectedRegion)
            }
        }
    }
    
    func zoomToRegion(region: Region) {
        let coords = transformToXY(lat: region.latitude, long: region.longitude)
        
        if let superView = self.superview {
            let superviewFrame = superView.frame
            let superViewFrameMidX = superviewFrame.midX
            let superViewFrameMidY = superviewFrame.midY
            
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
            animationGroup.duration = MapImageView.mapPanDuration
            animationGroup.fillMode = kCAFillModeForwards
            animationGroup.isRemovedOnCompletion = false
            animationGroup.animations = [positionAnimation, scaleAnimation]
            
            self.mapScale = scale
            self.lastPosition = position
            self.mapLayer.position = position
            self.mapLayer.add(animationGroup, forKey: "panAndZoom")
        }
    }
    
    func zoomToRegion(regionId: String) {
        let realm = try! Realm()
        if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
            zoomToRegion(region: region)
        }
    }
    
    private func translateScaleToiOS(regionScale: CGFloat, superviewFrame: CGRect) -> CGFloat {
        // scale values were based on 350x500 res, need to compute the right values for iOS
        let height = superviewFrame.height
        
        // scale it based on the height
        let scale = height / 500 * regionScale
        
        return scale
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
