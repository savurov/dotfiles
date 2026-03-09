; extends

; Match preferred Python keyword groups.
(["await" "in"] @keyword
  (#set! priority 130))

(["is"] @keyword.function
  (#set! priority 130))

(["or" "and" "not"] @keyword.function
  (#set! priority 130))
