# DevOps là gì?

## I. DevOps là gì?

- DevOps là viết tắt của Development (Dev) và Operations (Ops). DevOps là một văn hóa làm việc kết hợp giữa kỹ sư phát triển phần mềm (dev) với bộ phận operator (kỹ sư hệ thống, nhân viên bảo mật, kỹ sư mạng, kỹ sư hạ tầng,...) nhằm mục đích rút ngắn vòng đời phát triển sản phẩm (SDLC).

Dưới đây sẽ giới thiệu về những điều cần biết để áp dụng DevOps, bao gồm:


- DevOps Culture : văn hóa làm việc kết hợp giữa Dev và Ops

- DevOps Practices : cách để thực hiện DevOps

- DevOps Tools : những Tools cần để thực hiện DevOps

- DevOps và Cloud : mối quan hệ giữa DevOps và cloud

## II. DevOps Culture

-  Khi có 1 team DevOps, những mục tiêu đạt đến cụ thể như sau:


- Fast time - to market (TTM) : code nhanh, deploy nhanh

- Few production failures : khi sản phẩm được đảm bảo về tính ổn định ngay từ đầu thì lỗi sẽ ít xảy ra hơn

- Immediate recovery from failures: không may nếu xảy ra lỗi, vì chúng ta có 1 team đầy đủ dev và ops nên có thể nhanh chóng nhận định nguyên nhân lỗi là do program hay do cấu trúc hệ thống,... và có thể nhanh chóng giải quyết vấn đề ngay lập tức.

- Trong DevOps culture, cả dev và operations đều phải quan tâm đến tính ổn định và tốc độ của sản phẩm.Vì thế, dev và operations sẽ phải làm việc cùng nhau, sử dụng những tools kiểm tra tốc độ và tính ổn định của sản phẩm, nhờ vậy mà có thể tạo ra những sản phẩm tốt hơn.

- Thử so sánh DevOps với mô hình làm việc truyền thống Traditional Silos, ta thấy như sau:

