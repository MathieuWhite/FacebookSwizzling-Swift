//
//  ViewController.swift
//  FacebookSwizzle
//
//  Created by Mathieu White on 2016-05-18.
//  Copyright © 2016 Mathieu White. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.didPressFacebookShareAction),
                                                         name: "kSwizzleNotification",
                                                         object: nil)
        
    }
    
    func didPressFacebookShareAction()
    {
        print("success!")
        
        let alert = UIAlertController(title: "Success", message: "Just swizzled the Facebook share action.", preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let activityItems = ["Method Swizzling"]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}


// MARK: - UIActivity Method Swizzling

// Swizzling example on NSHipster
// http://nshipster.com/swift-objc-runtime/
// http://nshipster.com/method-swizzling/
extension UIActivity {
    
    public override class func initialize() {
        
        // Make sure this isn't a subclass
        if (self !== UIActivity.self) {
            return
        }
        
        struct Static {
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            UIActivity.swizzleInstanceMethods(#selector(UIActivity.prepareWithActivityItems(_:)),
                                              swizzledSelector: #selector(UIActivity.mwx_prepareWithActivityItems(_:)))
            
            UIActivity.swizzleInstanceMethods(#selector(UIActivity.canPerformWithActivityItems(_:)),
                                              swizzledSelector: #selector(UIActivity.mwx_canPerformWithActivityItems(_:)))
            
            UIActivity.swizzleInstanceMethods(#selector(UIActivity.performActivity),
                                              swizzledSelector: #selector(UIActivity.mwx_performActivity))
        }
    }
    
    
    static var mwx_defaultFacebookActivityType: String {
        let array = ["com", "apple", "UIKit", "activity", "PostToFacebook"]
        return array.joinWithSeparator(".")
    }
    
    func mwx_canUseFacebookActivityOverride() -> Bool {
        let activityType = self.activityType()
        return (activityType == UIActivity.mwx_defaultFacebookActivityType)
    }
    
    func mwx_canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        if (self.mwx_canUseFacebookActivityOverride()) {
            return true
        }
        
        return self.mwx_canPerformWithActivityItems(activityItems)
    }
    
    func mwx_prepareWithActivityItems(activityItems: [AnyObject]) {
        if (!self.mwx_canUseFacebookActivityOverride()) {
            self.mwx_prepareWithActivityItems(activityItems)
            return
        }

        // Do something with the items
    }
    
    func mwx_performActivity() {
        if (!self.mwx_canUseFacebookActivityOverride()) {
            self.mwx_performActivity()
            return
        }
        
        // Do something when the facebook option is selected
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("kSwizzleNotification", object: nil)
        
    }
    
    
    static func swizzleInstanceMethods(originalSelector: Selector, swizzledSelector: Selector) {
        
        let ac: AnyClass = NSClassFromString(String(format: "UI%@%@%@", "Soc", "ialActi", "vity"))!
        
        let originalMethod = class_getInstanceMethod(ac, originalSelector)
        let swizzledMethod = class_getInstanceMethod(ac, swizzledSelector)
        
        let didAddMethod = class_addMethod(ac, originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        
        if (didAddMethod) {
            class_replaceMethod(ac, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
}

