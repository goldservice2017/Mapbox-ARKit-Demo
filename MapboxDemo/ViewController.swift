import UIKit
import Mapbox
import SceneKit
import ARKit

/*
 A simple example that uses the Mapbox Outdoors style to view
 Yosemite National Park, USA with a polygon visualization of the
 park boundary that can be interacted with.
 
 A demo access token has been provided for convenience and it may
 stop working in the future.
 
 You can obtain your own access token from the
 [Mapbox account page](https://www.mapbox.com/studio/account/tokens/)
 and add it to this application's Info.plist as the value for
 MGLMapboxAccessToken
 */
class ViewController: UIViewController {

    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    
    var mapView: MGLMapView!
    var sceneView: SCNView!
    var nodeModel:SCNNode!
    let nodeName = "cherub"
    
    // Define a name for our annotation
    let annotationIdentifier = "yosemite-fill-layer"
    
    // Define the name of the map label layer we will want our annotation to be placed under
    let styleLabelLayer = "mountain-peak-label"
    
    // The initial center geometric coordinate for the map to display - this is Yosemite National Park, USA
    let centerCoordinate = CLLocationCoordinate2DMake(37.742241, -119.576923)
    
    // MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupAnnotationContextView()
        setupAndAddMapView()
        setupGestureHandling()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAndAddSCNView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
//        sceneView.session.pause()
    }
    // MARK: - Map object interaction
    
    @objc func didTapMap(sender: UITapGestureRecognizer) {
        sceneView.alpha = 1
        btnCancel.alpha = 1
        
        for child in (sceneView.scene?.rootNode.childNodes)! {
            child.removeFromParentNode()
        }
        let location = sender.location(in: mapView)
        let vector3 = getDirection(for: location, in: sceneView)

        let boy = nodeModel.clone() as SCNNode
        boy.position = vector3
        let scaleFactor = abs(vector3.z / 1000)
        boy.scale = SCNVector3Make(scaleFactor * 5, scaleFactor * 5, scaleFactor * 5)
//        boy.rotation = SCNVector4Make(0, 0, 0, Float(Double.pi / 2))
        sceneView.scene?.rootNode.addChildNode(boy)
    }
    func getDirection(for point: CGPoint, in view: SCNView) -> SCNVector3 {
        let farPoint  = view.unprojectPoint(SCNVector3Make(Float(point.x), Float(point.y), 1))
        let nearPoint = view.unprojectPoint(SCNVector3Make(Float(point.x), Float(point.y), 0))
        
        return SCNVector3Make(farPoint.x - nearPoint.x, farPoint.y - nearPoint.y, farPoint.z - nearPoint.z)
    }
    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == nodeName {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }
    @IBAction func closeARView(_ sender: Any) {
        sceneView.alpha = 0
        btnCancel.alpha = 0
    }
    // MARK: - Initialization and setup
    
    /*
     Simple (but somewhat styled) stub of a view to present
     contextual information about tapped objects on the map.
     */
//    fileprivate func setupAnnotationContextView() {
//        annotationContextView.alpha = 0
//        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurView.frame = annotationContextView.bounds
//        blurView.layer.cornerRadius = 5
//        blurView.clipsToBounds = true
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//        annotationContextView.insertSubview(blurView, at: 0)
//        blurView.topAnchor.constraint(equalTo: annotationContextView.topAnchor).isActive = true
//        blurView.leftAnchor.constraint(equalTo: annotationContextView.leftAnchor).isActive = true
//        blurView.rightAnchor.constraint(equalTo: annotationContextView.rightAnchor).isActive = true
//        blurView.bottomAnchor.constraint(equalTo: annotationContextView.bottomAnchor).isActive = true
//    }
    
    /*
     Create and add a ARSCNView to the the view
     intended to contain it. Setup with the style, initial
     location in the world, and make this object the delegate
     of the map. Finally, set up a camera to control how the
     user will view the map initially.
     */
    fileprivate func setupAndAddSCNView() {
        
        sceneView = SCNView(frame: mapViewContainer.bounds)
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.clear
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        sceneView.alpha = 0
        btnCancel.alpha = 0
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: -30, y: 0, z: 100)
        cameraNode.camera?.automaticallyAdjustsZRange = true
                
        mapViewContainer.addSubview(sceneView)
        
        let modelScene = SCNScene(named:
            "art.scnassets/cherub/cherub.dae")!
        
        nodeModel =  modelScene.rootNode.childNode(withName: nodeName, recursively: true)
        nodeModel.scale = SCNVector3Make(100.0, 100.0, 100.0)
    }
    
    /*
     Create and add a Mapbox map view to the the view
     intended to contain it. Setup with the style, initial
     location in the world, and make this object the delegate
     of the map. Finally, set up a camera to control how the
     user will view the map initially.
     */
    fileprivate func setupAndAddMapView() {
        mapView = MGLMapView(frame: mapViewContainer.bounds)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mapView.styleURL = MGLStyle.outdoorsStyleURL(withVersion: 10)
        mapView.setCenter(centerCoordinate, zoomLevel: 10, animated: false)
        mapView.delegate = self
        mapViewContainer.addSubview(mapView)
        
//        accessTokenWarningView.layer.cornerRadius = 5
//        accessTokenWarningView.isHidden = true
        
        // This demo access token has been provided for convenience and it may
        // stop working in the future.
        // You can obtain your own access token from the
        // [Mapbox account page](https://www.mapbox.com/studio/account/tokens/)
        // and add it to this application's Info.plist as the value for MGLMapboxAccessToken
        if MGLAccountManager.accessToken() == "pk.eyJ1IjoibWFwYm94IiwiYSI6ImNqYThuNnZ3NTA5MGMyd3F1cmF1eW1xaGEifQ.TdBTSHHPeT1pfLZ_6x_1vA" {
//            accessTokenWarningView.isHidden = false
        }
        
        let camera = MGLMapCamera(lookingAtCenter: centerCoordinate, fromDistance: 100000, pitch: 60, heading: 0)
        mapView.setCamera(camera, animated: false)
    }
    
    /*
     Add a gesture recognizer that will be used to handle user
     interactions with the map.
     */
    fileprivate func setupGestureHandling() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
}
/*
 Implementation of ARSCNView delegate methods relevant to this application
 */
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone = self.nodeModel.clone()
                modelClone.position = SCNVector3Zero
                
                // Add model as a child of the node
                node.addChildNode(modelClone)
            }
        }
    }
}
/*
 Implementation of Mapbox map view delegate methods relevant to this application
 */
