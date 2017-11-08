
import UIKit
import TouchDraw

class TrainViewController: UIViewController {
	@IBOutlet var touchDrawView: TouchDrawView!
	@IBOutlet var drawLabel: UILabel!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
	}
	
	@IBAction func clearButton(_ sender: Any) {
		touchDrawView.clearDrawing()
	}
	
	@IBAction func sendButton(_ sender: Any) {
	}
}


/*
Add

self.dsidPicker.delegate = self
self.dsidPicker.dataSource = self

to main class definition in viewDidLoad,

call

dsidPicker.reloadAllComponents()
*/

//extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//
//	func numberOfComponents(in pickerView: UIPickerView) -> Int {
//		return 1
//	}
//
//	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//		return dsids.count
//	}
//
//	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//		return "\(dsids[row])"
//	}
//
//	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//		self.dsid = dsids[row]
//	}
//}





