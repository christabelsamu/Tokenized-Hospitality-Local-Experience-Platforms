;; Cultural Authenticity Contract
;; Ensures authentic cultural experiences

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u400))
(define-constant err-not-found (err u401))
(define-constant err-invalid-score (err u402))
(define-constant err-unauthorized (err u403))

;; Cultural authenticity assessments
(define-map authenticity-assessments
  { experience-id: uint }
  {
    assessor: principal,
    cultural-accuracy-score: uint,
    historical-accuracy-score: uint,
    local-community-involvement: uint,
    traditional-practices-score: uint,
    overall-authenticity-score: uint,
    assessment-date: uint,
    verified: bool,
    comments: (string-ascii 500)
  }
)

;; Cultural experts registry
(define-map cultural-experts
  { expert: principal }
  {
    name: (string-ascii 50),
    credentials: (string-ascii 200),
    specialization: (string-ascii 100),
    verified: bool,
    assessment-count: uint
  }
)

;; Community feedback
(define-map community-feedback
  { experience-id: uint, reviewer: principal }
  {
    authenticity-rating: uint,
    cultural-respect-rating: uint,
    community-benefit-rating: uint,
    feedback-text: (string-ascii 300),
    review-date: uint
  }
)

;; Register cultural expert
(define-public (register-expert
  (name (string-ascii 50))
  (credentials (string-ascii 200))
  (specialization (string-ascii 100))
)
  (let ((expert tx-sender))
    (ok (map-set cultural-experts
      { expert: expert }
      {
        name: name,
        credentials: credentials,
        specialization: specialization,
        verified: false,
        assessment-count: u0
      }
    ))
  )
)

;; Verify cultural expert (admin only)
(define-public (verify-expert (expert principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (map-get? cultural-experts { expert: expert })) err-not-found)

    (map-set cultural-experts
      { expert: expert }
      (merge (unwrap-panic (map-get? cultural-experts { expert: expert }))
        { verified: true }
      )
    )
    (ok true)
  )
)

;; Submit authenticity assessment
(define-public (assess-authenticity
  (experience-id uint)
  (cultural-accuracy uint)
  (historical-accuracy uint)
  (community-involvement uint)
  (traditional-practices uint)
  (comments (string-ascii 500))
)
  (let (
    (assessor tx-sender)
    (expert-data (unwrap! (map-get? cultural-experts { expert: assessor }) err-unauthorized))
    (overall-score (/ (+ cultural-accuracy (+ historical-accuracy (+ community-involvement traditional-practices))) u4))
  )
    (asserts! (get verified expert-data) err-unauthorized)
    (asserts! (and (<= cultural-accuracy u100) (<= historical-accuracy u100) (<= community-involvement u100) (<= traditional-practices u100)) err-invalid-score)

    (map-set authenticity-assessments
      { experience-id: experience-id }
      {
        assessor: assessor,
        cultural-accuracy-score: cultural-accuracy,
        historical-accuracy-score: historical-accuracy,
        local-community-involvement: community-involvement,
        traditional-practices-score: traditional-practices,
        overall-authenticity-score: overall-score,
        assessment-date: block-height,
        verified: true,
        comments: comments
      }
    )

    ;; Update expert assessment count
    (map-set cultural-experts
      { expert: assessor }
      (merge expert-data { assessment-count: (+ (get assessment-count expert-data) u1) })
    )

    (ok overall-score)
  )
)

;; Submit community feedback
(define-public (submit-community-feedback
  (experience-id uint)
  (authenticity-rating uint)
  (cultural-respect-rating uint)
  (community-benefit-rating uint)
  (feedback-text (string-ascii 300))
)
  (let ((reviewer tx-sender))
    (asserts! (and (<= authenticity-rating u5) (<= cultural-respect-rating u5) (<= community-benefit-rating u5)) err-invalid-score)
    (asserts! (and (>= authenticity-rating u1) (>= cultural-respect-rating u1) (>= community-benefit-rating u1)) err-invalid-score)

    (ok (map-set community-feedback
      { experience-id: experience-id, reviewer: reviewer }
      {
        authenticity-rating: authenticity-rating,
        cultural-respect-rating: cultural-respect-rating,
        community-benefit-rating: community-benefit-rating,
        feedback-text: feedback-text,
        review-date: block-height
      }
    ))
  )
)

;; Get authenticity assessment
(define-read-only (get-authenticity-assessment (experience-id uint))
  (map-get? authenticity-assessments { experience-id: experience-id })
)

;; Get expert profile
(define-read-only (get-expert (expert principal))
  (map-get? cultural-experts { expert: expert })
)

;; Get community feedback
(define-read-only (get-community-feedback (experience-id uint) (reviewer principal))
  (map-get? community-feedback { experience-id: experience-id, reviewer: reviewer })
)
