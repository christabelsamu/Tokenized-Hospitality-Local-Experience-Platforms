;; Booking Coordination Contract
;; Manages experience bookings between tourists and providers

(define-constant err-not-found (err u200))
(define-constant err-invalid-status (err u201))
(define-constant err-unauthorized (err u202))
(define-constant err-insufficient-payment (err u203))

;; Booking statuses
(define-constant status-pending "pending")
(define-constant status-confirmed "confirmed")
(define-constant status-completed "completed")
(define-constant status-cancelled "cancelled")

;; Experience listings
(define-map experiences
  { experience-id: uint }
  {
    provider: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    price: uint,
    duration: uint,
    max-participants: uint,
    location: (string-ascii 100),
    active: bool
  }
)

;; Bookings
(define-map bookings
  { booking-id: uint }
  {
    experience-id: uint,
    tourist: principal,
    provider: principal,
    booking-date: uint,
    experience-date: uint,
    participants: uint,
    total-price: uint,
    status: (string-ascii 20),
    payment-held: uint
  }
)

;; Counters
(define-data-var next-experience-id uint u1)
(define-data-var next-booking-id uint u1)

;; Create experience listing
(define-public (create-experience
  (title (string-ascii 100))
  (description (string-ascii 500))
  (price uint)
  (duration uint)
  (max-participants uint)
  (location (string-ascii 100))
)
  (let ((experience-id (var-get next-experience-id)))
    (map-set experiences
      { experience-id: experience-id }
      {
        provider: tx-sender,
        title: title,
        description: description,
        price: price,
        duration: duration,
        max-participants: max-participants,
        location: location,
        active: true
      }
    )
    (var-set next-experience-id (+ experience-id u1))
    (ok experience-id)
  )
)

;; Book experience
(define-public (book-experience (experience-id uint) (experience-date uint) (participants uint))
  (let (
    (booking-id (var-get next-booking-id))
    (experience (unwrap! (map-get? experiences { experience-id: experience-id }) err-not-found))
    (total-price (* (get price experience) participants))
  )
    (asserts! (get active experience) err-invalid-status)
    (asserts! (<= participants (get max-participants experience)) err-invalid-status)

    (map-set bookings
      { booking-id: booking-id }
      {
        experience-id: experience-id,
        tourist: tx-sender,
        provider: (get provider experience),
        booking-date: block-height,
        experience-date: experience-date,
        participants: participants,
        total-price: total-price,
        status: status-pending,
        payment-held: total-price
      }
    )
    (var-set next-booking-id (+ booking-id u1))
    (ok booking-id)
  )
)

;; Confirm booking (provider only)
(define-public (confirm-booking (booking-id uint))
  (let ((booking (unwrap! (map-get? bookings { booking-id: booking-id }) err-not-found)))
    (asserts! (is-eq tx-sender (get provider booking)) err-unauthorized)
    (asserts! (is-eq (get status booking) status-pending) err-invalid-status)

    (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: status-confirmed })
    )
    (ok true)
  )
)

;; Complete booking
(define-public (complete-booking (booking-id uint))
  (let ((booking (unwrap! (map-get? bookings { booking-id: booking-id }) err-not-found)))
    (asserts! (or (is-eq tx-sender (get tourist booking)) (is-eq tx-sender (get provider booking))) err-unauthorized)
    (asserts! (is-eq (get status booking) status-confirmed) err-invalid-status)

    (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: status-completed })
    )
    (ok true)
  )
)

;; Get experience details
(define-read-only (get-experience (experience-id uint))
  (map-get? experiences { experience-id: experience-id })
)

;; Get booking details
(define-read-only (get-booking (booking-id uint))
  (map-get? bookings { booking-id: booking-id })
)
