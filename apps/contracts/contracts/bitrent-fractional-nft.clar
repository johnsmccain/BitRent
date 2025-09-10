;; BitRent Fractional NFT Contract
;; Enables fractional ownership of rental properties

(define-constant CONTRACT_OWNER tx-sender)
(define-constant TOTAL_SUPPLY u1000) ;; 1000 fractions per property
(define-constant MIN_FRACTION_PRICE u1000000) ;; 1 STX minimum

;; Property data structure
;; NOTE: define-data-var requires 3 args: name, type, initial-value (literal/const)
(define-data-var property-data (string-ascii 100) "")
(define-data-var property-owner principal CONTRACT_OWNER)
(define-data-var total-fractions uint TOTAL_SUPPLY)
(define-data-var fraction-price uint MIN_FRACTION_PRICE)
(define-data-var is-listed bool false)

;; NFT metadata
(define-non-fungible-token bitrent-property (string-ascii 100))

;; Fraction ownership mapping
(define-map fraction-owners principal u1000)

;; Events (use print for portability)

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u1001))
(define-constant ERR-INSUFFICIENT-FRACTIONS (err u1002))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u1003))
(define-constant ERR-PROPERTY-NOT-LISTED (err u1004))
(define-constant ERR-INVALID-PRICE (err u1005))

;; Public functions

;; List a property for fractional ownership
(define-public (list-property (property-id (string-ascii 100)) (price u1000000))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-UNAUTHORIZED)
    (asserts! (> price MIN_FRACTION_PRICE) ERR-INVALID-PRICE)
    (data-var-set property-data property-id)
    (data-var-set property-owner tx-sender)
    (data-var-set total-fractions TOTAL_SUPPLY)
    (data-var-set fraction-price price)
    (data-var-set is-listed true)
    (ok (print (tuple (event "property-listed") (property-id property-id) (owner tx-sender) (price price))))
  )
)

;; Purchase fractions of a property
(define-public (purchase-fractions (property-id (string-ascii 100)) (amount u1000))
  (let ((payment (* amount (data-var-get fraction-price))))
    (begin
      (asserts! (data-var-get is-listed) ERR-PROPERTY-NOT-LISTED)
      (asserts! (>= (data-var-get total-fractions) amount) ERR-INSUFFICIENT-FRACTIONS)
      (asserts! (>= tx-amount payment) ERR-INSUFFICIENT-PAYMENT)
      
      ;; Update ownership
      (map-set fraction-owners tx-sender (+ (default-to u0 (map-get? fraction-owners tx-sender)) amount))
      (data-var-set total-fractions (- (data-var-get total-fractions) amount))
      
      ;; Transfer STX to property owner
      (stx-transfer? payment tx-sender (data-var-get property-owner))
      
      ;; Mint NFT if this is the first fraction
      (if (is-eq (map-get? fraction-owners tx-sender) amount)
        (nft-mint? bitrent-property property-id tx-sender)
        (ok true)
      )
      
      (ok (print (tuple (event "fraction-purchased") (buyer tx-sender) (property-id property-id) (amount amount))))
    )
  )
)

;; Sell fractions back
(define-public (sell-fractions (property-id (string-ascii 100)) (amount u1000))
  (let ((refund (* amount (data-var-get fraction-price))))
    (begin
      (asserts! (data-var-get is-listed) ERR-PROPERTY-NOT-LISTED)
      (asserts! (>= (default-to u0 (map-get? fraction-owners tx-sender)) amount) ERR-INSUFFICIENT-FRACTIONS)
      
      ;; Update ownership
      (map-set fraction-owners tx-sender (- (map-get? fraction-owners tx-sender) amount))
      (data-var-set total-fractions (+ (data-var-get total-fractions) amount))
      
      ;; Transfer STX back to seller
      (stx-transfer? refund (data-var-get property-owner) tx-sender)
      
      ;; Burn NFT if no fractions left
      (if (is-eq (map-get? fraction-owners tx-sender) u0)
        (nft-burn? bitrent-property property-id tx-sender)
        (ok true)
      )
      
      (ok (print (tuple (event "fraction-sold") (seller tx-sender) (property-id property-id) (amount amount))))
    )
  )
)

;; Get property information
(define-read-only (get-property-info (property-id (string-ascii 100)))
  (ok (tuple
    (owner (data-var-get property-owner))
    (total-fractions (data-var-get total-fractions))
    (fraction-price (data-var-get fraction-price))
    (is-listed (data-var-get is-listed))
  ))
)

;; Get user's fraction balance
(define-read-only (get-user-fractions (user principal))
  (ok (default-to u0 (map-get? fraction-owners user)))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok TOTAL_SUPPLY)
)

;; Contract owner functions

;; Update fraction price
(define-public (update-fraction-price (new-price u1000000))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-UNAUTHORIZED)
    (asserts! (> new-price MIN_FRACTION_PRICE) ERR-INVALID-PRICE)
    (data-var-set fraction-price new-price)
    (ok true)
  )
)

;; Delist property
(define-public (delist-property)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-UNAUTHORIZED)
    (data-var-set is-listed false)
    (ok true)
  )
)
