//
//  PlanCollectionViewController.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 3/3/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import APIKit

private let reuseIdentifier = "PlanCell"

class PlanCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    fileprivate var retrievedProducts: [SKProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let planNib = UINib(nibName: "PlanCollectionViewCell", bundle: nil)
        self.collectionView?.register(planNib, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
//        if let subscriptionType = mainStore.state.accountState.subscriptionType {
//            switch subscriptionType {
//            case .monthly:
//                monthlyCellContentView.alpha = 0.5
//                monthlyCellContentView.isUserInteractionEnabled = false
//                monthlyCurrentPlanLabelView.isHidden = false
//            case .semiannually:
//                semiannuallyCellContentView.alpha = 0.5
//                semiannuallyCellContentView.isUserInteractionEnabled = false
//                semiannuallyCurrentPlanLabelView.isHidden = false
//            case .annually:
//                annuallyCellContentView.alpha = 0.5
//                annuallyCellContentView.isUserInteractionEnabled = false
//                annuallyCurrentPlanLabelView.isHidden = false
//            default:
//                break
//            }
//        }
        IndicatorView.show()
        
        // default show all products
        var productIds = [
            SubscriptionType.monthly.subscriptionProductId,
            SubscriptionType.semiannually.subscriptionProductId,
            SubscriptionType.annually.subscriptionProductId]
        
        // get only the products for the current plan and the products that the user can upgrade to
        if let subscriptionType = mainStore.state.accountState.subscriptionType {
            switch subscriptionType {
            case.semiannually:
                productIds = [
                    SubscriptionType.semiannually.subscriptionProductId,
                    SubscriptionType.annually.subscriptionProductId]
            case .annually:
                productIds = [SubscriptionType.annually.subscriptionProductId]
            default:
                break
            }
        }
        
        SwiftyStoreKit.retrieveProductsInfo([
            SubscriptionType.monthly.subscriptionProductId,
            SubscriptionType.semiannually.subscriptionProductId,
            SubscriptionType.annually.subscriptionProductId
        ]) { result in
            self.retrievedProducts.removeAll()
            
            productIds.forEach({ (productId) in
                let filteredResults = result.retrievedProducts.filter({ return $0.productIdentifier == productId })
                if let result = filteredResults.first {
                    self.retrievedProducts.append(result)
                }
            })
            
//            self.retrievedProducts.append(result.retrievedProducts.filter{return $0.productIdentifier == SubscriptionType.monthly.subscriptionProductId}[0])
//            self.retrievedProducts.append(result.retrievedProducts.filter{return $0.productIdentifier == SubscriptionType.semiannually.subscriptionProductId}[0])
//            self.retrievedProducts.append(result.retrievedProducts.filter{return $0.productIdentifier == SubscriptionType.annually.subscriptionProductId}[0])
            // dismiss Indicator
            self.collectionView?.reloadData()
            IndicatorView.dismiss()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if retrievedProducts.count == 0 {
            return 0
        }
        
        let accountState = mainStore.state.accountState
        
        if let subscription = accountState.subscriptionType, case .semiannually = subscription {
            return 2
        }
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PlanCollectionViewCell
        
        let product = self.retrievedProducts[indexPath.item]
        cell?.monthlyCostLabel.text = pricePerMonthString(product: product)
        
        if product.productIdentifier == SubscriptionType.monthly.subscriptionProductId {
            cell?.planNameLabel.text = "Monthly"
        }
        else if product.productIdentifier == SubscriptionType.semiannually.subscriptionProductId {
            cell?.planNameLabel.text = "6 Months"
        }
        else if product.productIdentifier == SubscriptionType.annually.subscriptionProductId {
            cell?.planNameLabel.text = "Annually"
        }
        
        if product.productIdentifier == mainStore.state.accountState.subscriptionType?.subscriptionProductId {
            // this product is the currently selected plan
            cell?.setCurrentPlanColors()
            cell?.isUserInteractionEnabled = false
        }
        else {
            if product.productIdentifier == SubscriptionType.annually.subscriptionProductId {
                cell?.setBestValueColors()
            }
            
            cell?.isUserInteractionEnabled = true
        }
        return cell!
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        upgradePlan(newProduct: retrievedProducts[indexPath.item])
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - 40, height: 88);
    }
    
    
    private func pricePerMonthString(product: SKProduct) -> String? {
        var priceString: String? = nil
        if let months = AccountState.numberOfMonthsForPlan(planId: product.productIdentifier) {
            priceString = product.localizedPrice(perMonth: months)
        }
        return priceString
    }
    
    // Determines if renewal string should be every month, 6 months, or year
    private func renewalEveryString(product: SKProduct) -> String {
        var renewalString: String = ""
        
        let planId = product.productIdentifier
        
        if SubscriptionType.monthly.planId == planId {
            renewalString = "month"
        }
        else if SubscriptionType.semiannually.planId == planId {
            renewalString = "6 months"
        }
        else if SubscriptionType.annually.planId == planId {
            renewalString = "year"
        }
        
        return renewalString
    }
    
    private func upgradePlan(newProduct: SKProduct) {
        let priceString = newProduct.localizedPrice!
        let renewalString = renewalEveryString(product: newProduct)
        let alert = UIAlertController(title: "Subscription Terms", message: "Subscribe to Recurring Subscription. This subscription will automatically renew every \(renewalString) for \(priceString)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action in
            IndicatorView.show()
            SwiftyStoreKit.purchaseProduct(SubscriptionType.semiannually.subscriptionProductId, atomically: false) { result in
                switch result {
                case .success(let product):
                    
                    let upgradeRequest = UpgradeRequest(
                        session: mainStore.state.accountState.session!,
                        accountId: mainStore.state.accountState.mailAddress!,
                        planId: SubscriptionType.semiannually.planId,
                        receipt: SwiftyStoreKit.localReceiptData!
                    )
                    Session.send(upgradeRequest) {
                        (result) in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                if product.needsFinishTransaction {
                                    SwiftyStoreKit.finishTransaction(product.transaction)
                                }
                                mainStore.dispatch(AccountAction.upgrade(subscription: .semiannually, expiredDate: Date()))
                                IndicatorView.dismiss()
                                self.dismiss(animated: true, completion: nil)
                            }
                        case .failure(let error):
                            print(error)
                            IndicatorView.dismiss()
                        }
                    }
                case .error(let error):
                    print(error)
                    IndicatorView.dismiss()
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

fileprivate extension SKProduct {
    func localizedPrice(perMonth: Int) -> String? {
        let nsNumberPerMonth = NSDecimalNumber(value: perMonth)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = self.priceLocale
        numberFormatter.numberStyle = .currency
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return numberFormatter.string(from: self.price.dividing(by: nsNumberPerMonth, withBehavior: handler))
    }
}
