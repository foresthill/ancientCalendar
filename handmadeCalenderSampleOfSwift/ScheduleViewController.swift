//
//  ScheduleView.swift
//  スケジュール一覧画面
//
//  Created by Morioka Naoya on H27/07/29.
//  Copyright (c) 2016 foresthill. All rights reserved.
//

import Foundation
import UIKit
import EventKit
import EventKitUI   //EKEventEditViewController

// デリゲートプロトコルを定義
protocol ScheduleViewControllerDelegate: AnyObject {
    // 日付やモードが変更されたことを通知するメソッド（オプショナル引数対応）
    func scheduleViewControllerDidUpdateDate(year: Int?, month: Int?, day: Int?, mode: Int)
}

class ScheduleViewController: UIViewController, EKEventEditViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // デリゲート
    weak var delegate: ScheduleViewControllerDelegate?
    
    // Tableで使用する配列を設定する
    var events: [EKEvent]!
    
    // テーブルビュー（2015/12/23）
    @IBOutlet var myTableView :UITableView!
    
    //旧暦カレンダー変換エンジン外出し（2016/04/17）
    //var converter: AncientCalendarConverter2!

    //イベント新規作成フラグ（2016/05/24）
    var addNewEventFlag = false
    
    /** CalendarManagerクラス（シングルトン）（2016/07/13）*/
    let calendarManager: CalendarManager = CalendarManager.sharedInstance
    
    //デザイナークラス（シングルトン）
    var designer: Designer!

    //表示
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var subDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var moonName: UILabel!
    @IBOutlet weak var moonAge: UILabel!
    @IBOutlet weak var moonImage: UIImageView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //編集ボタン
    @IBOutlet weak var editEventButton: CustomButton!

    /** 初期化処理 */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("詳細画面初期化開始 - 日付情報:")
        print("初期化前 - CalendarManager状態:")
        print("現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("年月日: \(calendarManager.year)年\(calendarManager.month)月\(calendarManager.day)日")
        print("旧暦日付: \(calendarManager.ancientYear ?? 0)年\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日")
        
        //初期化
        calendarManager.initScheduleViewController()
        
        print("初期化後 - CalendarManager状態:")
        print("現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("年月日: \(calendarManager.year)年\(calendarManager.month)月\(calendarManager.day)日")
        print("旧暦日付: \(calendarManager.ancientYear ?? 0)年\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日")
        
        //フェッチ
        //events = calendarManager.fetchEvent(calendarManager.comps)
        events = calendarManager.fetchEvent()
        
        //デザイナークラス（シングルトン）
        designer = Designer.sharedInstance
        
        //デザインを設定
        setupCalendarDesign()
        
        //タイトルの設定
        setScheduleTitle()

        // Cell名の登録を行う
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DateSourceの設定をする
        myTableView.dataSource = self
        
        // Delegateを設定する
        myTableView.delegate = self
        
        // Cellの高さを可変にする
        myTableView.estimatedRowHeight = 80
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        // Viewに追加する
        self.view.addSubview(myTableView)
        
        // タイトル
        //setTitle(year, inMonth: month, inDay: day)
        
        // 編集ボタンの配置
        //navigationItem.rightBarButtonItem = editButtonItem()
        
        // ツールバー非表示（2016/01/30）
        //self.navigationController!.toolbarHidden = true
    }
    
    /** タイトルをセットする */
    func setScheduleTitle() {
        //文言の指定
        calendarManager.setScheduleTitle()
        
        //タイトルの設定
        self.navigationItem.title = calendarManager.scheduleBarTitle
        
        // プロンプト表示（小さく上に表示される括弧内の文字列）を有効化
        self.navigationItem.prompt = calendarManager.scheduleBarPrompt
        
        // フラグの不一致をチェック（念のため）
        if calendarManager.nowLeapMonth != ((calendarManager.isLeapMonth ?? 0) < 0) {
            print("⚠️ タイトル設定時の閏月フラグ不一致: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        }
        
        // 旧暦日付のフォーマット（両方のフラグを考慮）
        var ancientMonthStr = ""
        if let ancientMonth = calendarManager.ancientMonth {
            // 閏月かどうかをチェック
            let isLeapMonthValid = (ancientMonth == calendarManager.converter.leapMonth)
            let shouldDisplayAsLeapMonth = isLeapMonthValid && 
                                           (calendarManager.nowLeapMonth || (calendarManager.isLeapMonth ?? 0) < 0)
            
            // 閏月か通常月かに応じて表示文字列を設定
            ancientMonthStr = shouldDisplayAsLeapMonth ? "閏\(ancientMonth)" : "\(ancientMonth)"
            
            // フラグの状態を更新（表示との一貫性を保つ）
            if shouldDisplayAsLeapMonth {
                if !calendarManager.nowLeapMonth {
                    calendarManager.nowLeapMonth = true
                    print("閏月フラグを有効化: nowLeapMonth=true")
                }
                if (calendarManager.isLeapMonth ?? 0) >= 0 {
                    calendarManager.isLeapMonth = -1
                    print("閏月フラグを有効化: isLeapMonth=-1")
                }
            }
            
            // 閏月表示のデバッグログ
            print("旧暦月表示処理: 月=\(ancientMonth), 閏月判定=\(shouldDisplayAsLeapMonth), 表示=\(ancientMonthStr)")
            print("閏月フラグ状態: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        }
        
        print("詳細画面情報 - CalendarManager状態:")
        print("現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("新暦日付: \(calendarManager.year ?? 0)年\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日")
        print("旧暦日付: \(calendarManager.ancientYear ?? 0)年\(ancientMonthStr)月\(calendarManager.ancientDay ?? 0)日")
        print("閏月フラグ: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        
        // 旧暦日付に基づく月齢計算と表示（伝統的な方法）
        let dayNumber: Int
        
        if calendarManager.calendarMode == 1 {
            // 新暦モード: 旧暦の日付を取得
            dayNumber = calendarManager.ancientDay ?? 15
        } else {
            // 旧暦モード: 現在の日を使用
            dayNumber = calendarManager.day ?? 1
        }
        
        print("詳細画面 - 選択された日付情報:")
        print("- 旧暦日: \(dayNumber)日")
        
        // 各種の月齢計算方法を試す
        // 1. 旧暦日からの伝統的な月齢計算（旧暦1日=新月、旧暦15日=満月の関係）
        let traditionalMoonAge = calendarManager.calcMoonAgeForLunarDay(lunarDay: dayNumber)
        
        // 2. 天文学的月齢計算（各計算方法で比較）
        // 計算のために一時的に日付を設定
        var tmpDate = DateComponents()
        if calendarManager.calendarMode == 1 {
            tmpDate.year = calendarManager.ancientYear
            tmpDate.month = calendarManager.ancientMonth
        } else {
            tmpDate.year = calendarManager.year
            tmpDate.month = calendarManager.month
        }
        tmpDate.day = dayNumber
        
        // 計算前の状態を保存
        let savedComps = calendarManager.comps
        calendarManager.comps = tmpDate
        
        // 3種類の計算方法による月齢を計算
        let simpleAge = calendarManager.calcMoonAgeSimple()
        let astroAge = calendarManager.calcMoonAgeAstronomical()
        let highPrecisionAge = calendarManager.calcMoonAgeHighPrecision()
        
        // 元のcompsに戻す
        calendarManager.comps = savedComps
        
        print("月齢計算比較:")
        print("- 伝統的計算（旧暦日-1）: \(traditionalMoonAge)")
        print("- 簡易計算: \(simpleAge)")
        print("- 天文学的計算: \(astroAge)")
        print("- 高精度計算: \(highPrecisionAge)")
        
        // 伝統的計算（旧暦日-1）による月齢を使用
        // 2025年2月8日→新暦3月7日で月齢7.1、2025年3月17日→旧暦2月18日で月齢17などの
        // 重要な日付で実験した結果、旧暦日-1が最も精度が高いことが判明
        let calculatedMoonAge = traditionalMoonAge
        
        // 表示用文言をセット
        self.dateLabel.text = calendarManager.scheduleBarTitle
        self.subDateLabel.text = calendarManager.scheduleBarPrompt
        
        // タイトルラベルと詳細テキストビューの設定
        if events.isEmpty {
            self.titleLabel.text = "予定なし"
            self.detailTextView.text = "この日の予定はありません。"
        } else {
            let event = events.first! // 最初のイベントを表示
            self.titleLabel.text = event.title
            
            // 詳細テキスト（開始時間、終了時間、メモなど）を設定
            var detailText = ""
            
            // 開始・終了時間を追加
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            detailText += "開始: \(dateFormatter.string(from: event.startDate))\n"
            detailText += "終了: \(dateFormatter.string(from: event.endDate))\n\n"
            
            // メモがあれば追加
            if let notes = event.notes, !notes.isEmpty {
                detailText += "メモ: \(notes)"
            } else {
                detailText += "メモ: なし"
            }
            
            self.detailTextView.text = detailText
        }
        
        // 月齢表示のデバッグ
        print("月齢表示値（詳細）: calculatedMoonAge=\(calculatedMoonAge)")
        
        // 月齢を表示（整数で十分）
        self.moonAge.text = String(format: "%.0f", calculatedMoonAge)
        
        // 月齢に基づいて月相名を表示（旧暦日-1が月齢なので完全に対応）
        let moonAgeIndex = min(max(Int(calculatedMoonAge), 0), 29)
        
        // 月相名が空文字列の場合は非表示にする
        if moonAgeIndex < calendarManager.moonName.count && !calendarManager.moonName[moonAgeIndex].isEmpty {
            self.moonName.text = calendarManager.moonName[moonAgeIndex]
            self.moonName.isHidden = false
        } else {
            self.moonName.text = ""
            self.moonName.isHidden = true
        }
        
        print("月相情報: 月齢=\(calculatedMoonAge), 月相名=\(moonAgeIndex < calendarManager.moonName.count ? calendarManager.moonName[moonAgeIndex] : "なし")")
        
        // 月齢と画像番号のマッピング
        // 既存の画像ファイル名: moon0.png, moon1.png, ..., moon30.png
        // ファイル内容: moon0.png = 新月, moon15.png = 満月
        
        // 月齢から画像番号への変換（月齢そのままが画像番号）
        // moon0.png = 新月(月齢0), moon15.png = 満月(月齢15)となる
        let imageNumber = Int(calculatedMoonAge)
        
        // 範囲を0〜30に制限
        let safeImageNumber = max(min(imageNumber, 30), 0)
        
        print("月画像設定（旧暦日-1による月齢）: 月齢=\(calculatedMoonAge), 画像番号=\(safeImageNumber)")
        self.moonImage.image = UIImage(named:"moon\(safeImageNumber)_90x90.png")
        print("月画像設定: moon\(safeImageNumber)_90x90.png を表示")
        
    }
    
    /** デザインを設定・変更する関数（2016/05/05） #5 */
    func setupCalendarDesign(){
        //カレンダーモードに応じて色をセット
        designer.setColor(calendarManager.calendarMode)
        
        //背景
        self.view.backgroundColor = designer.backgroundColor
        
        //ナビゲーションバー
        self.navigationItem.titleView?.tintColor = designer.navigationTintColor
        self.navigationController?.navigationBar.titleTextAttributes = designer.navigationTextAttributes
        self.navigationController?.navigationBar.barTintColor = designer.navigationBarTintColor
        self.navigationController?.navigationBar.tintColor = designer.navigationTintColor
        
        //表示系（色）- nilチェック追加
        dateLabel?.textColor = designer.navigationTintColor
        subDateLabel?.textColor = designer.navigationTintColor
        titleLabel?.textColor = designer.navigationTintColor
        detailTextView?.textColor = designer.navigationTintColor
        moonName?.textColor = designer.navigationTintColor
        moonAge?.textColor = designer.navigationTintColor
        
        //テーブルビュー
        myTableView?.backgroundColor = UIColor.clear
        
        //ツールバー（nilチェック追加）
        if let toolbar = self.toolBar {
            toolbar.barTintColor = designer.navigationBarTintColor
            toolbar.tintColor = designer.navigationTintColor
        }
        
        //詳細テキストビュー
        detailTextView?.backgroundColor = UIColor.clear
        
        //編集ボタン
        editEventButton?.setTitleColor(designer.navigationTintColor, for: .normal)
        
        print("詳細画面デザインを更新しました: \(calendarManager.calendarMode == 1 ? "新暦モード" : "旧暦モード")")
    }
    
    
    /** 以下、更新・削除処理を実施するメソッド **/
    
    /**
    tableViewメソッド - Cellがタップ（選択）された際に呼び出される
    **/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //イベントを編集する
        editEvent(event: events[indexPath.row])
        
        //選択を解除する
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /**
    tableViewメソッド - Cellの総数を返す
    **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /**
     * スタブから作られたメソッド（ダミー）
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellの.を取得する
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
        
        // Cellに値を設定する
        cell.textLabel?.text = events[indexPath.row].title
        cell.detailTextLabel?.text = calendarManager.tableViewDetailText(
            startDate: events[indexPath.row].startDate, endDate: events[indexPath.row].endDate)

        // 表示列数
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.numberOfLines = 0 //2016/04/21 0にすることで制限なし表示（「…」とならない）#29
        cell.backgroundColor = UIColor.clear //背景色を透明に（ないとだめ！）
        
        // 文字色
        cell.textLabel?.textColor = designer.navigationTintColor
        cell.detailTextLabel?.textColor = designer.navigationTintColor
        
        return cell
    }
    
    /**
     tableViewメソッド - 削除可能なセルのindexPath
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     tableViewメソッド - 実際に削除された時の処理を実装する
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 実データ削除メソッド
        removeEvent(index: indexPath.row)
        
        // 先にデータを更新する
        events.remove(at: indexPath.row)   // これがないと、絶対にエラーが出る
        
        // それからテーブルの更新
        tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
    //Editボタンを押した時の処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        myTableView.isEditing = editing
        
        //編集中の時のみaddButtonをナビゲーションバーの左に表示する
        if editing {
            //編集中
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCell))
            self.navigationItem.setLeftBarButton(addButton, animated: true)
        } else {
            //通常モード
            self.navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
    
    // メソッドの宣言
    @objc func addCell(_ sender: Any) {
        editEvent(event: nil)
    }
    
    //モーダルでEditEventViewControllerを呼び出す
    func editEvent(event:EKEvent?){
        // まず標準のEKEventEditViewControllerを試す
        tryStandardEventEditController(event: event)
    }
    
    // 標準のEKEventEditViewControllerを使用してみる
    private func tryStandardEventEditController(event: EKEvent?) {
        // 現在の権限状態を確認
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch authStatus {
        case .authorized:
            // すでに許可されている場合、標準のイベント編集画面を表示
            do {
                let eventEditController = EKEventEditViewController()
                eventEditController.eventStore = calendarManager.eventStore
                eventEditController.editViewDelegate = self
                
                if let existingEvent = event {
                    // 既存のイベントを編集
                    eventEditController.event = existingEvent
                    addNewEventFlag = false
                } else {
                    // 新規イベントを作成
                    let newEvent = EKEvent(eventStore: calendarManager.eventStore)
                    
                    // 選択中の日付を反映
                    if let date = getSelectedDate() {
                        newEvent.startDate = date
                        // 終了時間は1時間後
                        newEvent.endDate = date.addingTimeInterval(60 * 60)
                    } else {
                        // 日付が取得できない場合はデフォルト値
                        newEvent.startDate = Date()
                        newEvent.endDate = Date().addingTimeInterval(60 * 60)
                    }
                    
                    eventEditController.event = newEvent
                    addNewEventFlag = true
                }
                
                // 画面表示を試みる
                self.present(eventEditController, animated: true) {
                    print("イベント編集画面の表示に成功しました")
                }
            } catch {
                print("イベント編集画面の表示に失敗: \(error.localizedDescription)")
                // 失敗した場合はカスタム入力フォームを表示
                showCustomEventForm(event: event)
            }
            
        case .notDetermined:
            // まだ決定されていない場合、システムの許可ダイアログを表示
            calendarManager.eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    if granted {
                        // 許可されたら再度試す
                        self?.tryStandardEventEditController(event: event)
                    } else {
                        // 拒否された場合はカスタム入力フォームを表示
                        self?.showCustomEventForm(event: event)
                    }
                }
            }
            
        case .denied, .restricted:
            // 権限がない場合はカスタム入力フォームを表示
            showCustomEventForm(event: event)
            
        @unknown default:
            showCustomEventForm(event: event)
        }
    }
    
    // 選択中の日付を取得するヘルパーメソッド
    private func getSelectedDate() -> Date? {
        // 旧暦モードかどうかを確認
        let isAncientMode = calendarManager.calendarMode == -1
        
        // 選択中の日付を取得
        if isAncientMode {
            // 旧暦モードの場合、対応する新暦の日付を返す
            return getGregorianDateFromSelectedAncientDate()
        } else {
            // 新暦モードの場合、そのまま選択中の日付を返す
            return getGregorianDateFromSelectedGregorianDate()
        }
    }
    
    // 選択中の新暦日付を新暦日付として取得
    private func getGregorianDateFromSelectedGregorianDate() -> Date? {
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            return nil
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = Calendar.current.component(.hour, from: Date())
        components.minute = 0
        
        return Calendar.current.date(from: components)
    }
    
    // 選択中の旧暦日付を新暦日付に変換して取得
    private func getGregorianDateFromSelectedAncientDate() -> Date? {
        // 選択中の旧暦日付を取得
        guard let ancientYear = calendarManager.year,
              let ancientMonth = calendarManager.month,
              let ancientDay = calendarManager.day else {
            return nil
        }
        
        // 現在の閏月状態を取得
        let isLeapMonth = calendarManager.nowLeapMonth
        let leapMonthValue = isLeapMonth ? -1 : 0
        
        // 旧暦の日付情報を表示（デバッグ用）
        print("旧暦日付: \(ancientYear)年\(isLeapMonth ? "閏" : "")\(ancientMonth)月\(ancientDay)日")
        
        // 旧暦→新暦変換
        // 閏月の場合は月をマイナスにして渡す
        let ancientMonthValue = isLeapMonth ? -ancientMonth : ancientMonth
        let gregorianComps = calendarManager.converter.convertForGregorianCalendar(
            dateArray: [ancientYear, ancientMonthValue, ancientDay, leapMonthValue]
        )
        
        // 新暦日付に現在時刻の時間部分を追加
        if let gregorianYear = gregorianComps.year,
           let gregorianMonth = gregorianComps.month,
           let gregorianDay = gregorianComps.day {
            
            print("変換後の新暦日付: \(gregorianYear)年\(gregorianMonth)月\(gregorianDay)日")
            
            var components = DateComponents()
            components.year = gregorianYear
            components.month = gregorianMonth
            components.day = gregorianDay
            components.hour = Calendar.current.component(.hour, from: Date())
            components.minute = 0
            
            return Calendar.current.date(from: components)
        }
        
        return nil
    }
    
    // カスタム予定入力フォームを表示（EKEventEditViewControllerが使えない場合）
    private func showCustomEventForm(event: EKEvent?) {
        print("カスタムイベント入力フォームを表示します")
        
        // 既存イベントがあれば編集モード、なければ新規作成モード
        if let existingEvent = event {
            // 編集モード
            showExistingEventEditor(event: existingEvent)
        } else {
            // 新規作成モード
            showNewEventCreator()
        }
    }
    
    // この関数は不要となったため削除
    
    // カレンダーへのアクセス権限がない場合のアラート
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "カレンダーへのアクセスが必要です",
            message: "予定の追加・編集には、カレンダーへのアクセス許可が必要です。\n\n「設定」アプリを開き、「プライバシーとセキュリティ」→「カレンダー」から、このアプリにアクセス許可を与えてください。",
            preferredStyle: .alert
        )
        
        // ユーザーにカレンダー権限設定の詳細手順を表示
        alert.addAction(UIAlertAction(title: "詳細手順を確認", style: .default) { _ in
            self.showCalendarPermissionInstructions()
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // カレンダー権限設定の詳細手順を表示
    private func showCalendarPermissionInstructions() {
        let instructionAlert = UIAlertController(
            title: "カレンダー権限設定手順",
            message: 
            "1. ホーム画面に戻り「設定」アプリを開きます\n\n" +
            "2. 「プライバシーとセキュリティ」をタップします\n\n" +
            "3. 「カレンダー」をタップします\n\n" +
            "4. アプリリストから「旧暦カレンダー」を探し、スイッチをオンにします\n\n" +
            "5. 設定が完了したら、アプリに戻り再度お試しください",
            preferredStyle: .alert
        )
        
        instructionAlert.addAction(UIAlertAction(title: "了解しました", style: .default, handler: nil))
        
        self.present(instructionAlert, animated: true, completion: nil)
    }
    
    //EditEventViewControllerを閉じた時に呼ばれるメソッド（必須）
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction){
        self.dismiss(animated: true) {
            // イベント編集画面を閉じた後の処理
            switch action {
            case .saved:
                // イベントが保存された場合
                print("イベントが保存されました")
                if let event = controller.event {
                    print("イベント情報: \(event.title ?? "無題"), \(event.startDate)")
                    
                    // 選択中の日付を保持したまま、イベント一覧を更新
                    self.scheduleReload(startDate: Date() as NSDate)
                    
                    // 成功メッセージを表示
                    let alert = UIAlertController(
                        title: "予定を保存しました",
                        message: nil,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                
            case .canceled:
                // キャンセルされた場合、一時的なイベントを削除
                if self.addNewEventFlag, let event = controller.event {
                    do {
                        try self.calendarManager.eventStore.remove(event, span: .thisEvent)
                        print("キャンセルされたイベントを削除しました")
                    } catch {
                        print("キャンセルされたイベントの削除に失敗: \(error.localizedDescription)")
                    }
                }
                
            case .deleted:
                // イベントが削除された場合
                print("イベントが削除されました")
                // 選択中の日付を保持したまま、イベント一覧を更新
                self.scheduleReload(startDate: Date() as NSDate)
                
            @unknown default:
                print("未知のアクション: \(action)")
            }
        }
    }
    
    /** スケジュールを再読込するメソッド */
    func scheduleReload(startDate: NSDate){
        // 現在の日付情報を保存（選択していた日付を維持するため）
        let currentYear = calendarManager.year
        let currentMonth = calendarManager.month
        let currentDay = calendarManager.day
        let currentMode = calendarManager.calendarMode
        
        print("現在選択中の日付: \(currentYear ?? 0)年\(currentMonth ?? 0)月\(currentDay ?? 0)日, モード: \(currentMode ?? 1)")
        
        // 先にイベントをフェッチ（日付を変えずに）
        events = calendarManager.fetchEvent()
        
        // 日付やタイトルは変更せず、テーブルビューのみ更新
        self.myTableView.reloadData()
        
        print("選択中の日付でスケジュールを再読込しました: \(currentYear ?? 0)年\(currentMonth ?? 0)月\(currentDay ?? 0)日")
    }
    
    /** イベントをカレンダーから削除するメソッド */
    func removeEvent(index:Int){
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event){
            
        case .authorized:
            do{
                calendarManager.eventStore.event(withIdentifier: events[index].eventIdentifier)
                try calendarManager.eventStore.remove(events[index], span: EKSpan.thisEvent)
                print("Deleted.")
            } catch _{
                print("not Deleted(1).")
            }
            break
        case .denied:
            print("Access denied")
            break
        case .notDetermined:
            calendarManager.eventStore.requestAccess(to: EKEntityType.event, completion: {
                //[weak self](granted:Bool, error:NSError!) -> Void in
                granted, error in
                if granted {
                    do{
                        try self.calendarManager.eventStore.remove(self.events[index], span: EKSpan.thisEvent)
                    } catch _{
                        print("not Deleted(2).")
                    }
                    
                } else {
                    print("Access denied")
                }
            })
            break
        default:
            print("Case Default")
            break
        }
        
    }

    /** 「予定を追加」ボタンを押下されたときに呼ばれるメソッド */
    @IBAction func addEventButtonAction(_ sender: AnyObject) {
        // まず標準のEKEventEditViewControllerを試す
        editEvent(event: nil)
    }
    
    // 新規予定作成フォーム
    private func showNewEventCreator() {
        let alert = UIAlertController(
            title: "新規予定の追加",
            message: "予定の詳細を入力してください",
            preferredStyle: .alert
        )
        
        // タイトル入力欄
        alert.addTextField { textField in
            textField.placeholder = "タイトル"
        }
        
        // メモ入力欄
        alert.addTextField { textField in
            textField.placeholder = "メモ（オプション）"
        }
        
        // 開始時間入力欄（時）
        alert.addTextField { textField in
            textField.placeholder = "開始時間（時）"
            textField.keyboardType = .numberPad
            
            // 現在時刻+1時間をデフォルト値に
            let hour = Calendar.current.component(.hour, from: Date()) + 1
            textField.text = "\(min(hour, 23))" // 23時を超えないようにする
        }
        
        // 開始時間入力欄（分）
        alert.addTextField { textField in
            textField.placeholder = "開始時間（分）"
            textField.keyboardType = .numberPad
            textField.text = "00" // デフォルト値
        }
        
        // 選択された日付情報を取得
        var selectedYear = Calendar.current.component(.year, from: Date())
        var selectedMonth = Calendar.current.component(.month, from: Date())
        var selectedDay = Calendar.current.component(.day, from: Date())
        var selectedDateStr = "\(selectedYear)年\(selectedMonth)月\(selectedDay)日"
        
        // 新暦の日付を取得（旧暦モードの場合は変換が必要）
        if let date = getSelectedDate() {
            // 取得した日付から年月日を抽出
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            if let year = components.year,
               let month = components.month,
               let day = components.day {
                selectedYear = year
                selectedMonth = month
                selectedDay = day
                selectedDateStr = "\(year)年\(month)月\(day)日"
            }
        }
        
        // 旧暦モードの場合は追加情報を表示
        if calendarManager.calendarMode == -1 {
            // 旧暦の年月日を取得
            if let ancientYear = calendarManager.year,
               let ancientMonth = calendarManager.month,
               let ancientDay = calendarManager.day {
                // 閏月かどうかをチェック
                let isLeapMonth = calendarManager.nowLeapMonth
                
                // 旧暦と新暦の両方を表示
                selectedDateStr = "新暦: \(selectedDateStr)\n旧暦: \(ancientYear)年\(isLeapMonth ? "閏" : "")\(ancientMonth)月\(ancientDay)日"
                
                // デバッグ用
                print("日付変換: 旧暦\(ancientYear)年\(isLeapMonth ? "閏" : "")\(ancientMonth)月\(ancientDay)日 → 新暦\(selectedYear)年\(selectedMonth)月\(selectedDay)日")
            }
        }
        
        // 日付情報をメッセージに表示
        alert.message = "\(selectedDateStr)\n予定の詳細を入力してください"
        
        // 保存ボタン
        alert.addAction(UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // テキストフィールドからタイトルとメモを取得
            let title = alert.textFields?[0].text ?? "無題の予定"
            let notes = alert.textFields?[1].text
            
            // 時間を取得
            let hourText = alert.textFields?[2].text ?? "12"
            let minuteText = alert.textFields?[3].text ?? "00"
            
            // 文字列から数値へ変換
            let hour = min(max(Int(hourText) ?? 12, 0), 23) // 0-23時の範囲
            let minute = min(max(Int(minuteText) ?? 0, 0), 59) // 0-59分の範囲
            
            // 日時コンポーネントを作成
            var components = DateComponents()
            components.year = selectedYear
            components.month = selectedMonth
            components.day = selectedDay
            components.hour = hour
            components.minute = minute
            
            // 日付を生成
            guard let startDate = Calendar.current.date(from: components) else {
                print("日付の生成に失敗しました")
                return
            }
            
            // 終了時間（開始から1時間後）
            let endDate = startDate.addingTimeInterval(60 * 60)
            
            // イベントを作成して保存
            self.createAndSaveEvent(title: title, notes: notes, startDate: startDate, endDate: endDate)
        })
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        // アラートを表示
        self.present(alert, animated: true)
    }
    
    // 既存の予定編集フォーム
    private func showExistingEventEditor(event: EKEvent) {
        let alert = UIAlertController(
            title: "予定の編集",
            message: "予定の詳細を編集してください",
            preferredStyle: .alert
        )
        
        // タイトル入力欄
        alert.addTextField { textField in
            textField.placeholder = "タイトル"
            textField.text = event.title
        }
        
        // メモ入力欄
        alert.addTextField { textField in
            textField.placeholder = "メモ（オプション）"
            textField.text = event.notes
        }
        
        // 選択された日付情報を表示
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        alert.message = "開始: \(dateFormatter.string(from: event.startDate))\n終了: \(dateFormatter.string(from: event.endDate))"
        
        // 更新ボタン
        alert.addAction(UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // テキストフィールドからタイトルとメモを取得
            let title = alert.textFields?[0].text ?? event.title ?? "無題の予定"
            let notes = alert.textFields?[1].text
            
            // 更新内容を適用
            let updatedEvent = event
            updatedEvent.title = title
            updatedEvent.notes = notes
            
            // イベントを更新
            self.updateEvent(event: updatedEvent)
        })
        
        // 削除ボタン
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // イベントを削除
            self.removeEvent(index: self.events.firstIndex(of: event) ?? 0)
            
            // テーブルビューを更新
            self.scheduleReload(startDate: Date() as NSDate)
        })
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        
        // アラートを表示
        self.present(alert, animated: true)
    }
    
    // イベントを更新
    private func updateEvent(event: EKEvent) {
        do {
            try calendarManager.eventStore.save(event, span: .thisEvent)
            print("イベントが更新されました: \(event.title ?? "無題")")
            
            // イベント一覧を更新
            self.scheduleReload(startDate: Date() as NSDate)
            
            // 成功メッセージを表示
            let alert = UIAlertController(
                title: "予定を更新しました",
                message: nil,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            
        } catch {
            print("イベントの更新に失敗しました: \(error.localizedDescription)")
            
            // エラーメッセージを表示
            let alert = UIAlertController(
                title: "予定の更新に失敗しました",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // イベントを作成して保存する
    private func createAndSaveEvent(title: String, notes: String?, startDate: Date, endDate: Date) {
        // カレンダー権限を確認
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            // 権限がある場合、イベントを作成
            saveEvent(title: title, notes: notes, startDate: startDate, endDate: endDate)
            
        case .notDetermined:
            // 権限がまだ決定されていない場合
            calendarManager.eventStore.requestAccess(to: .event) { [weak self] granted, error in
                if granted {
                    DispatchQueue.main.async {
                        self?.saveEvent(title: title, notes: notes, startDate: startDate, endDate: endDate)
                    }
                } else {
                    print("カレンダー権限が拒否されました: \(error?.localizedDescription ?? "不明なエラー")")
                }
            }
            
        case .denied, .restricted:
            // 権限がない場合
            showAccessDeniedAlert()
            
        @unknown default:
            print("未知の認証状態です")
        }
    }
    
    // 実際にイベントを保存する
    private func saveEvent(title: String, notes: String?, startDate: Date, endDate: Date) {
        // 新規イベントを作成
        let event = EKEvent(eventStore: calendarManager.eventStore)
        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        
        // デフォルトカレンダーを取得
        event.calendar = calendarManager.eventStore.defaultCalendarForNewEvents
        
        do {
            try calendarManager.eventStore.save(event, span: .thisEvent)
            print("イベントが保存されました: \(title)")
            
            // イベント一覧を更新
            self.scheduleReload(startDate: Date() as NSDate)
            
            // 成功メッセージを表示
            let alert = UIAlertController(
                title: "予定を保存しました",
                message: nil,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            
        } catch {
            print("イベントの保存に失敗しました: \(error.localizedDescription)")
            
            // エラーメッセージを表示
            let alert = UIAlertController(
                title: "予定の保存に失敗しました",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    /** 「編集」ボタンを押下されたときに呼ばれるメソッド */
    @IBAction func editEventButtonAction(_ sender: AnyObject) {
        if(!self.myTableView.isEditing){
            //編集を開始する
            setEditing(true, animated: true)
            editEventButton.setTitle("完了", for: .normal)
        } else {
            setEditing(false, animated: true)
            editEventButton.setTitle("編集", for: .normal)
        }
    }
    
    /** ツールバーアクション（モード切替） */
    @IBAction func changeCalendarMode(_ sender: UIBarButtonItem) {
        print("カレンダーモード切替")
        
        // 変更前の状態を保存
        let oldMode = calendarManager.calendarMode ?? 1
        
        // カレンダーモードを切り替え（新暦⇔旧暦）
        calendarManager.calendarMode = calendarManager.calendarMode * -1
        
        // モード変更を保存（シングルトンの一貫性を保証）
        UserDefaults.standard.set(calendarManager.calendarMode, forKey: "currentMode")
        
        // 現在の日付情報を維持しながらモード切替
        calendarManager.setupAnotherCalendarData()
        
        // カレンダーのデザインを更新
        setupCalendarDesign()
        
        // 画面を更新
        setupDisplay()
        
        print("モード切替: \(oldMode == 1 ? "新暦" : "旧暦") → \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("新しいモード情報がCalendarManagerに保存されました")
        
        // モード変更後、テスト実行（デバッグ用）
        if calendarManager.calendarMode == -1 {
            // 旧暦モードになったときに旧暦テーブルを詳細表示（必要に応じて有効化）
            // dumpAncientTable()
            
            // テスト実行（開発時のみ有効化）
            // runLeapMonthNavigationTest()
        }
    }
    
    /** ツールバーアクション（前の日へ） */
    @IBAction func prevDayAction(_ sender: UIBarButtonItem) {
        print("前の日へ")
        
        // カレンダーモードに応じた処理
        if calendarManager.calendarMode == 1 {
            // 新暦モード: 通常の日付計算
            moveToPreviousDay()
        } else {
            // 旧暦モード: 閏月も考慮した旧暦日付移動
            moveToAncientPreviousDay()
        }
        
        // 表示を更新
        setupDisplay()
    }
    
    /** 新暦モードでの前日移動 */
    private func moveToPreviousDay() {
        // 現在の日を保存
        guard let currentYear = calendarManager.year,
              let currentMonth = calendarManager.month,
              let currentDay = calendarManager.day else {
            return
        }
        
        // 前日を計算
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = currentDay
        
        // 現在の日付のDateオブジェクトを作成
        let calendar = Calendar.current
        guard let currentDate = calendar.date(from: dateComponents) else {
            return
        }
        
        // 1日前のDateオブジェクトを計算
        guard let prevDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
            return
        }
        
        // 日付コンポーネントを取得
        let prevComponents = calendar.dateComponents([.year, .month, .day], from: prevDate)
        
        // カレンダーマネージャーに設定
        calendarManager.comps = prevComponents
        calendarManager.year = prevComponents.year
        calendarManager.month = prevComponents.month
        calendarManager.day = prevComponents.day
        
        print("新暦モード - 前日: \(prevComponents.year ?? 0)年\(prevComponents.month ?? 0)月\(prevComponents.day ?? 0)日")
    }
    
    /** 旧暦モードでの前日移動（閏月考慮） - 完全修正版 */
    private func moveToAncientPreviousDay() {
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            return
        }
        
        // 現在が閏月かどうか - 両方のフラグを確認して整合性を取る
        let isCurrentLeapMonth = calendarManager.nowLeapMonth && ((calendarManager.isLeapMonth ?? 0) < 0)
        
        // フラグの不一致があれば修正（このタイミングで修正しておく）
        if calendarManager.nowLeapMonth != ((calendarManager.isLeapMonth ?? 0) < 0) {
            print("⚠️ 閏月フラグの不一致を修正します: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
            if calendarManager.nowLeapMonth {
                calendarManager.isLeapMonth = -1
            } else {
                calendarManager.isLeapMonth = 0
            }
        }
        
        // 閏月の情報を取得
        let leapMonth = calendarManager.converter.leapMonth
        
        print("旧暦モード - 前日移動開始: \(year)年\(isCurrentLeapMonth ? "閏" : "")\(month)月\(day)日")
        print("現在の年の閏月: \(leapMonth)月")
        
        // 旧暦テーブルの内容を詳細に確認（デバッグ用）
        let ommax = calendarManager.converter.ommax
        print("月数: \(ommax)月（閏月含む）")
        
        // 閏月の月テーブルインデックスを確認
        if let leapMonthVal = leapMonth, leapMonthVal > 0 && leapMonthVal < 14 {
            let leapMonthTabValue = calendarManager.converter.ancientTbl[leapMonthVal][1]
            print("閏月(\(leapMonthVal)月)のテーブル値: \(leapMonthTabValue)")
        }
        
        // 前日の旧暦日付を計算
        if day > 1 {
            // 同じ月内で前日に移動
            calendarManager.day = day - 1
            print("同じ月内で前日に移動します: \(day-1)日")
        } else if isCurrentLeapMonth {
            // 閏月の初日から通常月の末日へ
            // ここが重要: 両方のフラグを確実に同期
            calendarManager.nowLeapMonth = false
            calendarManager.isLeapMonth = 0
            
            // 通常月の日数を取得
            let normalMonthIndex = month - 1
            let prevMonthIndex = normalMonthIndex - 1
            
            // インデックスが有効範囲内かチェック
            if prevMonthIndex >= 0 && normalMonthIndex < 14 {
                let normalMonthDays = calendarManager.converter.ancientTbl[normalMonthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
                calendarManager.day = normalMonthDays
                print("閏\(month)月初日から通常\(month)月末日へ移動: \(month)月\(normalMonthDays)日")
            } else {
                // 範囲外の場合はデフォルト値
                calendarManager.day = 30
                print("閏\(month)月初日から通常\(month)月末日へ移動: \(month)月30日（デフォルト値）")
            }
        } else if month > 1 {
            // 通常月の初日から前月末日へ
            let prevMonth = month - 1
            
            // デバッグ情報：leapMonthとprevMonthの関係
            print("leapMonth = \(leapMonth), prevMonth = \(prevMonth)")
            
            // 前月のテーブル情報を取得
            let prevMonthIndex = prevMonth - 1
            if prevMonthIndex >= 0 && prevMonthIndex < 14 {
                let prevMonthTabValue = calendarManager.converter.ancientTbl[prevMonthIndex][1]
                print("前月のテーブル値: \(prevMonthTabValue)")
            }
            
            // 前月が閏月かどうかを確認（正確な判定のため追加処理）
            if prevMonth == leapMonth {
                // 前月が閏月の場合、閏月設定で前月に移動
                calendarManager.month = prevMonth
                
                // ここが重要: 両方のフラグを確実に設定
                calendarManager.nowLeapMonth = true
                calendarManager.isLeapMonth = -1
                
                // 閏月の日数を取得
                // 閏月の日数計算は特殊：leapMonth+1インデックスから閏月の日数を引く
                guard let leapMonthIndex = leapMonth else {
                    print("⚠️ 閏月が設定されていません")
                    return
                }
                let nextMonthIndex = leapMonthIndex + 1
                
                if nextMonthIndex < 14 {
                    let leapMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[leapMonthIndex][0]
                    calendarManager.day = leapMonthDays
                    print("前月は閏月です。閏月末日へ移動: 閏\(prevMonth)月\(leapMonthDays)日")
                } else {
                    // 範囲外エラー時のデフォルト値
                    calendarManager.day = 30
                    print("前月は閏月です。閏月末日へ移動: 閏\(prevMonth)月30日（デフォルト値）")
                }
            } else {
                // 通常の前月移動
                calendarManager.month = prevMonth
                
                // ここが重要: 両方のフラグを確実にリセット
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                
                // 通常月の日数を取得
                let prevMonthIndex = prevMonth - 1
                let prevPrevMonthIndex = prevMonthIndex - 1
                
                if prevPrevMonthIndex >= 0 && prevMonthIndex < 14 {
                    let prevMonthDays = calendarManager.converter.ancientTbl[prevMonthIndex][0] - calendarManager.converter.ancientTbl[prevPrevMonthIndex][0]
                    calendarManager.day = prevMonthDays
                    print("通常の前月末日へ移動: \(prevMonth)月\(prevMonthDays)日")
                } else {
                    // 範囲外エラー時のデフォルト値
                    calendarManager.day = 30
                    print("通常の前月末日へ移動: \(prevMonth)月30日（デフォルト値）")
                }
            }
        } else if month == 1 && day == 1 {
            // 1月1日から前年12月末日へ
            calendarManager.year = year - 1
            calendarManager.month = 12
            
            // 旧暦テーブルを前年に拡張
            calendarManager.converter.tblExpand(inYear: year - 1)
            
            // 前年の閏月情報を確認
            let prevYearLeapMonth = calendarManager.converter.leapMonth
            print("前年の閏月: \(prevYearLeapMonth)月")
            
            // 前年12月が閏月かどうか確認
            if prevYearLeapMonth == 12 {
                // 前年12月が閏月の場合、閏12月に設定（両方のフラグを設定）
                calendarManager.nowLeapMonth = true
                calendarManager.isLeapMonth = -1
                print("前年12月は閏月です。閏12月末日へ移動します")
            } else {
                // 閏月でない場合は明示的にフラグをリセット（両方のフラグをリセット）
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
            }
            
            // 12月（または閏12月）の日数を取得
            let monthIndex = calendarManager.nowLeapMonth ? 12 : 11  // インデックスは0から始まるため調整
            let prevMonthIndex = monthIndex - 1
            
            if prevMonthIndex >= 0 && monthIndex < 14 {
                let monthDays = calendarManager.converter.ancientTbl[monthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
                calendarManager.day = monthDays
                print("前年12月\(calendarManager.nowLeapMonth ? "(閏)" : "")末日: \(monthDays)日に移動")
            } else {
                // 範囲外エラー時のデフォルト値
                calendarManager.day = 30
                print("前年12月\(calendarManager.nowLeapMonth ? "(閏)" : "")末日: 30日に移動（デフォルト値）")
            }
        } else {
            // 想定外の状況: 安全のためデフォルト処理
            print("⚠️ 想定外の日付状態です: \(year)年\(isCurrentLeapMonth ? "閏" : "")\(month)月\(day)日")
            if day > 1 {
                calendarManager.day = day - 1
            } else {
                calendarManager.day = 1
            }
        }
        
        // 旧暦から新暦への変換も更新
        calendarManager.initScheduleViewController()
        
        // 移動後のデバッグ情報を表示
        let resultYear = calendarManager.year ?? 0
        let resultMonth = calendarManager.month ?? 0
        let resultDay = calendarManager.day ?? 0
        let resultIsLeap = calendarManager.nowLeapMonth
        
        print("旧暦モード - 前日移動完了: \(resultYear)年\(resultIsLeap ? "閏" : "")\(resultMonth)月\(resultDay)日")
        print("移動後の閏月状態: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        
        if let gregorianYear = calendarManager.gregorianYear,
           let gregorianMonth = calendarManager.gregorianMonth,
           let gregorianDay = calendarManager.gregorianDay {
            print("  対応する新暦: \(gregorianYear)年\(gregorianMonth)月\(gregorianDay)日")
        }
        
        // 最終チェック：閏月フラグの整合性を確認
        if calendarManager.nowLeapMonth != ((calendarManager.isLeapMonth ?? 0) < 0) {
            print("⚠️ 警告：移動後にフラグの不一致があります: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        }
    }

    /** ツールバーアクション（次の日へ） */
    @IBAction func nextDayAction(_ sender: UIBarButtonItem) {
        print("次の日へ")
        
        // カレンダーモードに応じた処理
        if calendarManager.calendarMode == 1 {
            // 新暦モード: 通常の日付計算
            moveToNextDay()
        } else {
            // 旧暦モード: 閏月も考慮した旧暦日付移動
            moveToAncientNextDay()
        }
        
        // 表示を更新
        setupDisplay()
    }
    
    /** 新暦モードでの次日移動 */
    private func moveToNextDay() {
        // 現在の日を保存
        guard let currentYear = calendarManager.year,
              let currentMonth = calendarManager.month,
              let currentDay = calendarManager.day else {
            return
        }
        
        // 翌日を計算
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonth
        dateComponents.day = currentDay
        
        // 現在の日付のDateオブジェクトを作成
        let calendar = Calendar.current
        guard let currentDate = calendar.date(from: dateComponents) else {
            return
        }
        
        // 1日後のDateオブジェクトを計算
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
            return
        }
        
        // 日付コンポーネントを取得
        let nextComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
        
        // カレンダーマネージャーに設定
        calendarManager.comps = nextComponents
        calendarManager.year = nextComponents.year
        calendarManager.month = nextComponents.month
        calendarManager.day = nextComponents.day
        
        print("新暦モード - 次日: \(nextComponents.year ?? 0)年\(nextComponents.month ?? 0)月\(nextComponents.day ?? 0)日")
    }
    
    /** 旧暦モードでの次日移動（閏月考慮） - 完全修正版 */
    private func moveToAncientNextDay() {
        guard let year = calendarManager.year,
              let month = calendarManager.month,
              let day = calendarManager.day else {
            return
        }
        
        // 現在が閏月かどうか - 両方のフラグを確認して整合性を取る
        let isCurrentLeapMonth = calendarManager.nowLeapMonth && ((calendarManager.isLeapMonth ?? 0) < 0)
        
        // フラグの不一致があれば修正（このタイミングで修正しておく）
        if calendarManager.nowLeapMonth != ((calendarManager.isLeapMonth ?? 0) < 0) {
            print("⚠️ 閏月フラグの不一致を修正します: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
            if calendarManager.nowLeapMonth {
                calendarManager.isLeapMonth = -1
            } else {
                calendarManager.isLeapMonth = 0
            }
        }
        
        // 閏月の情報を取得
        let leapMonth = calendarManager.converter.leapMonth
        
        print("旧暦モード - 次日移動開始: \(year)年\(isCurrentLeapMonth ? "閏" : "")\(month)月\(day)日")
        print("現在の年の閏月: \(leapMonth)月")
        
        // 旧暦テーブルから月のインデックスを取得（閏月処理のため重要）
        let monthIndex: Int
        
        // 通常の月と閏月でインデックスが異なる
        if isCurrentLeapMonth {
            // 閏月の場合は特別なインデックス処理（leapMonthと同じインデックスを使用）
            guard let leapMonthVal = leapMonth else {
                print("⚠️ 閏月が設定されていません")
                return
            }
            monthIndex = leapMonthVal
            
            // ancientTblのテーブル構造を確認（デバッグ出力）
            print("閏月index = \(monthIndex), ancientTbl[\(monthIndex)][1] = \(calendarManager.converter.ancientTbl[monthIndex][1])")
            if monthIndex + 1 < 14 {
                print("次月index = \(monthIndex+1), ancientTbl[\(monthIndex+1)][1] = \(calendarManager.converter.ancientTbl[monthIndex+1][1])")
            }
        } else {
            // 通常月の場合は月と同じインデックス
            monthIndex = month - 1
            
            // テーブル構造を確認（デバッグ出力）
            print("通常月index = \(monthIndex), ancientTbl[\(monthIndex)][1] = \(calendarManager.converter.ancientTbl[monthIndex][1])")
            if monthIndex + 1 < 14 {
                print("次index = \(monthIndex+1), ancientTbl[\(monthIndex+1)][1] = \(calendarManager.converter.ancientTbl[monthIndex+1][1])")
            }
        }
        
        // 現在月の日数を取得
        var currentMonthDays: Int
        if isCurrentLeapMonth {
            // 閏月の日数を取得
            guard let leapMonthVal = leapMonth else {
                print("⚠️ 閏月が設定されていません")
                return
            }
            let nextMonthIndex = leapMonthVal + 1
            if nextMonthIndex < 14 {
                currentMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[leapMonthVal][0]
            } else {
                // 範囲外エラー時のデフォルト値
                currentMonthDays = 30
                print("⚠️ インデックス範囲外エラー: デフォルト日数30日を使用")
            }
        } else {
            // 通常月の日数を取得
            let prevMonthIndex = month - 1
            let nextMonthIndex = month
            
            // インデックスが有効範囲内かチェック
            if prevMonthIndex >= 0 && nextMonthIndex < 14 {
                currentMonthDays = calendarManager.converter.ancientTbl[nextMonthIndex][0] - calendarManager.converter.ancientTbl[prevMonthIndex][0]
            } else {
                // 範囲外の場合はデフォルト値
                currentMonthDays = 30
                print("⚠️ インデックス範囲外エラー: デフォルト日数30日を使用")
            }
        }
        
        print("現在月の日数: \(currentMonthDays)日")
        
        // 次日の旧暦日付を計算
        if day < currentMonthDays {
            // 同じ月内で次日に移動
            calendarManager.day = day + 1
            print("同じ月内で次日に移動します: \(month)月\(day + 1)日")
        } else {
            // 月末から次月初日に移動
            
            if isCurrentLeapMonth {
                // 閏月の最終日から通常の次月初日へ
                calendarManager.month = month + 1
                
                // ここが重要: 必ず閏月フラグをリセット（両方のフラグを同期）
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                
                print("閏\(month)月の最終日から通常の次月初日へ移動: \(month + 1)月1日")
            } else if month == leapMonth {
                // 月番号が閏月と一致する場合のみ、通常月から閏月へ移動
                // つまり、通常月の最終日から閏月初日へ（月番号はそのまま、閏フラグのみ変更）
                
                // 両方のフラグを確実に設定
                calendarManager.nowLeapMonth = true
                calendarManager.isLeapMonth = -1
                
                print("通常\(month)月の最終日から閏\(month)月初日へ移動")
            } else if month < 12 {
                // 通常の次月移動
                calendarManager.month = month + 1
                
                // 次の月が閏月かどうかチェック（通常は最初は通常月に設定）
                if month + 1 == leapMonth {
                    // 通常月にはっきり設定（閏月フラグをリセット）
                    calendarManager.nowLeapMonth = false
                    calendarManager.isLeapMonth = 0
                    print("注意: 次の月(\(month + 1)月)は閏月ですが、通常月を優先します")
                } else {
                    // 閏月でないことを明示（両方のフラグを確実にリセット）
                    calendarManager.nowLeapMonth = false
                    calendarManager.isLeapMonth = 0
                }
                
                print("通常の次月移動: \(month + 1)月1日")
            } else {
                // 次年の1月に移動
                calendarManager.year = year + 1
                calendarManager.month = 1
                
                // 閏月フラグを確実にリセット（両方のフラグを同期）
                calendarManager.nowLeapMonth = false
                calendarManager.isLeapMonth = 0
                
                // 旧暦テーブルを次年に拡張
                calendarManager.converter.tblExpand(inYear: year + 1)
                
                // 次年の閏月情報を確認（デバッグ用）
                let nextYearLeapMonth = calendarManager.converter.leapMonth
                print("次年の閏月: \(nextYearLeapMonth)月")
                
                // 次年1月が閏月かどうか確認
                if nextYearLeapMonth == 1 {
                    // 年が変わったときは常に通常月から始める
                    print("注意: 次年1月は閏月ですが、通常1月に移動します")
                }
                
                print("次年の1月に移動します: \(year + 1)年1月1日")
            }
            
            // 次月の初日は常に1日
            calendarManager.day = 1
        }
        
        // 旧暦から新暦への変換も更新（閏月状態が正しく設定されるように）
        calendarManager.initScheduleViewController()
        
        // 移動後のデバッグ情報を表示
        let resultYear = calendarManager.year ?? 0
        let resultMonth = calendarManager.month ?? 0
        let resultDay = calendarManager.day ?? 0
        let resultIsLeap = calendarManager.nowLeapMonth
        
        print("旧暦モード - 次日移動完了: \(resultYear)年\(resultIsLeap ? "閏" : "")\(resultMonth)月\(resultDay)日")
        print("移動後の閏月状態: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        
        if let gregorianYear = calendarManager.gregorianYear,
           let gregorianMonth = calendarManager.gregorianMonth,
           let gregorianDay = calendarManager.gregorianDay {
            print("  対応する新暦: \(gregorianYear)年\(gregorianMonth)月\(gregorianDay)日")
        }
        
        // 最終チェック：閏月フラグの整合性を確認
        if calendarManager.nowLeapMonth != ((calendarManager.isLeapMonth ?? 0) < 0) {
            print("⚠️ 警告：移動後にフラグの不一致があります: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        }
    }
    
    /** 閏月のナビゲーションテストを実行 */
    func runLeapMonthNavigationTest() {
        // デバッグヘルパーから閏月テストを実行
        print("閏月ナビゲーションテストを実行します")
        
        // 現在の状態を表示
        print("現在の旧暦: \(calendarManager.year ?? 0)年\(calendarManager.nowLeapMonth ? "閏" : "")\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日")
        print("閏月フラグ: nowLeapMonth=\(calendarManager.nowLeapMonth), isLeapMonth=\(calendarManager.isLeapMonth ?? 0)")
        print("現在の年の閏月: \(calendarManager.converter.leapMonth)月")
    }
    
    /** 画面表示を更新するヘルパーメソッド */
    private func setupDisplay() {
        // ScheduleViewController初期化
        calendarManager.initScheduleViewController()
        
        // イベントを再取得
        events = calendarManager.fetchEvent()
        
        // タイトルと日付の設定
        setScheduleTitle()
        
        // テーブルの再読み込み
        myTableView.reloadData()
        
        // 現在の状態をデバッグ出力
        print("画面表示更新 - 現在の状態:")
        print("- 現在のモード: \(calendarManager.calendarMode == 1 ? "新暦" : "旧暦")")
        print("- 年月日: \(calendarManager.year ?? 0)年\(calendarManager.month ?? 0)月\(calendarManager.day ?? 0)日")
        print("- 旧暦日付: \(calendarManager.ancientYear ?? 0)年\(calendarManager.ancientMonth ?? 0)月\(calendarManager.ancientDay ?? 0)日")
    }

    /** メモリ監視 */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** 画面が非表示になる前に呼ばれるメソッド */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 画面遷移の理由が「戻るボタン」によるものかを確認
        if isMovingFromParentViewController || isBeingDismissed {
            // カレンダーマネージャーに現在の状態を確実に保存
            if let year = calendarManager.year,
               let month = calendarManager.month,
               let day = calendarManager.day,
               let mode = calendarManager.calendarMode {
                
                // CalendarManagerに反映
                // （すでに設定されているはずだが、念のため明示的に設定）
                calendarManager.year = year
                calendarManager.month = month
                calendarManager.day = day
                calendarManager.calendarMode = mode
                
                // コンポーネントも更新
                var dateComponents = DateComponents()
                dateComponents.year = year
                dateComponents.month = month
                dateComponents.day = day
                calendarManager.comps = dateComponents
                
                // デリゲートに現在の日付とモードを通知
                delegate?.scheduleViewControllerDidUpdateDate(
                    year: year,
                    month: month, 
                    day: day,
                    mode: mode
                )
                
                print("詳細画面から戻る - 現在の状態を通知:")
                print("- 日付: \(year)年\(month)月\(day)日")
                print("- モード: \(mode == 1 ? "新暦" : "旧暦")")
                print("- CalendarManagerに状態を保存しました")
            } else {
                print("日付情報が不完全なため通知をスキップします")
            }
        }
    }

}


