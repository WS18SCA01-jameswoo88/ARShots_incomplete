//
//  ViewController.swift
//  ARShots
//
//  Created by James Chun on 1/19/19.
//  Copyright © 2019 James Chun. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var hoopAdded: Bool = false; //p. 489: 1st tap creates hoop, subsequent taps create balls
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [
            .showWorldOrigin      //red, green, blue axes, p. 457
        ];
        
        // Create a new scene containing an omni light.
        guard let scene: SCNScene = SCNScene(named: "art.scnassets/empty.scn") else {
            fatalError("couldn't find art.scnassets/hoop.scn");
        }
        
        // Set the scene to the view.
        sceneView.scene = scene;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration();
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if !hoopAdded {
            let touchLocation: CGPoint = sender.location(in: sceneView)
            let hitTestResult: [ARHitTestResult] = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
            
            if let result: ARHitTestResult = hitTestResult.first {
                print("Ray intersected a discovered plane")
                addHoop(result: result)
                hoopAdded = true
            }
        } else {
            createBasketball()
        }
    }
    
    func addHoop(result: ARHitTestResult) {
        // Retrieve the scene file and locate the "Hoop" node
        guard let hoopScene: SCNScene = SCNScene(named: "art.scnassets/hoop.scn") else {
            fatalError("couldn't find art.scnassets/hoop.scn");
        }
        
        guard let hoopNode: SCNNode = hoopScene.rootNode.childNode(withName: "Hoop", recursively: false) else {
            fatalError("couldn't find node Hoop in art.scnassets/hoop.scn");
        }
        
        guard let anchor: ARAnchor = result.anchor else {
            fatalError("ARHitTestResult had no anchor.");
        }
        
        // Place the hoopNode in the correct position and orientation.
        
        hoopNode.transform = SCNMatrix4(anchor.transform); //4 X 4 matrix
        hoopNode.eulerAngles.x -= Float.pi / 2;
        let position: simd_float4 = result.worldTransform.columns.3;
        hoopNode.position = SCNVector3(position.x, position.y, position.z);
        
        // Add the node to the scene.
        // Scaling the Hoop node in the Node Inspector didn't work here.
        
        hoopNode.scale = SCNVector3(0.25, 0.25, 0.25);
        sceneView.scene.rootNode.addChildNode(hoopNode);
    }
    
    func createBasketball() {
        guard let currentFrame: ARFrame = sceneView.session.currentFrame else {
            fatalError("could not get current frame");
        }
        
        let geometry: SCNSphere = SCNSphere(radius: 0.25 * 0.25); //to match the small hoop
        if let firstMaterial: SCNMaterial = geometry.firstMaterial {
            firstMaterial.diffuse.contents = UIColor.orange;
        } else {
            fatalError("geometry.firstMaterial == nil");
        }
        
        let ball = SCNNode(geometry: geometry);
        let cameraTransform: SCNMatrix4 = SCNMatrix4(currentFrame.camera.transform);
        ball.transform = cameraTransform;
        
        sceneView.scene.rootNode.addChildNode(ball)
    }
    
}
