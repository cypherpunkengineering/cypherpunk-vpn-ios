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

class MapImageView: UIImageView {
    private let locationColor = UIColor.init(hexString: "#008888").cgColor
    private let locationBorderColor = UIColor.init(hexString: "#004444").cgColor

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(image: R.image.worldmap_2000())
        setupMap()
    }
    
    override init(frame: CGRect) {
        super.init(image: R.image.worldmap_2000())
        setupMap()
    }
    
    init() {
        super.init(image: R.image.worldmap_2000())
        setupMap()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        if layer == self.layer {
            // set bounds for all sublayers
            let sublayers = self.layer.sublayers
            sublayers?.forEach({ (sublayer) in
                sublayer.frame = self.bounds
            })
        }
    }
    
    private func setupMap() {
        self.contentMode = .center
        self.alpha = 0.3
        self.layer.needsDisplayOnBoundsChange = true
        
        drawLocationsOnMap()
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
        
        self.layer.addSublayer(layer)
    }
    
    func zoomToScale(_ scale: CGFloat) {
        UIView.animate(withDuration: 5.0) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
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
        let scale = region.locDisplayScale
        
        let coords = transformToXY(lat: region.latitude, long: region.longitude)
        
        if let superView = self.superview {
            let superviewFrame = superView.frame
            let superViewFrameMidX = superviewFrame.midX
            let superViewFrameMidY = superviewFrame.midY
            
            UIView.animate(withDuration: 2.0, animations: {
                self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                
                self.frame = CGRect(x: superViewFrameMidX - CGFloat(coords.x) * scale, y: superViewFrameMidY - CGFloat(coords.y) * scale, width: self.frame.size.width, height: self.frame.size.height)
            })
        }
    }
    
    func zoomToRegion(regionId: String) {
        let realm = try! Realm()
        if let region = realm.object(ofType: Region.self, forPrimaryKey: regionId) {
            zoomToRegion(region: region)
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
