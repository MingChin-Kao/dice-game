import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var socketConnector:SocketDataManager!
    @IBOutlet weak var ipAddressField: UITextField!
    @IBOutlet weak var portField: UITextField!
    @IBOutlet weak var messageHistoryView: UITextView!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabl: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var rollButtonPress: UIButton!
    @IBOutlet weak var diceImageView1: UIImageView!
    @IBOutlet weak var diceImageView2: UIImageView!
    @IBOutlet weak var diceGif1: UIImageView!
    @IBOutlet weak var diceGif2: UIImageView!
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var disContBtn: UIButton!
    
    
    
    let diceArray=["dice1","dice2","dice3","dice4","dice5","dice6"]
    var randomDiceIndex1:Int = 0
    var randomDiceIndex2:Int = 0
    
    
    //test_label
    @IBOutlet weak var tesst: UILabel!
    
    
    var audioPlayer:AVAudioPlayer!
    var audioPlayer2:AVAudioPlayer!
    
    var final_choose:Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //label換行
        labelResult.lineBreakMode = NSLineBreakMode.byWordWrapping
        labelResult.numberOfLines = 0
        
        socketConnector = SocketDataManager(with: self)
        resetUIWithConnection(status: false)
        // Do any additional setup after loading the view, typically from a nib.
        
        diceGif1.loadGif(name: "diceGif2")
        diceGif2.loadGif(name: "diceGif2")
        
        diceImageView1.isHidden = false
        diceImageView2.isHidden = false
        
        rollButtonPress.isEnabled = false
        rollButtonPress.isHidden = true
        disContBtn.isEnabled = false
        myLabel.isHidden = true
        
        
        do{
            let filePath = Bundle.main.path(forResource: "dice",ofType:"mp3")
            audioPlayer = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: filePath!) as URL)
            
            let filePath2 = Bundle.main.path(forResource: "end",ofType:"mp3")
            audioPlayer2 = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: filePath2!) as URL)
            
            
        }catch{
            print("error")
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer2.prepareToPlay()
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func mySegmentAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            final_choose = 1   //若user選擇左邊的，數值為1,大
        }
        else{
            final_choose = 0   //若user選擇右邊的，數值為0,小
        }
    }
    
    
    //查看結果的button
    @IBAction func play(_ sender: Any) {
        
        tesst.isHidden = false
        labelResult.isHidden = false
        
        audioPlayer2.play()
        
        let a = myLabel.text
        let num = (a! as NSString).integerValue
        print(num)
        
        if(num > 6){
            let number = Int.random(in: (num - 6)...6)
            randomDiceIndex1 = number
            randomDiceIndex2 = num - number
            print("diec1 = \(randomDiceIndex1),dice2 = \(randomDiceIndex2)")
        }else if(num == 1){
            randomDiceIndex1 = 1
            randomDiceIndex2 = 1
            print("diec1 = \(randomDiceIndex1),dice2 = \(randomDiceIndex2)")
        }else{
            let number = Int.random(in: 1...(num - 1))
            randomDiceIndex1 = number
            randomDiceIndex2 = num - number
            print("diec1 = \(randomDiceIndex1),dice2 = \(randomDiceIndex2)")
        }
        
        diceGif1.isHidden = false
        diceGif2.isHidden = false
        
        diceImageView1.isHidden = false
        diceImageView2.isHidden = false
        
        diceImageView1.image=UIImage(named:diceArray[randomDiceIndex1-1])
        diceImageView2.image=UIImage(named:diceArray[randomDiceIndex2-1])
        
        let total = randomDiceIndex1 + randomDiceIndex2
        
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
        
        //判斷輸贏
        if(Int(final_choose) == 1 && total > 6){
            tesst.text = "You Win!"
            labelResult.text = "Your choose : 大\n總骰子數 : \(total)"
        }
        else if(Int(final_choose) == 1 && total <= 6){
            tesst.text = "You Lose!"
            labelResult.text = "Your choose : 大\n總骰子數 : \(total)"
        }
        else if(Int(final_choose) == 0 && total > 6){
            tesst.text = "You Lose!"
            labelResult.text = "Your choose : 小\n總骰子數 : \(total)"
        }
        else{
            tesst.text = "You Win!"
            labelResult.text = "Your choose : 小\n總骰子數 : \(total)"
        }
        
        sendBtn.isEnabled = true
        sendBtn.isHidden = false
        rollButtonPress.isEnabled = false   //此為查“查看結果”button
        rollButtonPress.isHidden = true
    
    }
    
    @IBAction func connect(){
        //http://localhost:50694/
        guard let ipAddr = ipAddressField.text, let portVal = portField.text  else {
            return
        }
        let soc = DataSocket(ip: ipAddr, port: portVal)
        socketConnector.connectWith(socket: soc)
        disContBtn.isEnabled = true
        
    }
    
    
    
    @IBAction func send(){
        
        audioPlayer.play()
        
        tesst.isHidden = true
        labelResult.isHidden = true

        
        // guard let msg = messageField.text else {
        //     return
        // }
        let msg = "b"   //不用輸入即可收到回傳值
        send(message: msg)
        //messageField.text = ""
        rollButtonPress.isEnabled = true
        rollButtonPress.isHidden = false
        sendBtn.isHidden = true
        
    }
    
    func send(message: String){
        //使用者輸入什麼字母
        socketConnector.send(message: message)
        
        update(message: "me:\(message)")
        
    }
    
    @IBAction func disConnect(_ sender: Any) {
        viewDidLoad()
        disContBtn.isEnabled = false
    }
    
    
    
    
    
}

extension ViewController: PresenterProtocol{
    
    func resetUIWithConnection(status: Bool){
        
        ipAddressField.isEnabled = !status
        portField.isEnabled = !status
        connectBtn.isEnabled = !status
        sendBtn.isEnabled = status
        
        if (status){
            updateStatusViewWith(status: "Connected")
        }else{
            updateStatusViewWith(status: "Disconnected")
        }
    }
    func updateStatusViewWith(status: String){
        
        statusLabl.text = status
        
    }
    
    
    //擲骰子的button
    func update(message: String){
        
        myLabel.text=message
        
        //tesst.text = message
        
        diceImageView1.isHidden = true
        diceImageView2.isHidden = true
        
        sendBtn.isEnabled = false
        rollButtonPress.isEnabled = true
        
        /*
         //將Server傳回來的值用成字串
         let test3 = String(message.prefix(14))
         
         
         //從server回傳的數值,型態是string
         let index1 = test3.index(test3.endIndex, offsetBy: -2)
         let numFromServer = String(test3.suffix(from: index1))
         
         //取得的數值
         tesst.text = numFromServer
         
         let a = Int(numFromServer)
         
         var number = Int.random(in: 1...6)
         
         print("radom number is\(number) & a is \(String(describing: tesst.text))")
         
         /*
         while(a ?? 1 < number){
         print("a is = \(a)")
         number = number - 1
         }*/
         
         //print("number is = \(number)")
         
         randomDiceIndex1 = a ?? 1
         randomDiceIndex2 = a ?? 1 - number
         
         //print("dice 1 = \(randomDiceIndex1)")
         //print("dice 2 = \(randomDiceIndex2)")
         
         */
        
        
        if let text = messageHistoryView.text{
            
            let newText = """
            \(text)
            \(message)
            """
            messageHistoryView.text = newText
            
        }else{
            let newText = """
            \(message)
            """
            messageHistoryView.text = newText
            
        }
        
        let myRange=NSMakeRange(messageHistoryView.text.count-1, 0);
        messageHistoryView.scrollRangeToVisible(myRange)
        
        
    }
    
    
    
    
}
