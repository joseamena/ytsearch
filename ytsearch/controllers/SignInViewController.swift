//
//  SignInViewController.swift
//  ytsearch
//
//  Created by Jose on 8/31/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import GoogleSignIn
import UIKit

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    let signInButton = GIDSignInButton()
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.center = view.center
        view.addSubview(signInButton)
        signInButton.isHidden = true    //hide it, only show it log-in fails

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
    }

    override func viewDidAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().signInSilently()
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

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("signIn \(user)\n");
        if let error = error {
            signInButton.isHidden = false
            print(error)
        } else {
            signInButton.isHidden = true
            VideoService.shared.user = user
            performSegue(withIdentifier: "toVideos", sender: nil)
        }
    }
}

//helper methods
extension SignInViewController {

    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}


