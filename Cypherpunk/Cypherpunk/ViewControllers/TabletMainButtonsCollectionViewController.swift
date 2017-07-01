//
//  TabletMainButtonsCollectionViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/8/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "ButtonCell"

class TabletMainButtonsCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let cellNib = UINib(nibName: "TabletButtonCollectionViewCell", bundle: nil)
        self.collectionView!.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegionUpdateNotification), name: regionUpdateNotification, object: nil)

        // Do any additional setup after loading the view.
        setContentInsets(landscape: UIDevice.current.orientation.isLandscape)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRegionUpdateNotification() {
        self.collectionView?.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // the device is going to rotate but has not rotated yet, set insets based on what the orientation will be
        setContentInsets(landscape: UIDevice.current.orientation.isLandscape)
        
        // reload to force cells to run prepare for reuse
        self.collectionView?.reloadData()
    }
    
    private func setContentInsets(landscape: Bool) {
        if landscape {
            self.collectionView?.contentInset.top = 12
            self.collectionView?.contentInset.bottom = 12
            self.collectionView?.contentInset.right = 0
            self.collectionView?.contentInset.left = 0
        }
        else {
            self.collectionView?.contentInset.top = 10
            self.collectionView?.contentInset.bottom = 10
            self.collectionView?.contentInset.left = 12
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let realm = try! Realm()
        if realm.isEmpty || realm.objects(Region.self).isEmpty {
            return 0 // no servers yet
        }
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TabletButtonCollectionViewCell
    
        // Configure the cell
        switch indexPath.item {
        case 0:
            cell?.imageView.image = R.image.cypherPlay()
            cell?.titleLabel.text = "CypherPlay™"
        case 1:
            cell?.imageView.image = R.image.fastestServer()
            cell?.titleLabel.text = "Fastest Server"
        case 2:
            cell?.imageView.image = R.image.us()
            cell?.titleLabel.text = "Fastest USA"
        case 3:
            cell?.imageView.image = R.image.gb()
            cell?.titleLabel.text = "Fastest UK"
        default:
            break
        }
    
        return cell!
    }
    
    
    

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.item {
        case 0:
            ConnectionHelper.connectToFastest(cypherplay: true)
        case 1:
            ConnectionHelper.connectToFastest(cypherplay: false)
        case 2:
            ConnectionHelper.connectToFastest(cypherplay: false, country: "US")
        case 3:
            ConnectionHelper.connectToFastest(cypherplay: false, country: "GB")
        default:
            break
        }
    }
}

extension TabletMainButtonsCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UIDevice.current.orientation.isLandscape {
            let collectionViewWidth = UIScreen.main.bounds.width - 350
            return CGSize(width: (collectionViewWidth - 50) / 4, height: 90)
        }
        else {
            let collectionViewWidth = UIScreen.main.bounds.width - 350
            return CGSize(width: (collectionViewWidth - 50) / 2, height: 60)
        }
    }
}
