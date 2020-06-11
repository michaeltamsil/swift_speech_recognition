//
//  ViewController.swift
//  Speech Recognition
//
//  Created by michael tamsil on 11/06/20.
//  Copyright © 2020 michael tamsil. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var view_color: UIView!
    @IBOutlet weak var lb_search: UILabel!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task : SFSpeechRecognitionTask!
    var isStart : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_color.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        requestPermission()
    }

    @IBAction func btn_start_stop(_ sender: Any) {
        isStart = !isStart
        if isStart {
            startSpeechRecognization()
            btnStart.setTitle("STOP", for: .normal)
            btnStart.backgroundColor = .systemGreen
            
        } else {
            cancelSpeechRecognization()
            btnStart.setTitle("START", for: .normal)
            btnStart.backgroundColor = .systemOrange
        }
    }
    
    func alertView(message: String){
        let controller = UIAlertController.init(title: "Error occured...!", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in controller.dismiss(animated: true, completion: nil)}))
        self.present(controller, animated: true, completion: nil)
    }
    
    func requestPermission(){
        self.btnStart.isEnabled = false
        SFSpeechRecognizer.requestAuthorization{(authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("ACCEPTED")
                    self.btnStart.isEnabled = true
                } else if authState == .denied{
                    self.alertView(message: "User denied the permission")
                    
                }else if authState == .notDetermined {
                    self.alertView(message: "In User phone there is no speech recognition")
                }else if authState == .restricted {
                    self.alertView(message: "User has been restricted for using the speech recognition")
                }
            }
        }
    }
    
    func startSpeechRecognization(){
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in self.request.append(buffer) }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            alertView(message: "Error comes here for starting the audio listener = \(error.localizedDescription)")
        }
        
        guard let myRecognization = SFSpeechRecognizer() else {
            self.alertView(message: "Recognization is not allow on your local")
            return
        }
        
        if !myRecognization.isAvailable {
            self.alertView(message: "Recognization is free right now, please try again after some time.")
        }
        
        task = speechRecognizer?.recognitionTask(with: request, resultHandler: {
            (response, error) in
            guard let response = response else {
                if error != nil {
                    self.alertView(message: error.debugDescription)
                } else {
                    self.alertView(message: "Problem is giving the response")
                }
                return
            }
            let message = response.bestTranscription.formattedString
            print("Message: \(message)")
            self.lb_search.text = message
            
            var lastString: String = ""
            for segment in response.bestTranscription.segments {
                let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                lastString = String(message[indexTo...])
            }
            
            if lastString == "red" {
                self.view_color.backgroundColor = .systemRed
            } else if lastString.elementsEqual("green") {
                self.view_color.backgroundColor = .systemGreen
            } else if lastString.elementsEqual("pink") {
                self.view_color.backgroundColor = .systemPink
            } else if lastString.elementsEqual("blue") {
                self.view_color.backgroundColor = .systemBlue
            }
            
        })
    }
    
    func cancelSpeechRecognization(){
        task.finish()
        task.cancel()
        task = nil
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    
}

