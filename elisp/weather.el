

;;; ==========================================

;;; 城市天气预报系统 - 三种选项，异步获取
;;; ==========================================

(require 'url)
(require 'json)
(require 'org)
(require 'async)

;;; 1. 配置变量
(defcustom weather-api-provider 'open-meteo
  "天气API提供商，可选 'open-meteo 或 'openweather"
  :type '(choice (const :tag "Open-Meteo" open-meteo)
                 (const :tag "OpenWeather" openweather)
                 (const :tag "WeatherAPI" weatherapi))
  :group 'weather)

(defcustom weather-forecast-days 5
  "天气预报天数，可选 3 或 5 天"
  :type '(choice (const :tag "3天" 3)
                 (const :tag "5天" 5))
  :group 'weather)

(defcustom weather-units "metric"
  "温度单位，可选 'metric（摄氏度）或 'imperial（华氏度）"
  :type '(choice (const :tag "摄氏度" metric)
                 (const :tag "华氏度" imperial))
  :group 'weather)

(defcustom weather-show-icons t
  "是否显示天气图标"
  :type 'boolean
  :group 'weather)

;; API密钥配置
(defcustom openweather-api-key ""
  "OpenWeather API密钥，从 https://openweathermap.org/api 获取"
  :type 'string
  :group 'weather)

(defcustom weatherapi-api-key ""
  "WeatherAPI.com API密钥，从 https://www.weatherapi.com 获取"
  :type 'string
  :group 'weather)

;;; 2. 城市配置
(defvar weather-cities
  '(("北京"     "39.9042"   "116.4074")
    ("上海"     "31.2304"   "121.4737")
    ("广州"     "23.1291"   "113.2644")
    ("深圳"     "22.5431"   "114.0579")
    ("杭州"     "30.2741"   "120.1551")
    ("成都"     "30.5728"   "104.0668")
    ("南京"     "32.0603"   "118.7969")
    ("西安"     "34.3416"   "108.9398")
    ("武汉"     "30.5928"   "114.3055")
    ("重庆"     "29.5630"   "106.5516"))
  "城市列表：名称 纬度 经度")

;;; 3. 预设选项定义
(defun weather-set-option-a ()
  "设置选项a: 3天 WeatherAPI"
  (interactive)
  (setq weather-api-provider 'weatherapi)
  (setq weather-forecast-days 3)
  (message "已设置为选项a: 3天 WeatherAPI")
  (weather-quick-show))

(defun weather-set-option-b ()
  "设置选项b: 5天 OpenWeather"
  (interactive)
  (setq weather-api-provider 'openweather)
  (setq weather-forecast-days 5)
  (message "已设置为选项b: 5天 OpenWeather")
  (weather-quick-show))

(defun weather-set-option-c ()
  "设置选项c: 5天 Open-Meteo (默认)"
  (interactive)
  (setq weather-api-provider 'open-meteo)
  (setq weather-forecast-days 5)
  (message "已设置为选项c: 5天 Open-Meteo (默认)")
  (weather-quick-show))

;;; 4. 异步获取管理
(defvar weather-async-jobs nil
  "异步任务列表")

(defvar weather-async-results nil
  "异步获取结果")

(defvar weather-async-callback nil
  "异步完成回调函数")

;;; 5. API URL生成函数
(defun weather--get-api-url (lat lon)
  "根据选择的API提供商返回API URL"
  (cond
   ((eq weather-api-provider 'open-meteo)
    (format "https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,weathercode&timezone=auto&forecast_days=%d"
            lat lon weather-forecast-days))
   
   ((eq weather-api-provider 'openweather)
    (if (string-empty-p openweather-api-key)
        (error "请先设置OpenWeather API密钥")
      (format "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&appid=%s&units=%s&cnt=%d"
              lat lon openweather-api-key weather-units
              (* weather-forecast-days 8))))  ; OpenWeather返回3小时间隔，每天8个数据点
   
   ((eq weather-api-provider 'weatherapi)
    (if (string-empty-p weatherapi-api-key)
        (error "请先设置WeatherAPI API密钥")
      (format "https://api.weatherapi.com/v1/forecast.json?key=%s&q=%s,%s&days=%d&aqi=no&alerts=no"
              weatherapi-api-key lat lon weather-forecast-days)))
   
   (t (error "未知的API提供商"))))

;;; 6. 数据解析函数
(defun weather--parse-open-meteo-data (json-data)
  "解析Open-Meteo返回的JSON数据"
  (let* ((daily (cdr (assoc 'daily json-data)))
         (time (cdr (assoc 'time daily)))
         (temp-max (cdr (assoc 'temperature_2m_max daily)))
         (temp-min (cdr (assoc 'temperature_2m_min daily)))
         (precip (cdr (assoc 'precipitation_sum daily)))
         (prob (cdr (assoc 'precipitation_probability_max daily)))
         (weathercode (cdr (assoc 'weathercode daily))))
    (cl-loop for i from 0 below (min (length time) weather-forecast-days)
             collect (list
                      (aref time i)
                      (aref temp-max i)
                      (aref temp-min i)
                      (aref precip i)
                      (aref prob i)
                      (aref weathercode i)))))

(defun weather--parse-openweather-data (json-data)
  "解析OpenWeather返回的JSON数据"
  (let* ((list-data (cdr (assoc 'list json-data)))
         (daily-data (make-hash-table :test 'equal))
         (days-collected 0))
    
    ;; 按日期分组
    (dolist (item list-data)
      (when (< days-collected weather-forecast-days)
        (let* ((dt (cdr (assoc 'dt item)))
               (date (format-time-string "%Y-%m-%d" (seconds-to-time dt)))
               (main (cdr (assoc 'main item)))
               (temp (cdr (assoc 'temp main)))
               (temp-min (cdr (assoc 'temp_min main)))
               (temp-max (cdr (assoc 'temp_max main)))
               (pop (cdr (assoc 'pop item)))  ; 降雨概率
               (weather (car (cdr (assoc 'weather item))))
               (weather-id (cdr (assoc 'id weather)))
               (rain (cdr (assoc 'rain item)))
               (rain-3h (if rain (cdr (assoc '3h rain)) 0.0)))
          
          (unless (gethash date daily-data)
            (puthash date (list date temp-max temp-min rain-3h (* 100 pop) weather-id) daily-data)
            (cl-incf days-collected))
          
          (let ((current (gethash date daily-data)))
            ;; 更新最高温和最低温
            (setf (nth 1 current) (max (nth 1 current) temp))
            (setf (nth 2 current) (min (nth 2 current) temp))
            ;; 更新降雨概率
            (setf (nth 4 current) (max (nth 4 current) (* 100 pop)))
            (puthash date current daily-data)))))
    
    ;; 转换为列表并按日期排序
    (let ((result nil))
      (maphash (lambda (key value) (push value result)) daily-data)
      (sort result (lambda (a b) (string< (car a) (car b)))))))

(defun weather--parse-weatherapi-data (json-data)
  "解析WeatherAPI返回的JSON数据"
  (let* ((forecast (cdr (assoc 'forecast json-data)))
         (forecastday (cdr (assoc 'forecastday forecast)))
         (daily-data nil))
    
    (dotimes (i (min (length forecastday) weather-forecast-days))
      (let* ((day (aref forecastday i))
             (date (cdr (assoc 'date day)))
             (day-data (cdr (assoc 'day day)))
             (temp-max (cdr (assoc 'maxtemp_c day-data)))
             (temp-min (cdr (assoc 'mintemp_c day-data)))
             (precip (cdr (assoc 'totalprecip_mm day-data)))
             (prob (cdr (assoc 'daily_chance_of_rain day-data)))
             (condition (cdr (assoc 'condition day-data)))
             (weather-code (cdr (assoc 'code condition))))
        
        (push (list date temp-max temp-min precip prob weather-code) daily-data)))
    
    (reverse daily-data)))

(defun weather--get-weather-icon (weathercode)
  "根据天气代码返回对应的图标"
  (cond
   ((eq weather-api-provider 'open-meteo)
    (cond
     ((<= weathercode 1) "☀️")   ; 晴
     ((<= weathercode 2) "⛅")   ; 少云
     ((<= weathercode 3) "☁️")   ; 多云
     ((<= weathercode 48) "🌫️") ; 雾
     ((<= weathercode 55) "🌧️") ; 小雨
     ((<= weathercode 65) "🌧️") ; 中雨
     ((<= weathercode 75) "❄️")  ; 雪
     ((<= weathercode 77) "🌨️") ; 霰
     ((<= weathercode 82) "⛈️")  ; 雷暴
     ((<= weathercode 86) "🌨️") ; 雪
     ((<= weathercode 99) "⛈️")  ; 雷暴
     (t "❓")))
   
   ((eq weather-api-provider 'openweather)
    (cond
     ((<= weathercode 299) "⛈️")   ; 雷阵雨
     ((<= weathercode 399) "🌧️")   ; 细雨
     ((<= weathercode 499) "🌧️")   ; 中雨
     ((<= weathercode 599) "🌧️")   ; 大雨
     ((<= weathercode 699) "🌨️")   ; 雪
     ((<= weathercode 799) "🌫️")   ; 大气现象
     ((= weathercode 800) "☀️")     ; 晴
     ((<= weathercode 801) "⛅")    ; 少云
     ((<= weathercode 802) "☁️")    ; 散云
     ((<= weathercode 804) "☁️")    ; 阴天
     (t "❓")))
   
   ((eq weather-api-provider 'weatherapi)
    (cond
     ((= weathercode 1000) "☀️")   ; 晴
     ((= weathercode 1003) "⛅")   ; 部分多云
     ((= weathercode 1006) "☁️")   ; 多云
     ((= weathercode 1009) "☁️")   ; 阴天
     ((<= weathercode 1030) "🌫️") ; 雾
     ((<= weathercode 1063) "🌧️") ; 小雨
     ((<= weathercode 1180) "🌧️") ; 小雨
     ((<= weathercode 1186) "🌧️") ; 中雨
     ((<= weathercode 1192) "🌧️") ; 大雨
     ((<= weathercode 1201) "🌧️") ; 暴雨
     ((<= weathercode 1237) "🌨️") ; 冰雹
     ((<= weathercode 1264) "🌨️") ; 雨夹雪
     ((<= weathercode 1276) "⛈️")  ; 雷暴
     (t "❓")))
   
   (t "❓")))

;;; 7. 异步获取函数
(defun weather-async-fetch-city (city)
  "异步获取单个城市天气数据"
  (let* ((name (car city))
         (lat (cadr city))
         (lon (caddr city))
         (url (weather--get-api-url lat lon))
         (data nil))
    
    (condition-case err
        (with-current-buffer (url-retrieve-synchronously url t t 10)
          (goto-char (point-min))
          (when (search-forward-regexp "^$" nil t)
            (let ((json-data (json-read-from-string
                              (buffer-substring (point) (point-max)))))
              (kill-buffer (current-buffer))
              (setq data json-data))))
      (error
       (message "获取 %s 天气数据失败: %s" name (error-message-string err))
       nil))
    
    (when data
      (let ((parsed-data
             (cond
              ((eq weather-api-provider 'open-meteo)
               (weather--parse-open-meteo-data data))
              ((eq weather-api-provider 'openweather)
               (weather--parse-openweather-data data))
              ((eq weather-api-provider 'weatherapi)
               (weather--parse-weatherapi-data data))
              (t nil))))
        (when parsed-data
          (list name parsed-data))))))

(defun weather-async-fetch-cities (cities callback)
  "异步获取多个城市天气数据"
  (let ((results (make-hash-table :test 'equal))
        (total (length cities))
        (completed 0))
    
    (dolist (city cities)
      (async-start
       `(lambda ()
          (require 'url)
          (require 'json)
          (let ((result (weather-async-fetch-city ',city)))
            (cons ',(car city) result)))
       (lambda (result)
         (let ((city-name (car result))
               (city-data (cdr result)))
           (puthash city-name city-data results)
           (cl-incf completed)
           
           (message "已获取 %d/%d 个城市天气数据" completed total)
           
           (when (= completed total)
             ;; 按原始顺序整理结果
             (let ((ordered-results nil))
               (dolist (city cities)
                 (let ((city-name (car city))
                       (city-data (gethash city-name results)))
                   (when city-data
                     (push city-data ordered-results))))
               (setq ordered-results (reverse ordered-results))
               
               (funcall callback ordered-results)
               (message "所有城市天气数据获取完成！")))))))))

;;; 8. 显示函数
(defun weather-display-table (cities-data)
  "显示天气表格"
  (let ((buffer (get-buffer-create "*天气预报*")))
    (with-current-buffer buffer
      (erase-buffer)
      (org-mode)
      
      ;; 标题
      (insert (format "#+TITLE: %d天天气预报 - 使用 %s\n" 
                      weather-forecast-days
                      (cond
                       ((eq weather-api-provider 'open-meteo) "Open-Meteo")
                       ((eq weather-api-provider 'openweather) "OpenWeather")
                       ((eq weather-api-provider 'weatherapi) "WeatherAPI")
                       (t "未知API"))))
      (insert (format "#+AUTHOR: Emacs Weather System (单位: %s)\n"
                      (if (string= weather-units "metric") "摄氏度" "华氏度")))
      (insert (format "#+DATE: %s\n" (format-time-string "%Y年%m月%d日")))
      (insert "#+OPTIONS: ^:nil\n")
      (insert "\n")
      
      ;; 创建表格
      (if weather-show-icons
          (insert "| 城市 | 日期 | 天气 | 最高温 | 最低温 | 降水量 | 降雨概率 |\n")
        (insert "| 城市 | 日期 | 最高温 | 最低温 | 降水量 | 降雨概率 |\n"))
      
      (if weather-show-icons
          (insert "|------+------+------+--------+--------+---------+----------|\n")
        (insert "|------+------+--------+--------+---------+----------|\n"))
      
      (dolist (city-data cities-data)
        (let ((city-name (car city-data))
              (daily-data (cdr city-data)))
          (dolist (day daily-data)
            (let* ((date (nth 0 day))
                   (temp-max (nth 1 day))
                   (temp-min (nth 2 day))
                   (precip (nth 3 day))
                   (prob (nth 4 day))
                   (weathercode (nth 5 day))
                   (icon (if weather-show-icons 
                             (weather--get-weather-icon weathercode) "")))
              
              (if weather-show-icons
                  (insert (format "| %s | %s | %s | " 
                                  city-name date icon))
                (insert (format "| %s | %s | " 
                                city-name date)))
              
              ;; 温度
              (insert (format "%s | %s | " 
                              (if temp-max 
                                  (format "%.1f°%s" temp-max
                                          (if (string= weather-units "metric") "C" "F"))
                                "N/A")
                              (if temp-min
                                  (format "%.1f°%s" temp-min
                                          (if (string= weather-units "metric") "C" "F"))
                                "N/A")))
              
              ;; 降水量
              (insert (format "%s | " 
                              (if precip (format "%.2f mm" precip) "0.00 mm")))
              
              ;; 降雨概率着色
              (if (and prob (>= prob 30))
                  (progn
                    (insert (propertize (format "%.0f%%" prob)
                                        'face '(:foreground "#ff5555" :weight bold)))
                    (insert " |\n"))
                (insert (format "%.0f%% |\n" (or prob 0))))))))
      
      (insert "\n")
      
      ;; 添加脚注
      (insert "#+BEGIN_COMMENT\n")
      (insert "* 说明：\n")
      (insert (format "1. 数据来源: %s\n" 
                      (cond
                       ((eq weather-api-provider 'open-meteo) "Open-Meteo API")
                       ((eq weather-api-provider 'openweather) "OpenWeather API")
                       ((eq weather-api-provider 'weatherapi) "WeatherAPI.com")
                       (t "未知")))
              (insert (format "2. 预报天数: %d 天\n" weather-forecast-days))
              (insert (format "3. 温度单位: %s\n" 
                              (if (string= weather-units "metric") "摄氏度" "华氏度")))
              (insert "4. 降雨概率 ≥ 30% 时显示为红色\n")
              (insert (format "5. 更新于: %s\n" (format-time-string "%Y-%m-%d %H:%M:%S")))
              
              (when (eq weather-api-provider 'openweather)
                (insert "6. OpenWeather 降水量为3小时累计值\n"))
              
              (insert "#+END_COMMENT\n")
              
              ;; 设置缓冲区属性
              (setq buffer-read-only t)
              (setq truncate-lines t)
              (visual-line-mode 1)
              (goto-char (point-min)))
      
      (display-buffer buffer))))

;;; 9. 主命令
(defun weather-show-multi-cities-async (city-count)
  "异步显示多个城市天气"
  (interactive "n显示几个城市的天气? (最大%d): ")
  (let* ((max-count (length weather-cities))
         (count (min city-count max-count))
         (cities (cl-subseq weather-cities 0 count)))
    
    (message "正在从 %s 异步获取 %d 个城市天气数据..." 
             (symbol-name weather-api-provider) count)
    
    (weather-async-fetch-cities
     cities
     (lambda (results)
       (if results
           (weather-display-table results)
         (message "获取天气数据失败，请检查网络连接或API配置。"))))))

(defun weather-show-all-cities-async ()
  "异步显示所有预设城市天气"
  (interactive)
  (weather-show-multi-cities-async (length weather-cities)))

;;; 10. 配置函数
(defun weather-set-provider (provider)
  "设置天气API提供商"
  (interactive
   (list (completing-read "选择API提供商: "
                          '("open-meteo" "openweather" "weatherapi")
                          nil t)))
  (setq weather-api-provider (intern provider))
  (message "已设置天气API提供商为: %s" provider))

(defun weather-set-forecast-days (days)
  "设置天气预报天数"
  (interactive
   (list (completing-read "选择预报天数: "
                          '("3" "5")
                          nil t)))
  (setq weather-forecast-days (string-to-number days))
  (message "已设置天气预报天数为: %d 天" weather-forecast-days))

(defun weather-set-openweather-key (key)
  "设置OpenWeather API密钥"
  (interactive "sOpenWeather API密钥: ")
  (setq openweather-api-key key)
  (message "已设置OpenWeather API密钥"))

(defun weather-set-weatherapi-key (key)
  "设置WeatherAPI API密钥"
  (interactive "sWeatherAPI.com API密钥: ")
  (setq weatherapi-api-key key)
  (message "已设置WeatherAPI.com API密钥"))

(defun weather-switch-units ()
  "切换温度单位"
  (interactive)
  (if (string= weather-units "metric")
      (setq weather-units "imperial")
    (setq weather-units "metric"))
  (message "已切换温度单位为: %s" 
           (if (string= weather-units "metric") "摄氏度" "华氏度")))

(defun weather-toggle-icons ()
  "切换是否显示天气图标"
  (interactive)
  (setq weather-show-icons (not weather-show-icons))
  (message "天气图标显示: %s" (if weather-show-icons "开启" "关闭")))

;;; 11. 快捷命令
(defun weather-quick-show ()
  "快速显示天气（异步）"
  (interactive)
  (weather-show-all-cities-async))

;;; 12. 选项菜单
(defun weather-show-options-menu ()
  "显示选项菜单"
  (interactive)
  (let ((buffer (get-buffer-create "*天气选项*")))
    (with-current-buffer buffer
      (erase-buffer)
      (insert "#+TITLE: 天气预报选项\n")
      (insert "\n")
      
      (insert "* 当前设置\n")
      (insert (format "- API提供商: %s\n" 
                      (cond
                       ((eq weather-api-provider 'open-meteo) "Open-Meteo")
                       ((eq weather-api-provider 'openweather) "OpenWeather")
                       ((eq weather-api-provider 'weatherapi) "WeatherAPI")
                       (t "未知"))))
      (insert (format "- 预报天数: %d 天\n" weather-forecast-days))
      (insert (format "- 温度单位: %s\n" 
                      (if (string= weather-units "metric") "摄氏度" "华氏度")))
      (insert (format "- 显示图标: %s\n" (if weather-show-icons "是" "否")))
      
      (insert "\n* 预设选项\n")
      (insert "1. 选项a: 3天 WeatherAPI (需要API密钥)\n")
      (insert "2. 选项b: 5天 OpenWeather (需要API密钥)\n")
      (insert "3. 选项c: 5天 Open-Meteo (默认，无需API密钥)\n")
      
      (insert "\n* 使用方法\n")
      (insert "- 按数字键 1, 2, 3 选择预设选项\n")
      (insert "- 按字母键自定义设置:\n")
      (insert "  p - 选择API提供商\n")
      (insert "  d - 选择预报天数\n")
      (insert "  u - 切换温度单位\n")
      (insert "  i - 切换图标显示\n")
      (insert "  s - 显示天气\n")
      (insert "  q - 退出\n")
      
      (local-set-key (kbd "1") 'weather-set-option-a)
      (local-set-key (kbd "2") 'weather-set-option-b)
      (local-set-key (kbd "3") 'weather-set-option-c)
      (local-set-key (kbd "p") 'weather-set-provider)
      (local-set-key (kbd "d") 'weather-set-forecast-days)
      (local-set-key (kbd "u") 'weather-switch-units)
      (local-set-key (kbd "i") 'weather-toggle-icons)
      (local-set-key (kbd "s") 'weather-quick-show)
      (local-set-key (kbd "q") (lambda () (interactive) (bury-buffer)))
      
      (org-mode)
      (setq buffer-read-only t)
      (goto-char (point-min)))
    (display-buffer buffer)))

;;; 13. 初始化
(defun weather-init ()
  "初始化天气系统"
  (message "天气系统已加载")
  (weather-check-api-availability))

(defun weather-check-api-availability ()
  "检查API可用性"
  (interactive)
  (message "正在检查 %s API可用性..." (symbol-name weather-api-provider))
  
  (cond
   ((and (eq weather-api-provider 'openweather)
         (string-empty-p openweather-api-key))
    (message "警告: OpenWeather需要API密钥，请先设置"))
   
   ((and (eq weather-api-provider 'weatherapi)
         (string-empty-p weatherapi-api-key))
    (message "警告: WeatherAPI需要API密钥，请先设置"))
   
   (t
    (async-start
     `(lambda ()
        (require 'url)
        (require 'json)
        (let ((test-city '("北京" "39.9042" "116.4074")))
          (weather-async-fetch-city test-city)))
     (lambda (result)
       (if result
           (message "%s API连接正常" (symbol-name weather-api-provider))
         (message "警告: 无法连接到 %s API" (symbol-name weather-api-provider))))))))

;; 延迟初始化
(run-with-idle-timer 2 nil 'weather-init)

;;; 14. 全局快捷键
(global-set-key (kbd "C-c w w") 'weather-quick-show)
(global-set-key (kbd "C-c w o") 'weather-show-options-menu)
(global-set-key (kbd "C-c w a") 'weather-set-option-a)
(global-set-key (kbd "C-c w b") 'weather-set-option-b)
(global-set-key (kbd "C-c w c") 'weather-set-option-c)

;;; 15. 提供模式
(provide 'weather)