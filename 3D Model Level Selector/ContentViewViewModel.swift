//
//  ModelViewController.swift
//  3D Model Level Selector
//
//  Created by Brad Angliss on 23/04/2024.
//

import Foundation
import SwiftUI
import SceneKit

enum Nodes: String {
    case ftm = "tree_ref"
    case tree = "fantasy_ref"
    case house = "house_ref"
    case house2 = "chinese_buliding_ref"
}

extension ContentView {
    class ViewModel: ObservableObject {
        var mainScene: SCNScene
        var camera: SCNNode
        var pivot: SCNNode
        var nodeObjects = [SCNNode]()
        var selectedIndex: Int = 0
        
        var titles: [String] = [
            "Treetop Stronghold",
            "Mythic Township Revival",
            "Spectral Echoes",
            "Echoes of the Dynasty"
        ]
        var descriptions: [String] = [
            "Conquer guardians, climb branches, unveil secrets in this enchanted medieval treehouse adventure.",
            "Embark on quests to gather resources, recruit allies, and fortify your fantasy town against impending threats.",
            "Explore the haunting ruins, uncover dark secrets, and confront spectral entities in this desolate medieval house.",
            "Navigate ancient halls, decipher puzzles, and confront legendary spirits in this mystical Chinese adventure."
        ]
        
        @Published var levelTitle: String
        @Published var levelDescription: String
        
        init() {
            let scene = SCNScene(named: "MainScene.scn")!
            mainScene = makeScene(name: "MainScene.scn")!
            camera = setUpCamera()!
            pivot = scene.rootNode.childNode(withName: "pivot", recursively: true)!
            levelTitle = titles[0]
            levelDescription = descriptions[0]
            
            mainScene.rootNode.enumerateChildNodes { child, stop in
                if let _ = Nodes(rawValue: child.name!) {
                    child.runAction(.repeatForever(.rotateBy(x: 0, y: -10, z: 0, duration: 15)))
                    nodeObjects.append(child)
                    if child.name == Nodes.ftm.rawValue {
                        selectedIndex = nodeObjects.count - 1
                    }
                }
            }
            
        }
        
        func distanceToNodeFromCamera(node: SCNNode) -> Float {
            let end = node.presentation.worldPosition
            let start = camera.presentation.worldPosition

            let dx = (end.x) - (start.x)
            let dy = (end.y) - (start.y)
            let dz = (end.z) - (start.z)

            return sqrt(pow(dx,2)+pow(dy,2)+pow(dz,2))
        }

        func createBlur(node: SCNNode) -> CIFilter {
            let gaussianBlur    = CIFilter(name: "CIGaussianBlur")
            gaussianBlur?.name  = "blur"
            let blurAmount = distanceToNodeFromCamera(node: node)
            gaussianBlur?.setValue(blurAmount, forKey: "inputRadius")
            return gaussianBlur!
        }
        
        func swipeLeftGesture() {
            let currentNode = nodeObjects[selectedIndex]
            
            selectedIndex += 1
            if selectedIndex > nodeObjects.count - 1 {
                selectedIndex = 0
            }
            
            genericSwipeGesture(currentNode: currentNode)
        }
        
        func swipeRightGesture() {
            let currentNode = nodeObjects[selectedIndex]
            
            selectedIndex -= 1
            if selectedIndex < 0 {
                selectedIndex = nodeObjects.count - 1
            }
            genericSwipeGesture(currentNode: currentNode)
        }
        
        private func genericSwipeGesture(currentNode: SCNNode) {
            let angle = angleBetween(nodeOne: currentNode, nodeTwo: nodeObjects[selectedIndex])
            
            mainScene.rootNode.childNode(withName: "pivot", recursively: true)!.runAction(.rotate(by: angle, around: .init(x: 0, y: 1, z: 0), duration: 0.3))
            
            camera.look(at: nodeObjects[selectedIndex].position)
            
            levelTitle = titles[selectedIndex]
            levelDescription = descriptions[selectedIndex]
        }
        
        func angleBetween(nodeOne: SCNNode, nodeTwo: SCNNode) -> CGFloat {
            let previousAngle = atan2f(Float(nodeOne.position.z - pivot.position.z),
                                       Float(nodeOne.position.x - pivot.position.x))
            
            //Calculate the angle from the center of the view to the current touch point.
            let currentAngle = atan2f(Float(nodeTwo.position.z - pivot.position.z),
                                      Float(nodeTwo.position.x - pivot.position.x))
            //Adjust the rotation by the change in angle.
            return CGFloat(currentAngle - previousAngle)
            
        }
    }
    
    static func makeScene(name: String) -> SCNScene? {
        return SCNScene(named: name)
    }
    
    static func setUpCamera() -> SCNNode? {
        let scene = SCNScene(named: "MainScene.scn")!
        let cameraNode = scene.rootNode
            .childNode(withName: "camera", recursively: true)

        return cameraNode
    }
    
    static func degreesToRadians(_ degrees: Float) -> CGFloat {
        return CGFloat(degrees * .pi / 180)
    }
}
