//
//  PrivacyVC.swift
//  ZhangBu_original
//
//  Created by Kiichi Ikeda on 2021/09/17.
//  Copyright © 2021 net.Chee-Saga. All rights reserved.
//

import UIKit

class PrivacyVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    private let titles: [String] = ["プライバシーポリシー","利用規約"]
    var showMode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = titles[showMode]
//        textView.font = UIFont(name: textView.font!.fontName, size: 20)
        textView.text = showMode == 0 ? privacyPolicy : userPolicy
    }
    
    var privacyPolicy = """
    池天（以下，「開発者」といいます。）は，本アプリ上で提供するサービス（以下,「本サービス」といいます。）におけるプライバシー情報の取扱いについて，以下のとおりプライバシーポリシー（以下，「本ポリシー」といいます。）を定めます。

    第1条（プライバシー情報）

    プライバシー情報のうち「個人情報」とは，個人情報保護法にいう「個人情報」を指すものとし，生存する個人に関する情報であって，当該情報に含まれる氏名，生年月日，住所，電話番号，連絡先その他の記述等により特定の個人を識別できる情報を指します。
    プライバシー情報のうち「履歴情報および特性情報」とは，上記に定める「個人情報」以外のものをいい，ご利用いただいたサービスやご購入いただいた商品，ご覧になったページや広告の履歴，ユーザーが検索された検索キーワード，ご利用日時，ご利用の方法，ご利用環境，郵便番号や性別，職業，年齢，ユーザーのIPアドレス，クッキー情報，位置情報，端末の個体識別情報などを指します。
    第２条（プライバシー情報の収集方法）

    開発者は，ユーザーが利用登録をする際に氏名，生年月日，住所，電話番号，メールアドレス，銀行口座番号，クレジットカード番号，運転免許証番号などの個人情報をお尋ねすることがあります。また，ユーザーと提携先などとの間でなされたユーザーの個人情報を含む取引記録や，決済に関する情報を開発者の提携先（情報提供元，広告主，広告配信先などを含みます。以下，｢提携先｣といいます。）などから収集することがあります。
    開発者は，ユーザーについて，利用したサービスやソフトウエア，購入した商品，閲覧したページや広告の履歴，検索した検索キーワード，利用日時，利用方法，利用環境（携帯端末を通じてご利用の場合の当該端末の通信状態，利用に際しての各種設定情報なども含みます），IPアドレス，クッキー情報，位置情報，端末の個体識別情報などの履歴情報および特性情報を，ユーザーが開発者や提携先のサービスを利用しまたはページを閲覧する際に収集します。
    第３条（個人情報を収集・利用する目的）

    開発者が個人情報を収集・利用する目的は，以下のとおりです。

    （1）ユーザーに自分の登録情報の閲覧や修正，利用状況の閲覧を行っていただくために，氏名，住所，連絡先，支払方法などの登録情報，利用されたサービスや購入された商品，およびそれらの代金などに関する情報を表示する目的
    （2）ユーザーにお知らせや連絡をするためにメールアドレスを利用する場合やユーザーに商品を送付したり必要に応じて連絡したりするため，氏名や住所などの連絡先情報を利用する目的
    （3）ユーザーの本人確認を行うために，氏名，生年月日，住所，電話番号，銀行口座番号，クレジットカード番号，運転免許証番号，配達証明付き郵便の到達結果などの情報を利用する目的
    （4）ユーザーに代金を請求するために，購入された商品名や数量，利用されたサービスの種類や期間，回数，請求金額，氏名，住所，銀行口座番号やクレジットカード番号などの支払に関する情報などを利用する目的
    （5）ユーザーが簡便にデータを入力できるようにするために，開発者に登録されている情報を入力画面に表示させたり，ユーザーのご指示に基づいて他のサービスなど（提携先が提供するものも含みます）に転送したりする目的
    （6）代金の支払を遅滞したり第三者に損害を発生させたりするなど，本サービスの利用規約に違反したユーザーや，不正・不当な目的でサービスを利用しようとするユーザーの利用をお断りするために，利用態様，氏名や住所など個人を特定するための情報を利用する目的
    （7）ユーザーからのお問い合わせに対応するために，お問い合わせ内容や代金の請求に関する情報など開発者がユーザーに対してサービスを提供するにあたって必要となる情報や，ユーザーのサービス利用状況，連絡先情報などを利用する目的
    （8）上記の利用目的に付随する目的
    第４条（個人情報の第三者提供）

    開発者は，次に掲げる場合を除いて，あらかじめユーザーの同意を得ることなく，第三者に個人情報を提供することはありません。ただし，個人情報保護法その他の法令で認められる場合を除きます。
    （1）法令に基づく場合
    （2）人の生命，身体または財産の保護のために必要がある場合であって，本人の同意を得ることが困難であるとき
    （3）公衆衛生の向上または児童の健全な育成の推進のために特に必要がある場合であって，本人の同意を得ることが困難であるとき
    （4）国の機関もしくは地方公共団体またはその委託を受けた者が法令の定める事務を遂行することに対して協力する必要がある場合であって，本人の同意を得ることにより当該事務の遂行に支障を及ぼすおそれがあるとき
    （5）予め次の事項を告知あるいは公表をしている場合
    利用目的に第三者への提供を含むこと
    第三者に提供されるデータの項目
    第三者への提供の手段または方法
    本人の求めに応じて個人情報の第三者への提供を停止すること
    前項の定めにかかわらず，次に掲げる場合は第三者には該当しないものとします。
    （1）開発者が利用目的の達成に必要な範囲内において個人情報の取扱いの全部または一部を委託する場合
    （2）合併その他の事由による事業の承継に伴って個人情報が提供される場合
    （3）個人情報を特定の者との間で共同して利用する場合であって，その旨並びに共同して利用される個人情報の項目，共同して利用する者の範囲，利用する者の利用目的および当該個人情報の管理について責任を有する者の氏名または名称について，あらかじめ本人に通知し，または本人が容易に知り得る状態に置いているとき
    第５条（個人情報の開示）

    開発者は，本人から個人情報の開示を求められたときは，本人に対し，遅滞なくこれを開示します。ただし，開示することにより次のいずれかに該当する場合は，その全部または一部を開示しないこともあり，開示しない決定をした場合には，その旨を遅滞なく通知します。なお，個人情報の開示に際しては，１件あたり１，０００円の手数料を申し受けます。
    （1）本人または第三者の生命，身体，財産その他の権利利益を害するおそれがある場合
    （2）開発者の業務の適正な実施に著しい支障を及ぼすおそれがある場合
    （3）その他法令に違反することとなる場合
    前項の定めにかかわらず，履歴情報および特性情報などの個人情報以外の情報については，原則として開示いたしません。
    第６条（個人情報の訂正および削除）

    ユーザーは，開発者の保有する自己の個人情報が誤った情報である場合には，開発者が定める手続きにより，開発者に対して個人情報の訂正または削除を請求することができます。
    開発者は，ユーザーから前項の請求を受けてその請求に応じる必要があると判断した場合には，遅滞なく，当該個人情報の訂正または削除を行い，これをユーザーに通知します。
    第７条（個人情報の利用停止等）

    開発者は，本人から，個人情報が，利用目的の範囲を超えて取り扱われているという理由，または不正の手段により取得されたものであるという理由により，その利用の停止または消去（以下，「利用停止等」といいます。）を求められた場合には，遅滞なく必要な調査を行い，その結果に基づき，個人情報の利用停止等を行い，その旨本人に通知します。ただし，個人情報の利用停止等に多額の費用を有する場合その他利用停止等を行うことが困難な場合であって，本人の権利利益を保護するために必要なこれに代わるべき措置をとれる場合は，この代替策を講じます。

    第８条（プライバシーポリシーの変更）

    本ポリシーの内容は，ユーザーに通知することなく，変更することができるものとします。
    開発者が別途定める場合を除いて，変更後のプライバシーポリシーは，本ウェブサイトに掲載したときから効力を生じるものとします。
    """
    
    private let userPolicy = """
    この利用規約（以下，「本規約」といいます。）は，池天（以下，「開発者」といいます。）がこのアプリ上で提供するサービス（以下，「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下，「ユーザー」といいます。）には，本規約に従って，本サービスをご利用いただきます。

    第1条（適用）
    1. 本規約は，ユーザーと開発者との間の本サービスの利用に関わる一切の関係に適用されるものとします。
    2. 開発者は本サービスに関し，本規約のほか，ご利用にあたってのルール等，各種の定め（以下，「個別規定」といいます。）をすることがあります。これら個別規定はその名称のいかんに関わらず，本規約の一部を構成するものとします。
    3. 本規約の規定が前条の個別規定の規定と矛盾する場合には，個別規定において特段の定めなき限り，個別規定の規定が優先されるものとします。

    第2条（利用登録）
    1. 本サービスにおいては，登録希望者が本規約に同意の上，開発者の定める方法によって利用登録を申請し，開発者がこの承認を登録希望者に通知することによって，利用登録が完了するものとします。
    2. 開発者は，利用登録の申請者に以下の事由があると判断した場合，利用登録の申請を承認しないことがあり，その理由については一切の開示義務を負わないものとします。
    a. 利用登録の申請に際して虚偽の事項を届け出た場合
    b. 本規約に違反したことがある者からの申請である場合
    c. その他，開発者が利用登録を相当でないと判断した場合

    第3条（ユーザーIDおよびパスワードの管理）
    ユーザーは，自己の責任において，本サービスのユーザーIDおよびパスワードを適切に管理するものとします。
    ユーザーは，いかなる場合にも，ユーザーIDおよびパスワードを第三者に譲渡または貸与し，もしくは第三者と共用することはできません。開発者は，ユーザーIDとパスワードの組み合わせが登録情報と一致してログインされた場合には，そのユーザーIDを登録しているユーザー自身による利用とみなします。
    ユーザーID及びパスワードが第三者によって使用されたことによって生じた損害は，開発者に故意又は重大な過失がある場合を除き，開発者は一切の責任を負わないものとします。

    第4条（禁止事項）
    ユーザーは，本サービスの利用にあたり，以下の行為をしてはなりません。

    1. 法令または公序良俗に違反する行為
    2. 犯罪行為に関連する行為
    3. 開発者，本サービスの他のユーザー，または第三者のサーバーまたはネットワークの機能を破壊したり，妨害したりする行為
    4. 開発者のサービスの運営を妨害するおそれのある行為
    5. 他のユーザーに関する個人情報等を収集または蓄積する行為
    6. 不正アクセスをし，またはこれを試みる行為
    7. 他のユーザーに成りすます行為
    8. 開発者のサービスに関連して，反社会的勢力に対して直接または間接に利益を供与する行為
    9. 開発者，本サービスの他のユーザーまたは第三者の知的財産権，肖像権，プライバシー，名誉その他の権利または利益を侵害する行為
    """
}