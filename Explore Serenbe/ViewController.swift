
//  ViewController.swift

import UIKit
import WebKit
import Network
import SystemConfiguration
import SafariServices
import JXWebViewController
import SwiftUI

import NVActivityIndicatorView

let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")

class ViewController: UIViewController,WKNavigationDelegate,WKUIDelegate{

    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var nonet: UIButton!
    
    var activityIndicatorView:NVActivityIndicatorView!
    
    private let presentingIndicatorTypes = {
          return NVActivityIndicatorType.allCases.filter { $0 != .blank }
      }()
 
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      
        
        if Reachability.shared.isConnectedToNetwork(){
                
               nonet.isHidden = true
              // let url = URL(string: "https://google.com")!
              // myWebView3.load(URLRequest(url: url))
              // myWebView3.allowsBackForwardNavigationGestures = true
            
                webview.isHidden = false
               
               
                activityIndicatorView.startAnimating()
          
          
            
        }else{
            nonet.isHidden = false
        
            webview.isHidden = true
          }
        
        
        
    }
    
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         
         activityIndicatorView.stopAnimating()
        
         print("didfinish")
       
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (_: WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyForNavigationResponse")
        decisionHandler(.allow)
    }
    

    
      func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
          if navigationAction.targetFrame?.isMainFrame == nil {
              webView.load(navigationAction.request)
              
          }
          return nil
      }
      
      
      func webViewDidClose(_ webView: WKWebView) {
          view = self.webview
      }

      

   @objc func dismiss(){
       self.dismiss(animated: true)
   }

      func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
           
          
          
          if webview != self.webview {
               decisionHandler(.allow)
               return
           }

           let app = UIApplication.shared
           if let url = navigationAction.request.url {
               // Handle target="_blank"
               if navigationAction.targetFrame == nil {
                   if app.canOpenURL(url) {
                     //  app.open(url)
                    
                    let webViewController = JXWebViewController()
                                       webViewController.webView.load(URLRequest(url: url))
                                     //  present(webViewController, animated: true, completion: nil)
                    
                    let navController = UINavigationController(rootViewController: webViewController)
                    webViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,action:  "dismiss")
                    
                    present(navController, animated: true, completion: nil)
                    
                    
                    

                      decisionHandler(.cancel)
                       return
                   }
               }

               // Handle phone and email links
               if url.scheme == "tel" || url.scheme == "mailto" || url.scheme == "whatsapp" {
                   if app.canOpenURL(url) {
                       app.open(url)
                   }

                   decisionHandler(.cancel)
                   return
               }

               decisionHandler(.allow)
           }
          
          
      }
 
    override func viewDidLoad() {
        
         super.viewDidLoad()
         self.webview.navigationDelegate = self
         self.webview.uiDelegate=self
     
        let url:URL=URL(string: "https://explore.serenbe.com/")!
        let urlRequest:URLRequest=URLRequest(url:url)
        webview.load(urlRequest)
        webview.allowsBackForwardNavigationGestures = true
        nonet.isHidden = true
        webview.scrollView.bounces = true
       
    
        
        
        
       
               
               let midX = self.view.bounds.midX
               let midY = self.view.bounds.midY
                      
               let frame = CGRect(x: midX - 70.0, y: midY - 70.0, width:70.0, height:70.0)
               activityIndicatorView = NVActivityIndicatorView(frame: frame,type:NVActivityIndicatorType.ballScaleRippleMultiple, color: UIColor.black)
               activityIndicatorView.center = self.view.center
                      
               self.view.addSubview(activityIndicatorView)
        
        
        
        
       if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        
        let dictionary = [
            "UserAgent" : "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_3 like Mac OS X) AppleWebKit/603.3.8 (KHTML, like Gecko) Mobile/14G60"
        ]
        
        UserDefaults.standard.register(defaults: dictionary)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webview.scrollView.addSubview(refreshControl)
    
    }
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        webview?.reload()
        sender.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapreload(_ sender: Any) {
        
                webview.isHidden = false
                nonet.isHidden = true
                 
        if ((webview.url?.absoluteString.isEmpty) != nil){
            
            webview.reload()
        }else{
            
            let url:URL=URL(string: "https://explore.serenbe.com/")!
                   let urlRequest:URLRequest=URLRequest(url:url)
                   webview.load(urlRequest)
            
            
        }
                
        
        
        
    }
    
}


final class Reachability {

private init () {}
class var shared: Reachability {
    struct Static {
        static let instance: Reachability = Reachability()
    }
    return Static.instance
}

func isConnectedToNetwork() -> Bool {
        guard let flags = getFlags() else { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

    private func getFlags() -> SCNetworkReachabilityFlags? {
        guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
            return nil
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return nil
        }
        return flags
    }

    private func ipv6Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin6_family = sa_family_t(AF_INET6)

        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
    private func ipv4Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
}