![image](https://user-images.githubusercontent.com/108709507/177276438-2e7d1fff-08c9-49fb-a923-45ae47f6f700.png)

- Ở mô hình Traditional Silos, dev viết code đưa sang QA test. QA phát hiện ra bug sẽ đưa cho dev fix, rồi chuyển lại cho QA để test. Quá trình này lặp đi lặp lại cho đến khi sản phẩm không còn bug, thì sẽ chuyển giao cho operation để deploy code lên môi trường. Lúc này, QA sẽ test lại lần nữa. Lúc này, nếu phát sinh ra bug thì nguyên nhân có thể là do code của dev viết sai hoặc do operation deploy sai. Với mô hình làm việc truyền thống, cách làm việc của mỗi team dev và operations như một “black-box”, không tin tưởng lẫn nhau, vì vậy việc tìm kiếm nguyên nhân lỗi sẽ mất thời gian hơn.

- Tuy nhiên, với DevOps, dev QA và operations là 1 team thống nhất cùng làm 1 sản phẩm, họ sẽ sử dụng các tools như Jenkins, docker,... để tạo ra một hệ thống automation từ khi build code, test đến khi deploy. Nếu xảy ra bug họ có thể nhanh chóng revert lại version cũ, cùng nhau tìm hiểu nguyên nhân, fix bug rồi deploy code mới lên lại.

## III. DevOps Concepts và những Practices

### 1.Build Automation

- Build Automation là một quy trình tự động để chuẩn bị source code deploy lên môi trường bằng cách sử dụng script hoặc tool. Tùy vào ngôn ngữ được sử dụng mà cần phải compile, transform hoặc thực hiện unit test,... đối với code. Thông thường build automation cũng giống như việc chạy một command - line tool để chạy doạn code đã được viết script hoặc được setting trong file config. Việc build automation không nên bị phụ thuộc vào IDE cũng như những config của máy tính. Nó có nghĩa là code của bạn có thể được build trên bất cứ PC nào, dù là của bạn hay của người khác.

- Vậy tại sao phải build automation? Trước tiên, build automation sẽ giúp tiết kiệm thời gian, có thể handle được những task cần phải build theo một quy trình nhất định nào đó. Việc build automation cũng đảm bảo code sẽ luôn được build theo một quy trình chuẩn, mà ko xảy ra lỗi do nhầm lẫn hay một nguyên nhân nào đó. Ngoài ra, build automation còn giúp thực hiện việc build code trên bất kỳ PC nào, bất cứ ai trong team cũng có thể làm được. Nó giống như việc bạn cho 1 file lên server shared và bất cứ ai có quyền cũng có thể truy cập, sử dụng file đó.


### 2. Continuous Intergration ( CI - Tích hợp liên tục)

- CI là phương pháp đòi hỏi các developer phải thường xuyên merge code thay đổi. Với cách làm việc truyền thống, các developer sẽ làm việc riêng biệt với nhau và sau một khoảng thời gian nhất định chẳng hạn như 1 tuần họ sẽ tiến hành merge code. Tuy nhiên, với CI thì developer phải merge code của họ mỗi ngày và sẽ chạy auto test để detect những vấn đề khi merge code. CI cũng được tự động hóa, và thông thường được hỗ trợ bở một CI Server. Khi developer commit source code thay đổi của họ lên, CI Server sẽ thấy sự thay đổi này và bắt đầu thực hiện build, test source code thay đổi một cách tự động. Quá trình này sẽ được thực hiện nhiều lần trong 1 ngày, và nếu CI server phát hiện có vấn đề xảy ra nó sẽ ngay lập tức hiển thị thông báo cho developer.

- Trường hợp có một người khác đưa code của họ lên và xảy ra lỗi trong quá trình build hệ thống sẽ thông báo lỗi cho người đó tiến hành fix, đồng thời sẽ rollback lại để không làm ảnh hưởng đến những người khác.

- Vậy lợi ích của CI là gì? Đầu tiên, CI sẽ giúp phát hiện ra bug sớm, thông báo cho developer. Developer có thể fix ngay lập tức hoặc rollback để không làm ảnh hưởng đến người khác. Tiếp theo, áp dụng CI sẽ giúp tránh việc phải merge một lượng code lớn khi release. Thay vào đó code sẽ được merge tự động mỗi ngày. Đồng thời, nhờ vào việcì code được merge mỗi ngày nên chúng ta có thể release thường xuyên chứ không cần chờ đến cuối giai đoạn khi tất cả mọi thứ đã xong xuôi mới có thể release được. Khi code được build liên tục nó cũng tạo ra Continuos Testing (Test liên tục), QA có thể test ngay lập tức những chỉnh sửa đã được đưa lên mà không cần chờ đến khi mọi thứ hoàn thành. CI tạo ra một thói quen tốt cho develop, việc thường xuyên commit sẽ làm developer viết ra những đoạn code đơn giản, đúng chuẩn ko rườm ra.

### 3. Continuous Delivery và Continuous Deployment

- Continuous Delivery (CD) là method đảm bảo code có thể được deploy bất cứ lúc nào. Thay vì phải quyết định có nên deploy code hay không thì team phải build, merge, test,… để đảm bảo code luôn ở trạng thái có thể deploy.

- Một số người khi nhắc đến Continuous Delivery thường viết tắt là CD, tuy nhiên cách gọi tắt này sẽ khiến nhầm lẫn giữa Continuous Delivery và Continuous Deployment.

- Continuous Deployment là một practice đảm bảo code thay đổi (có size nhỏ) được deploy liên tục lên product.

- Vậy Continuous Delivery và Continuous Deployment khác nhau như thế nào ? Continous Delivery đảm bảo cho code có thể deploy bất cứ lúc nào. Trong khi Continuous Deployment là deploy thực tế lên product nhiều lần trong ngày.

- 































































































































































