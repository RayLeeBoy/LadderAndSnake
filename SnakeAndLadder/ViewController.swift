//
//  ViewController.swift
//  SnakeAndLadder
//
//  Created by 云淡风轻 on 2019/7/22.
//

import UIKit

class ViewController: UIViewController {

    // 25个位置数组
    var btnArr: [UIButton]!
    
    // 正方形棋盘背景
    var bgView: UIView!
    
    // 骰子
    var diceLabel: UILabel!
    
    // 红方英雄
    var redHeroView: UIView!
    
    // 蓝方英雄
    var blueHeroView: UIView!
    
    // 位置上的数据
    var board: [Int]!
    
    // 红方英雄和蓝方英雄的当前位置
    var positionArr: [Int]!
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 位置数组
        btnArr = []
        
        // 红蓝双方当前位置
        positionArr = [0, 0]
        
        // 初始化位置数据
        board = [Int](repeating: 0, count: 25)
        board[02] = +08; board[05] = +11; board[08] = +09; board[09] = +02
        board[13] = -10; board[18] = -11; board[21] = -02; board[23] = -08
        
        // 创建视图
        self.configUI()
    }
    
    // MARK: - 重新开始游戏
    @objc func restartAction() {
        self.titleLabel.text = "请红方走"
        self.diceLabel.text = "0"
        self.positionArr = [0, 0]
        self.redHeroView.layer.removeAllAnimations()
        self.blueHeroView.layer.removeAllAnimations()
    }
    
    // MARK: - 红方走
    @objc func redBtnAction(sender: UIButton) {
        self.animateAction(sender: sender, heroView: self.redHeroView)
    }
    
    // MARK: - 蓝方走
    @objc func blueBtnAction(sender: UIButton) {
        self.animateAction(sender: sender, heroView: self.blueHeroView)
    }
    
    // MARK: - 执行动画过程
    func animateAction(sender: UIButton, heroView: UIView) {
        sender.isEnabled = false
        randomValue()
        let value = Int(self.diceLabel.text!)!
        
        var positionIndex = 0
        
        // 英雄X坐标偏移量
        var addXValue: CGFloat = 0
        
        // 英雄Y坐标偏移量
        let addYValue: CGFloat = 30
        if heroView == self.redHeroView {
            positionIndex = 0
            addXValue = 20
        } else {
            positionIndex = 1
            addXValue = 40
        }
        
        // 最后移动到的位置
        var toPosition = self.positionArr[positionIndex] + value
        if toPosition > 24 {
            toPosition = 24
        }
        let to = btnArr[toPosition].frame.origin
        print("哪一方: \(positionIndex), 当前位置: \(self.positionArr[positionIndex]), 要去的地: \(toPosition)")
        
        let index = toPosition / 5
        
        // 当前位置
        let currentPosition = self.positionArr[positionIndex]
        
        // 动画路径数组
        var values: [NSValue] = []
        
        // 创建一个动画
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        
        // 第一步: 起点
        let tempTo = self.btnArr[currentPosition].frame.origin
        let v0 = NSValue(cgPoint: CGPoint(x: tempTo.x + addXValue, y: tempTo.y + addYValue))
        values.append(v0)
        
        // 第二步: 走到当前行的最后一格
        if (currentPosition / 5) < (toPosition / 5) {
            let tempTo1 = self.btnArr[currentPosition / 5 * 5 + 4].frame.origin
            let v1 = NSValue.init(cgPoint: CGPoint(x: tempTo1.x + addXValue, y: tempTo1.y + addYValue))
            values.append(v1)
        }
        
        // 第三步: 走到下一行的第一格
        if (currentPosition / 5) < (toPosition / 5) {
            let tempTo2 = self.btnArr[(currentPosition / 5 + 1) * 5].frame.origin
            let v2 = NSValue(cgPoint: CGPoint(x: tempTo2.x + addXValue, y: tempTo2.y + addYValue))
            values.append(v2)
        }
        
        // 第四步: 走到下一行的最后一格
        if currentPosition % 5 == 4 && value == 6 {
            let tempTo3 = self.btnArr[index * 5 - 1].frame.origin
            let v3 = NSValue(cgPoint: CGPoint(x: tempTo3.x + addXValue, y: tempTo3.y + addYValue))
            values.append(v3)
        }
        
        // 第五步: 走完
        if currentPosition != toPosition {
            let v4 = NSValue(cgPoint: CGPoint(x: to.x + addXValue, y: to.y + addYValue))
            values.append(v4)
        }
        
        // 第五步: 梯子和蛇
        let resultCurrentPositon = toPosition + self.board[toPosition]
        if toPosition != resultCurrentPositon {
            let finalTo = self.btnArr[resultCurrentPositon].frame.origin
            let v5 = NSValue(cgPoint: CGPoint(x: finalTo.x + addXValue, y: finalTo.y + addYValue))
            values.append(v5)
        }
        
        animation.values = values
        animation.duration = 2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        heroView.layer.add(animation, forKey: nil)
        
        // 记录位置
        self.positionArr[positionIndex] = resultCurrentPositon
        
        // 判断该谁走
        self.whoRun(positionIndex: positionIndex)
        
        // 判断是否胜利
        self.isSuccess(positionIndex: positionIndex)

        // 打开按钮
        sender.isEnabled = true
    }
    
    // MARK: - 判断该谁走
    func whoRun(positionIndex: Int) {
        if positionIndex == 0 {
            self.titleLabel.text = "请蓝方走"
        } else {
            self.titleLabel.text = "请红方走"
        }
    }
    
    // MARK: - 判断是否胜利
    func isSuccess(positionIndex: Int) {
        if self.positionArr[positionIndex] == 24 {
            var str = ""
            if positionIndex == 0 {
                str = "红方胜利"
            } else {
                str = "蓝方胜利"
            }
            let alert = UIAlertController.init(title: str, message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "知道了, 退下吧!", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - 摇骰子
    func randomValue() {
        let value = arc4random() % 6 + 1
        diceLabel.text = String(value)
    }
    
    // MARK: - 初始视图
    func configUI() {
        // 屏幕宽度
        let width: CGFloat = UIScreen.main.bounds.width
        
        // 每个位置的大小
        let height: CGFloat = 60
        
        // 提示用户
        titleLabel = UILabel.init()
        titleLabel.frame = CGRect(x: 20, y: 44, width: width - 40, height: 44)
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.text = "请红方走"
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .black
        self.view.addSubview(titleLabel)
        
        // 棋盘
        bgView = UIView.init()
        bgView.frame = CGRect(x: (width - height * 5) / 2, y: titleLabel.frame.maxY + 20, width: height * 5, height: height * 5)
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.borderWidth = 2
        self.view.addSubview(bgView)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var x1: CGFloat = 0
        var y1: CGFloat = 0
        
        // 棋盘
        for index in 0...24 {
            x = height * CGFloat(index % 5)
            if (index / 5 % 2 != 0) {
                x1 = bgView.bounds.width - x - height
            } else {
                x1 = height * CGFloat(index % 5)
            }
            
            y = height * CGFloat(index / 5)
            y1 = bgView.bounds.height - y - height
            
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect(x: x1, y: y1, width: height, height: height)
            bgView.addSubview(btn)
            btnArr.append(btn)
            
            let label = UILabel.init()
            label.frame = CGRect(x: height - 20, y: height - 20, width: 20, height: 20)
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 15)
            label.text = String(index + 1)
            btn.addSubview(label)
        }
        
        // 分割线
        for index in 0...24 {
            x = height * CGFloat(index % 5)
            y = height * CGFloat(index / 5)
            
            if (index < 4) {
                let line = UIView()
                line.frame = CGRect(x: x + height, y: 0, width: 2, height: height * 5)
                line.backgroundColor = .black
                bgView.addSubview(line)
            }
            
            if (index % 5 == 0 && index != 0) {
                let line = UIView()
                line.frame = CGRect(x: 0, y: y, width: height * 5, height: 2)
                line.backgroundColor = .black
                bgView.addSubview(line)
            }
        }
        
        // 梯子
        self.addArrow(from: btnArr[2].center, to: btnArr[10].center, color: .green)
        self.addArrow(from: btnArr[5].center, to: btnArr[16].center, color: .green)
        self.addArrow(from: btnArr[8].center, to: btnArr[17].center, color: .green)
        self.addArrow(from: btnArr[9].center, to: btnArr[11].center, color: .green)
        
        // 蛇
        self.addArrow(from: btnArr[23].center, to: btnArr[15].center, color: .red)
        self.addArrow(from: btnArr[21].center, to: btnArr[19].center, color: .red)
        self.addArrow(from: btnArr[18].center, to: btnArr[7].center, color: .red)
        self.addArrow(from: btnArr[13].center, to: btnArr[3].center, color: .red)
        
        // 玩家1
        let btn1 = UIButton.init(type: .custom)
        btn1.frame = CGRect(x: 20, y: bgView.frame.maxY + 20, width: (width - 40) / 2, height: 66)
        btn1.backgroundColor = .red
        btn1.setTitle("红方", for: .normal)
        btn1.layer.borderWidth = 2
        btn1.layer.borderColor = UIColor.blue.cgColor
        btn1.addTarget(self, action: #selector(redBtnAction(sender:)), for: .touchUpInside)
        self.view.addSubview(btn1)
        
        // 玩家2
        let btn2 = UIButton.init(type: .custom)
        btn2.frame = CGRect(x: width / 2, y: bgView.frame.maxY + 20, width: (width - 40) / 2, height: 66)
        btn2.backgroundColor = .blue
        btn2.setTitle("蓝方", for: .normal)
        btn2.setTitleColor(.white, for: .normal)
        btn2.layer.borderWidth = 2
        btn2.layer.borderColor = UIColor.red.cgColor
        btn2.addTarget(self, action: #selector(blueBtnAction(sender:)), for: .touchUpInside)
        self.view.addSubview(btn2)
        
        // 骰子
        diceLabel = UILabel()
        diceLabel.frame = CGRect(x: (width - 60) / 2, y: btn1.frame.maxY + 50, width: 60, height: 60)
        diceLabel.textAlignment = .center
        diceLabel.font = .boldSystemFont(ofSize: 44)
        diceLabel.text = "0";
        self.view.addSubview(diceLabel)
        
        // 重新开始
        let restartBtn = UIButton.init(type: .custom)
        restartBtn.frame = CGRect(x: 20, y: diceLabel.frame.maxY + 50, width: width - 40, height: 50)
        restartBtn.backgroundColor = .black
        restartBtn.setTitle("重新开始游戏", for: .normal)
        restartBtn.setTitleColor(.white, for: .normal)
        restartBtn.addTarget(self, action: #selector(restartAction), for: .touchUpInside)
        self.view.addSubview(restartBtn)
        
        // 英雄: 红方
        redHeroView = UIView()
        redHeroView.backgroundColor = .red
        let point = btnArr[0].frame.origin
        redHeroView.frame = CGRect(x: point.x + 10, y: point.y + 20, width: 20, height: 20)
        redHeroView.layer.cornerRadius = 10
        redHeroView.layer.masksToBounds = true
        bgView.addSubview(redHeroView)
        
        // 英雄: 蓝方
        blueHeroView = UIView()
        blueHeroView.backgroundColor = .blue
        blueHeroView.frame = CGRect(x: point.x + 30, y: point.y + 20, width: 20, height: 20)
        blueHeroView.layer.cornerRadius = 10
        blueHeroView.layer.masksToBounds = true
        bgView.addSubview(blueHeroView)
    }
    
    // MARK: 添加梯子和蛇
    func addArrow(from: CGPoint, to: CGPoint, color: UIColor) {
        let p = UIBezierPath.init()
        p.move(to: from)
        p.addLine(to: to)
        
        p.move(to: to)
        var delta: CGFloat = 0
        if (to.y > from.y) {
            delta = -10
        } else {
            delta = 10
        }
        let firstPoint = CGPoint(x: to.x, y: to.y + delta)
        p.addLine(to: firstPoint)
        
        p.move(to: to)
        if (to.x > from.x) {
            delta = -10
        } else {
            delta = 10
        }
        let secondPoint = CGPoint(x: to.x + delta, y: to.y)
        p.addLine(to: secondPoint)
        
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.path = p.cgPath
        bgView.layer.addSublayer(shapeLayer)
    }
}
