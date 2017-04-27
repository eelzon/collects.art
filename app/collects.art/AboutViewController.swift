//
//  AboutViewController.swift
//  collects.art
//
//  Created by Nozlee Samadzadeh on 4/24/17.
//  Copyright © 2017 Nozlee Samadzadeh and Bunny Rogers. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

  @IBOutlet weak var webView: UIWebView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let file = Bundle.main.path(forResource: "about", ofType: "html")!
    do {
      let html = try NSString.init(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue)
      webView.loadHTMLString(html as String, baseURL: URL.init(fileURLWithPath: Bundle.main.bundlePath))
    } catch {
      webView.loadHTMLString("<html><body><p>Collects is an anonymized social network in the style of the artist Bunny Rogers. Create your own collects or view the work of others at <a href='https://collectable.art'>collectable.art</a>.</p></body></html>", baseURL: nil)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.view?.superview?.layer.cornerRadius = 0;
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
   }
   */

}
