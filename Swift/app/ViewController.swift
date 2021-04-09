//
//  ViewController.swift
//  app
//
//  Created by Venom on 04/10/19.
//  Copyright © 2019 Venom. All rights reserved.
//

import UIKit
import AuthenticationServices
import Parse

class AuthDelegate:NSObject, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        return true
    }
    
    func restoreAuthenticationWithAuthData(authData: [String : String]?) -> Bool {
        return true
    }
}

class ViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var delegateLoaded = false

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            print("AUTHORIZED: \(credentials.fullName?.givenName ?? "")")
            
            let token = credentials.identityToken!
            let tokenString = String(data: token, encoding: .utf8)!
            let user = credentials.user
            
            print("TOKEN: \(tokenString)")
            print("USER: \(user)")
            
            if (! delegateLoaded){
                PFUser.register(AuthDelegate(), forAuthType: "apple")
                delegateLoaded = true
            }
            
            PFUser.logInWithAuthType(inBackground: "apple", authData: ["token":tokenString, "id": user]).continueWith { task -> Any? in
//                guard task.error == nil, let _ = task.result else {
//                    print("TASK: \(String(describing: task.result?.email!))")
//                    return task
//                }
//
//                if ((task.error) != nil){
//                    print("ERROR: \(task.error?.localizedDescription)")
//                }
//                return task
                
                if let userObject = task.result {
                    // Fill userObject (which is PFUser) by profile data, like:
                    //userObject.email = user.profile.email
                    //userObject.password = UUID().uuidString
                    //userObject["firstName"] = user.profile.givenName
                    //userObject["lastName"] = user.profile.familyName
                    print("LOGGED IN PARSE")
                } else {
                    // Failed to log in.
                    print("ERROR LOGGING IN IN PARSE: \(task.error?.localizedDescription)")
                }
                return nil
            }
            
            break
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("ERROR: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    func setupView(){
        let signInWithAppleButton = ASAuthorizationAppleIDButton()
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleButton.addTarget(self, action: #selector(didClickSignInWithAppleButton), for: .touchUpInside)
        
        view.addSubview(signInWithAppleButton)
        NSLayoutConstraint.activate([
            signInWithAppleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInWithAppleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    @objc
    func didClickSignInWithAppleButton(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }

}

