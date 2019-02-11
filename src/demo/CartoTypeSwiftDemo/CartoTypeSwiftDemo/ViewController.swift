//
//  ViewController.swift
//  CartoTypeSwiftDemo
//
//  Created by Graham Asher on 20/11/2016.
//  Copyright © 2016-2018 CartoType Ltd. All rights reserved.
//

import UIKit
import GLKit
import CoreLocation

class ViewController: GLKViewController, UIGestureRecognizerDelegate, UISearchBarDelegate, CLLocationManagerDelegate
{
    var m_framework: CartoTypeFramework!
    var m_ui_scale: CGFloat = UIScreen.main.scale
    var m_route_start = CartoTypePoint(x:0, y:0)
    var m_route_end = CartoTypePoint(x:0, y:0)
    var m_last_point_pressed = CartoTypePoint(x:0, y:0)
    var m_search_bar: UISearchBar!
    var m_route_instructions: UILabel!
    var m_navigate_button: UIButton!
    var m_pushpin_id: UInt64 = 0
    var m_navigating: Bool = false
    var m_location_manager: CLLocationManager!
    var m_location: CLLocation!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(framework aFrameWork: CartoTypeFramework!)
    {
        super.init(nibName: nil,bundle: nil)
        m_framework = aFrameWork
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.becomeFirstResponder()
        m_ui_scale = UIScreen.main.scale
        view.isMultipleTouchEnabled = true
        
        // Create a pan gesture recognizer.
        let my_pan_recognizer = UIPanGestureRecognizer(target: self,action: #selector(ViewController.handlePanGesture(_:)))
        my_pan_recognizer.delegate = self
        view.addGestureRecognizer(my_pan_recognizer)
        
        // Create a pinch gesture recognizer.
        let my_pinch_recognizer = UIPinchGestureRecognizer(target: self,action: #selector(ViewController.handlePinchGesture(_:)))
        my_pinch_recognizer.delegate = self
        view.addGestureRecognizer(my_pinch_recognizer)
        
        // Create a rotation gesture recognizer.
        let my_rotation_recognizer = UIRotationGestureRecognizer(target: self,action: #selector(ViewController.handleRotationGesture(_:)))
        my_rotation_recognizer.delegate = self
        view.addGestureRecognizer(my_rotation_recognizer)
        
        // Create a tap gesture recognizer.
        let my_tap_recognizer = UITapGestureRecognizer(target: self,action: #selector(ViewController.handleTapGesture(_:)))
        my_tap_recognizer.delegate = self
        view.addGestureRecognizer(my_tap_recognizer)
        
        // Create a long-press gesture recognizer.
        let my_long_press_recognizer = UILongPressGestureRecognizer(target: self,action: #selector(ViewController.handleLongPressGesture(_:)))
        my_long_press_recognizer.delegate = self
        view.addGestureRecognizer(my_long_press_recognizer)
        
        // Create a search bar.
        m_search_bar = UISearchBar.init()
        m_search_bar.delegate = self
        m_search_bar.frame = CGRect(x:0,y:0,width:300,height:40)
        m_search_bar.layer.position = CGPoint(x: view.bounds.size.width / 2,y:40)
        
        // Show cancel button.
        m_search_bar.showsCancelButton = true
        
        // Set placeholder
        m_search_bar.placeholder = "place name"
        
        // Add the search bar to the view.
        view.addSubview(m_search_bar!)
        
        // Create a label for the route instructions.
        m_route_instructions = UILabel.init()
        m_route_instructions.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        m_route_instructions.layer.position = CGPoint(x: view.bounds.size.width / 2, y: 40)
        m_route_instructions.backgroundColor = UIColor.white
        m_route_instructions.text = "route instructions"
        m_route_instructions.isHidden = true
        view.addSubview(m_route_instructions!)
        
        // Create a button to start and stop navigating.
        m_navigate_button = UIButton.init()
        m_navigate_button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        m_navigate_button.layer.position = CGPoint(x:view.bounds.size.width / 2,y:view.bounds.size.height - 30)
        m_navigate_button.setTitleColor(UIColor.red, for: UIControlState.normal)
        m_navigate_button.backgroundColor = UIColor.white
        m_navigate_button.setTitle("Start", for: UIControlState.normal)
        m_navigate_button.addTarget(self, action: #selector(startOrEndNavigation), for: UIControlEvents.touchUpInside)
        m_navigate_button.isHidden = true
        view.addSubview(m_navigate_button!)

        // Set up location services.
        m_location_manager = CLLocationManager.init()
        m_location_manager.delegate = self
        m_location_manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways &&
            CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse)
            {
            m_location_manager.requestWhenInUseAuthorization()
            }
        
        // Set the vehicle location to a quarter of the way up the display.
        m_framework.setVehiclePosOffsetX(0, andY: 0.25)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)->Bool
    {
        return true
    }
    
    func handlePanGesture(_ aRecognizer:UIPanGestureRecognizer)
    {
        if (aRecognizer.state == UIGestureRecognizerState.changed)
        {
            let t = aRecognizer.translation(in: nil)
            m_framework.panX(Int32(-t.x * m_ui_scale), andY: Int32(-t.y * m_ui_scale))
            aRecognizer.setTranslation(CGPoint.zero, in: nil)
        }
        else if (aRecognizer.state == UIGestureRecognizerState.recognized)
        {
        }
        else if (aRecognizer.state == UIGestureRecognizerState.cancelled)
        {
        }
    }
    
    func handlePinchGesture(_ aRecognizer:UIPinchGestureRecognizer)
    {
        if (aRecognizer.state == UIGestureRecognizerState.changed)
        {
            let p = aRecognizer.location(in: nil)
            m_framework.zoom(at: Double(aRecognizer.scale), x: Double(p.x * m_ui_scale), y: Double(p.y * m_ui_scale), coordType: DisplayCoordType)
            aRecognizer.scale = 1
        }
        else if (aRecognizer.state == UIGestureRecognizerState.recognized)
        {
        }
        else if (aRecognizer.state == UIGestureRecognizerState.cancelled)
        {
        }
    }
    
    func handleRotationGesture(_ aRecognizer:UIRotationGestureRecognizer)
    {
        if (aRecognizer.state == UIGestureRecognizerState.changed)
        {
            m_framework.rotate(Double(aRecognizer.rotation) / Double.pi * 180)
            aRecognizer.rotation = 0
        }
        else if (aRecognizer.state == UIGestureRecognizerState.recognized)
        {
        }
        else if (aRecognizer.state == UIGestureRecognizerState.cancelled)
        {
        }
    }
    
    func handleTapGesture(_ aRecognizer:UITapGestureRecognizer)
    {
        if (aRecognizer.state == UIGestureRecognizerState.recognized)
        {
        }
    }
    
    func handleLongPressGesture(_ aRecognizer:UILongPressGestureRecognizer)
        {
        if (aRecognizer.state == UIGestureRecognizerState.recognized)
            {
            let p = aRecognizer.location(in: nil)
            m_last_point_pressed.x = Double(p.x * m_ui_scale)
            m_last_point_pressed.y = Double(p.y * m_ui_scale)
            let pp : CartoTypePoint = m_last_point_pressed
            m_framework.convert(&m_last_point_pressed, from: DisplayCoordType, to: MapCoordType)
            
            // Find nearby objects.
            let object_array = NSMutableArray.init()
            let pixel_mm = m_framework.getResolutionDpi() / 25.4
            m_framework.find(inDisplay: object_array, maxItems: 10, point: pp, radius: ceil(2 * pixel_mm))
            
            // See if we have a pushpin.
            m_pushpin_id = 0
            for (cur_object) in object_array
                {
                if ((cur_object as! CartoTypeMapObject).getLayerName().isEqual("pushpin"))
                    {
                    m_pushpin_id = (cur_object as! CartoTypeMapObject).getId()
                    break
                    }
                }
                
            // Create the menu.
            let menu = UIMenuController.shared
            var pushpin_menu_item : UIMenuItem?
            if (m_pushpin_id != 0)
                {
                pushpin_menu_item = UIMenuItem.init(title: "Delete pin", action: #selector(deletePushPin))
                }
            else
                {
                pushpin_menu_item = UIMenuItem.init(title: "Insert pin", action: #selector(insertPushPin))
                }
            menu.menuItems = [
                             pushpin_menu_item!,
                             UIMenuItem.init(title: "Start here", action: #selector(ViewController.setRouteStart)),
                             UIMenuItem.init(title: "End here", action: #selector(ViewController.setRouteEnd)),
                             ]
            menu.setTargetRect(CGRect(x:p.x,y:p.y,width:1,height:1), in: view)
            menu.setMenuVisible(true, animated: true)
            }
        }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    func setRouteStart()
        {
        m_route_start = m_last_point_pressed
        if (m_route_end.x != 0 && m_route_end.y != 0)
            {
            m_navigate_button.isHidden = false
            m_framework.startNavigation(from: m_route_start, start: MapCoordType, to: m_route_end, end: MapCoordType)
            }
        }
    
    func setRouteEnd()
        {
        m_route_end = m_last_point_pressed
        if (m_route_end.x != 0 && m_route_end.y != 0)
            {
            m_framework.startNavigation(from: m_route_start, start: MapCoordType, to: m_route_end, end: MapCoordType)
            }
        m_navigate_button.isHidden = false
        }
    
    func insertPushPin()
        {
        let a : CartoTypeAddress = CartoTypeAddress.init()
        m_framework.getAddress(a, point: m_last_point_pressed, coordType: MapCoordType)
        let p : CartoTypeMapObjectParam = CartoTypeMapObjectParam.init(type: PointMapObjectType, andLayer: "pushpin", andCoordType: MapCoordType)
        p.appendX(m_last_point_pressed.x, andY: m_last_point_pressed.y)
        p.mapHandle = 0
        p.stringAttrib = a.toString(false)
        m_framework.insertMapObject(p)
        m_pushpin_id = p.objectId
        }
    
    func deletePushPin()
        {
        m_framework.deleteObjects(fromMap: 0, fromID: m_pushpin_id, toID: m_pushpin_id, withCondition: nil, andCount: nil)
        m_pushpin_id = 0
        }
    
    func startOrEndNavigation()
        {
        if (!m_navigating)
            {
            m_location_manager.startUpdatingLocation()
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Try to get start of route if not known.
            if (m_framework.getRouteCount() == 0)
                {
                if (m_location != nil)
                    {
                    m_route_start.x = m_location.coordinate.longitude
                    m_route_start.y = m_location.coordinate.latitude
                    m_framework.convert(&m_route_start, from: DegreeCoordType, to: MapCoordType)
                    m_framework.startNavigation(from: m_route_start, start: MapCoordType, to: m_route_end, end: MapCoordType)
                    }
                }
            
            if (m_framework.getRouteCount() != 0)
                {
                m_navigate_button.setTitle("End", for: UIControlState.normal)
                m_search_bar.isHidden = true
                m_route_instructions.isHidden = false
                m_navigating = true
                }
            
            }
        else
            {
            m_navigate_button.setTitle("Start", for: UIControlState.normal)
            m_search_bar.isHidden = false
            m_route_instructions.isHidden = true
            m_navigating = false
            m_route_start.x = 0; m_route_start.y = 0
            m_route_end.x = 0; m_route_end.y = 0
            m_framework.deleteRoutes()
            m_navigate_button.isHidden = true
            }
        
        if (!m_navigating)
            {
            m_location_manager.stopUpdatingLocation()
            UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        
    
    func searchBar(_ searchBar: UISearchBar, textDidChange aSearchText: String)
    {
    }

    func searchBarCancelButtonClicked(_ aSearchBar: UISearchBar)
    {
    view.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ aSearchBar: UISearchBar)
    {
    view.endEditing(true)
    let text = aSearchBar.text
    if (text != nil)
        {
        let found : NSMutableArray = NSMutableArray.init()
        let param : CartoTypeFindParam = CartoTypeFindParam.init()
        param.text = text
        m_framework.find(found, with: param)
        if (found.count > 0)
            {
            let object : CartoTypeMapObject = found.firstObject as! CartoTypeMapObject
            m_framework.setViewObject(object, margin: 16, minScale: 10000)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
        let alert_controller = UIAlertController.init(title: "Error", message: "could not get your location", preferredStyle: UIAlertControllerStyle.alert)
        present(alert_controller, animated: true, completion: nil)
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations aLocations: [CLLocation])
        {
        let new_location = aLocations.last
        if (new_location == nil)
            {
            return
            }
        m_location = new_location!
        if (m_navigating)
            {
            var nav_data = CartoTypeNavigationData.init(validity: KTimeValid, time: m_location.timestamp.timeIntervalSinceReferenceDate, longitude: 0, latitude: 0, speed: 0, course: 0, height: 0)
            if (m_location.horizontalAccuracy > 0 && m_location.horizontalAccuracy <= 100)
                {
                nav_data.validity |= KPositionValid
                nav_data.latitude = m_location.coordinate.latitude
                nav_data.longitude = m_location.coordinate.longitude
                }
            if (m_location.course >= 0)
                {
                nav_data.validity |= KCourseValid
                nav_data.course = m_location.course
                }
            if (m_location.speed >= 0)
                {
                nav_data.validity |= KSpeedValid
                nav_data.speed = m_location.speed * 3.6 // convert from metres per second to kilometres per hour
                }
            if (m_location.verticalAccuracy >= 0 && m_location.verticalAccuracy <= 100)
                {
                nav_data.validity |= KHeightValid
                nav_data.height = m_location.altitude
                }
            m_framework.navigate(&nav_data)
            let first_turn = CartoTypeTurn.init()
            m_framework.getFirstTurn(first_turn)
            m_route_instructions.text = first_turn.instructions
            }
        }
    
}
