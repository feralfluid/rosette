//
//  ViewController.swift
//  rosette
//
//  Created by Ty Poorman on 4/29/22.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var onionPrevView: PKCanvasView!
    @IBOutlet weak var onionNextView: PKCanvasView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var prevFrameButton: UIBarButtonItem!
    @IBOutlet weak var nextFrameButton: UIBarButtonItem!
    @IBOutlet weak var firstFrameButton: UIBarButtonItem!
    @IBOutlet weak var lastFrameButton: UIBarButtonItem!
    @IBOutlet weak var insertFrameButton: UIBarButtonItem!
    @IBOutlet weak var duplicateFrameButton: UIBarButtonItem!
    @IBOutlet weak var deleteFrameButton: UIBarButtonItem!
    @IBOutlet weak var clearFrameButton: UIBarButtonItem!
    @IBOutlet weak var toggleFingerDrawingButton: UIBarButtonItem!
    @IBOutlet weak var toggleOnionButton: UIBarButtonItem!
    @IBOutlet weak var playPawsButton: UIBarButtonItem!
    
    private var toolPicker: PKToolPicker!
    private var frames = [Data()]
    private var currentFrame = 0 {
        didSet {
            // update navBar title
            navBar.title = String(format: "frame %d of %d", currentFrame + 1, frames.count)
            
            // if there is a previous frame
            if currentFrame > 0 {
                // show onionPrevView
                if onion {
                    onionPrevView.isHidden = false
                    onionPrevView.drawing = try! PKDrawing(data: frames[currentFrame - 1])
                }
            } else {
                // hide onionPrevView
                if onion {
                    onionPrevView.isHidden = true
                }
            }
            
            // if there is a next frame
            if currentFrame < frames.count - 1 {
                // show onionNextView
                if onion {
                    onionNextView.isHidden = false
                    onionNextView.drawing = try! PKDrawing(data: frames[currentFrame + 1])
                }
            } else {
                // hide onionNextView
                if onion {
                    onionNextView.isHidden = true
                }
            }
        }
    }
    private var fps = 10.0
    private var playing = false {
        didSet {
            if playing {
                // update the playPawsButton icon
                playPawsButton.image = UIImage(systemName: "pause.circle")
                
                // turn onion skinning off
                onion = false
            } else {
                // update the playPawsButton icon
                playPawsButton.image = UIImage(systemName: "play.circle")
            }
        }
    }
    private var animationTimer: Timer?
    private var onion = false {
        didSet {
            toggleOnionButton.image = onion ? UIImage(systemName: "circlebadge.2.fill") : UIImage(systemName: "circlebadge.2")
            
            // if there is a previous frame
            if onion && currentFrame > 0 {
                onionPrevView.isHidden = false
                onionPrevView.drawing = try! PKDrawing(data: frames[currentFrame - 1])
            } else {
                onionPrevView.isHidden = true
            }
            // if there is a next frame
            if onion && currentFrame < frames.count - 1 {
                onionNextView.isHidden = false
                onionNextView.drawing = try! PKDrawing(data: frames[currentFrame + 1])
            } else {
                onionNextView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        onionPrevView.delegate = self
        onionNextView.delegate = self
        canvasView.drawing = PKDrawing()
        
        canvasView.layer.borderWidth = 10
        canvasView.layer.borderColor = UIColor.white.cgColor
        
        toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        updateNavButtons()
    }
    
    private func updateNavButtons() {
        playPawsButton.isEnabled = true
        firstFrameButton.isEnabled = true
        lastFrameButton.isEnabled = true
        prevFrameButton.isEnabled = true
        nextFrameButton.isEnabled = true
        insertFrameButton.isEnabled = true
        duplicateFrameButton.isEnabled = true
        deleteFrameButton.isEnabled = true
        clearFrameButton.isEnabled = true
        toggleOnionButton.isEnabled = true
        toggleFingerDrawingButton.isEnabled = true
        
        if frames.count == 1 {
            playPawsButton.isEnabled = false
            deleteFrameButton.isEnabled = false
            toggleOnionButton.isEnabled = false
        }
        
        if currentFrame == 0 {
            firstFrameButton.isEnabled = false
            prevFrameButton.isEnabled = false
        }
        
        if currentFrame == frames.count - 1 {
            lastFrameButton.isEnabled = false
            nextFrameButton.isEnabled = false
        }
        
        if playing {
            firstFrameButton.isEnabled = false
            lastFrameButton.isEnabled = false
            prevFrameButton.isEnabled = false
            nextFrameButton.isEnabled = false
            insertFrameButton.isEnabled = false
            duplicateFrameButton.isEnabled = false
            deleteFrameButton.isEnabled = false
            clearFrameButton.isEnabled = false
            toggleOnionButton.isEnabled = false
            toggleFingerDrawingButton.isEnabled = false
        }
    }
    
    @IBAction func swipedRight(_ sender: Any) {
        if canvasView.drawingPolicy != .anyInput {
            if prevFrameButton.isEnabled {
                prevFrame(self)
            }
        }
    }
    
    @IBAction func swipedLeft(_ sender: Any) {
        if canvasView.drawingPolicy != .anyInput {
            if nextFrameButton.isEnabled {
                nextFrame(self)
            } else if currentFrame == frames.count - 1 {
                insertFrame(self)
            }
        }
    }
    
    @IBAction func doubleTapped(_ sender: Any) {
        playPaws(self)
    }
    
    @IBAction func nextFrame(_ sender: Any) {
        // save current frame.
        frames[currentFrame] = canvasView.drawing.dataRepresentation()
        
        currentFrame = currentFrame == frames.count - 1 ? 0 : currentFrame + 1
        
        canvasView.drawing = try! PKDrawing(data: frames[currentFrame])
        
        updateNavButtons()
    }
    
    @IBAction func prevFrame(_ sender: Any) {
        // save current frame.
        frames[currentFrame] = canvasView.drawing.dataRepresentation()
        
        currentFrame -= 1

        canvasView.drawing = try! PKDrawing(data: frames[currentFrame])
        
        updateNavButtons()
    }
    
    @IBAction func firstFrame(_ sender: Any) {
        // save current frame.
        frames[currentFrame] = canvasView.drawing.dataRepresentation()
        
        currentFrame = 0
        
        canvasView.drawing = try! PKDrawing(data: frames[currentFrame])
        
        updateNavButtons()
    }
    
    @IBAction func lastFrame(_ sender: Any) {
        // save current frame.
        frames[currentFrame] = canvasView.drawing.dataRepresentation()
        
        currentFrame = frames.count - 1
        
        canvasView.drawing = try! PKDrawing(data: frames[currentFrame])
        
        updateNavButtons()
    }
    
    @IBAction func playPaws(_ sender: Any) {
        playing = !playing
        
        if playing {
            animationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0 / fps), repeats: true) { _ in
                self.nextFrame(self)
            }
        } else {
            animationTimer?.invalidate()
        }
        
        updateNavButtons()
    }
    
    @IBAction func insertFrame(_ sender: Any) {
        // save the current frame before moving forward.
        frames[currentFrame] = canvasView.drawing.dataRepresentation()
        
        frames.insert(Data(), at: currentFrame + 1)
        currentFrame += 1
        
        // initialize a drawing for the new frame.
        canvasView.drawing = PKDrawing()
        
        updateNavButtons()
    }
    
    @IBAction func duplcateFrame(_ sender: Any) {
        // save the current frame before moving forward.
        frames[currentFrame] = canvasView.drawing.dataRepresentation()
        
        frames.insert(Data(frames[currentFrame]), at: currentFrame + 1)
        currentFrame += 1
        
        canvasView.drawing = try! PKDrawing(data: frames[currentFrame])
        
        updateNavButtons()
    }
    
    @IBAction func deleteFrame(_ sender: Any) {
        frames.remove(at: currentFrame)
        
        currentFrame = currentFrame == 0 ? currentFrame : currentFrame - 1
        canvasView.drawing = try! PKDrawing(data: frames[currentFrame])
        
        updateNavButtons()
    }
    
    @IBAction func clearFrame(_ sender: Any) {
        frames[currentFrame] = Data()
        
        canvasView.drawing = PKDrawing()
    }
    
    @IBAction func toggleOnion(_ sender: Any) {
        onion = !onion
    }
    
    @IBAction func toggleFingerDrawing(_ sender: Any) {
        canvasView.drawingPolicy = canvasView.drawingPolicy == .default ? .anyInput : .default
        
        if canvasView.drawingPolicy == .anyInput {
            toggleFingerDrawingButton.tintColor = .green
        } else {
            toggleFingerDrawingButton.tintColor = .red
        }
    }
}