extension ViewController: MGLMapViewDelegate {
    
    /*
     When the map has finished loading the style it's a great time
     to do work like adding annotations.
     */
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        // This project's bundle contains a geojson file that represents the park boundary of Yosemite National Park in the USA
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "yose", ofType: "geojson")!)
        
        // Create an instance of a structure to represent a polygon
        // fill visualization that can be injeced into the map's style layers
        var annotation = StyledAnnotation(identifier: annotationIdentifier, resource: url, type: .extrusion)
        annotation.color = UIColor(red:1.00, green:0.95, blue:0.75, alpha:1.0)
        annotation.opacity = 0.75
        annotation.transitionDuration = 0.35
        
        // Inject the annotation below the label layer so some map labels
        // are still visible
        mapView.addStyledAnnotation(annotation, belowLayer: styleLabelLayer)
        
        // Alternatively, a more traditional annotation / marker API
        let pointFeatureAnnotation = MGLPointFeature()
        let offsetCoordinate = CLLocationCoordinate2D(latitude: centerCoordinate.latitude+0.1, longitude: centerCoordinate.longitude-0.01)
        pointFeatureAnnotation.coordinate = offsetCoordinate
        mapView.addAnnotation(pointFeatureAnnotation)
    }
    
}

/*
 An extention of the Mapbox map view class that offers a simplified
 API for a small subset of the runtime styling APIs used in this application.
 This could be extended.
 */
extension MGLMapView {
    
    func addStyledAnnotation(_ annotation: StyledAnnotation, belowLayer layerName: String) {
        if let labelsLayer = self.style?.layer(withIdentifier: "mountain-peak-label") {
            let source = addSource(for: annotation)
            let layer = addLayer(for: annotation, source: source)
            self.style?.insertLayer(layer, below: labelsLayer)
        }
    }
    
    func addStyledAnnotation(_ annotation: StyledAnnotation) {
        let source = addSource(for: annotation)
        let layer = addLayer(for: annotation, source: source)
        self.style?.addLayer(layer)
    }
    
    func addSource(for styledAnnotation: StyledAnnotation) -> MGLSource {
        let source = MGLShapeSource(identifier: UUID().uuidString, url: styledAnnotation.resource, options: nil)
        self.style?.addSource(source)
        return source
    }
    
    func addLayer(for styledAnnotation: StyledAnnotation, source: MGLSource) -> MGLStyleLayer {
        switch styledAnnotation.type {
        case .extrusion:
            let layer = MGLFillExtrusionStyleLayer(identifier: styledAnnotation.identifier, source: source)
            if let height = styledAnnotation.height {
                layer.fillExtrusionHeight = MGLStyleValue<NSNumber>(rawValue: NSNumber(floatLiteral: Double(height)))
            }
            if let color = styledAnnotation.color {
                layer.fillExtrusionColor = MGLStyleValue(rawValue: color)
            }
            if let opacity = styledAnnotation.opacity {
                layer.fillExtrusionOpacity = MGLStyleValue<NSNumber>(rawValue: NSNumber(floatLiteral: Double(opacity)))
            }
            if let duration = styledAnnotation.transitionDuration {
                layer.fillExtrusionHeightTransition = MGLTransitionMake(Double(duration), 0)
                layer.fillExtrusionOpacityTransition = MGLTransitionMake(Double(duration), 0)
            }
            return layer
        }
    }
    
}

/*
 A struct to represent a small subset of the annotations that
 are possible to add to a Mapbox map. This could be extended.
 */
struct StyledAnnotation {
    
    enum StyledAnnotationType {
        case extrusion
    }
    
    init(identifier: String, resource: URL, type: StyledAnnotationType) {
        self.identifier = identifier
        self.resource = resource
        self.type = type
    }
    
    var identifier: String
    var resource: URL
    var type: StyledAnnotationType
    
    var height: Float?
    var color: UIColor?
    var opacity: Float?
    var transitionDuration: Float?
    
}
