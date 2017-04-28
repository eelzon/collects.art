//
//  AboutViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/24/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {

  @IBOutlet weak var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let file = Bundle.main.path(forResource: "about", ofType: "html")!
    do {
      let html = try NSString.init(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue)
      webView.loadHTMLString(html as String, baseURL: URL.init(fileURLWithPath: Bundle.main.bundlePath))
    } catch {
      webView.loadHTMLString("<html><body><p>Collects is an anonymized social network in the style of the artist Bunny Rogers, created in 2017 for Rhizome's <a href='https://sevenonseven.art'>Seven on Seven</a> by Nozlee Samadzadeh and Bunny Rogers. Create your own collects or view the work of others at <a href='https://collectable.art'>collectable.art</a>.</p></body></html>", baseURL: nil)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.view?.superview?.layer.cornerRadius = 0
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if navigationType == UIWebViewNavigationType.linkClicked {
      UIApplication.shared.openURL(request.url!)
      return false
    }
    return true
  }

}
