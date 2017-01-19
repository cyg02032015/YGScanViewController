# YGScanViewController
## Requrements

* iOS 8.0+ 
* Xcode 8.0 or later

### Use
``` swift
	let scanVC = ScanViewController()  
	navigationController?.pushViewController(scanVC, animated: true)
```
In ScanViewController, In the function judgment your logic

```
    func showScanCode(code: String) {
        //TODO: ===========   判断二维码码号   ===========
        session.stopRunning()
        label.text = code
        GGDelay.gg_delay(3) {
            self.session.startRunning()
        }
    }
```
