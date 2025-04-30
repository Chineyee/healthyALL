;; Health Rewards System Smart Contract
;; Handles user health goals, achievements, and rewards distribution

;; Error codes
(define-constant ERR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERR-DUPLICATE-MEMBER-REGISTRATION (err u101))
(define-constant ERR-MEMBER-PROFILE-NOT-FOUND (err u102))
(define-constant ERR-INVALID-HEALTH-GOAL (err u103))
(define-constant ERR-INSUFFICIENT-REWARD-BALANCE (err u104))
(define-constant ERR-INVALID-REWARD-AMOUNT (err u105))
(define-constant ERR-INVALID-ACTIVITY-UNITS (err u106))
(define-constant ERR-INVALID-QUEST-ID (err u107))

;; Data variables
(define-data-var system-manager principal tx-sender)
(define-data-var total-reward-pool uint u0)
(define-data-var participant-count uint u0)

;; Data maps
(define-map member-profiles
    principal
    {
        wellness-score: uint,
        activity-count: uint,
        member-tier: uint,
        last-activity-time: uint,
        accrued-tokens: uint,
        active-quest-count: uint
    }
)

(define-map health-quests
    {member-address: principal, quest-id: uint}
    {
        activity-target: uint,
        activity-progress: uint,
        quest-expiration: uint,
        quest-completed: bool,
        token-reward: uint,
        activity-type: (string-ascii 20)
    }
)

(define-map member-achievements
    principal
    (list 10 (string-ascii 30))
)

;; Public functions

;; Initialize new user
(define-public (register-member)
    (let
        ((member-address tx-sender))
        (asserts! (is-none (map-get? member-profiles member-address)) (err ERR-DUPLICATE-MEMBER-REGISTRATION))
        (map-set member-profiles
            member-address
            {
                wellness-score: u0,
                activity-count: u0,
                member-tier: u1,
                last-activity-time: (unwrap-panic (get-block-info? time u0)),
                accrued-tokens: u0,
                active-quest-count: u0
            }
        )
        (var-set participant-count (+ (var-get participant-count) u1))
        (ok true)
    )
)

;; Set fitness goal
(define-public (start-health-quest (activity-target uint) (quest-expiration uint) (activity-type (string-ascii 20)))
    (let
        ((member-address tx-sender)
         (member-data (unwrap! (map-get? member-profiles member-address) ERR-MEMBER-PROFILE-NOT-FOUND))
         (quest-id (+ (get active-quest-count member-data) u1)))
        
        (asserts! (> activity-target u0) ERR-INVALID-HEALTH-GOAL)
        (asserts! (> quest-expiration (unwrap-panic (get-block-info? time u0))) ERR-INVALID-HEALTH-GOAL)
        (asserts! (<= (len activity-type) u20) ERR-INVALID-HEALTH-GOAL)
        
        (map-set health-quests
            {member-address: member-address, quest-id: quest-id}
            {
                activity-target: activity-target,
                activity-progress: u0,
                quest-expiration: quest-expiration,
                quest-completed: false,
                token-reward: (calculate-quest-reward activity-target),
                activity-type: activity-type
            }
        )
        
        (map-set member-profiles
            member-address
            (merge member-data {active-quest-count: quest-id})
        )
        (ok quest-id)
    )
)

;; Claim rewards for completed goals
(define-public (claim-quest-reward (quest-id uint))
    (let
        ((member-address tx-sender)
         (member-data (unwrap! (map-get? member-profiles member-address) ERR-MEMBER-PROFILE-NOT-FOUND)))
        
        (asserts! (<= quest-id (get active-quest-count member-data)) ERR-INVALID-QUEST-ID)
        
        (let
            ((quest-data (unwrap! (map-get? health-quests {member-address: member-address, quest-id: quest-id}) ERR-INVALID-QUEST-ID)))
            
            (asserts! (get quest-completed quest-data) ERR-INVALID-HEALTH-GOAL)
            (asserts! (>= (var-get total-reward-pool) (get token-reward quest-data)) ERR-INSUFFICIENT-REWARD-BALANCE)
            
            ;; Transfer rewards
            (var-set total-reward-pool (- (var-get total-reward-pool) (get token-reward quest-data)))
            (map-set member-profiles
                member-address
                (merge member-data {
                    accrued-tokens: (+ (get accrued-tokens member-data) (get token-reward quest-data))
                })
            )
            
            (ok (get token-reward quest-data))
        )
    )
)

;; Private functions

;; Calculate reward amount based on target
(define-private (calculate-quest-reward (activity-target uint))
    (let
        ((base-reward-rate u100))
        (* base-reward-rate (/ activity-target u100))
    )
)

;; Calculate points for activity
(define-private (calculate-wellness-points (activity-units uint))
    (* activity-units u10)
)

;; Calculate user level based on points
(define-private (calculate-member-tier (total-points uint))
    (+ u1 (/ total-points u1000))
)

;; Award achievement badge
(define-private (grant-achievement (member-address principal) (achievement-name (string-ascii 30)))
    (let
        ((existing-achievements (default-to (list) (map-get? member-achievements member-address))))
        (map-set member-achievements
            member-address
            (unwrap-panic (as-max-len? (append existing-achievements achievement-name) u10))
        )
    )
)

;; Read-only functions

;; Get user profile
(define-read-only (get-member-profile (member-address principal))
    (map-get? member-profiles member-address)
)

;; Get goal details
(define-read-only (get-quest-details (member-address principal) (quest-id uint))
    (map-get? health-quests {member-address: member-address, quest-id: quest-id})
)

;; Get user achievements
(define-read-only (get-member-achievements (member-address principal))
    (map-get? member-achievements member-address)
)

;; Get contract stats
(define-read-only (get-system-metrics)
    {
        total-members: (var-get participant-count),
        available-rewards: (var-get total-reward-pool)
    }
)

;; Administrative functions

;; Add funds to reward pool (only contract administrator)
(define-public (add-reward-tokens (token-amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get system-manager)) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (> token-amount u0) ERR-INVALID-REWARD-AMOUNT)
        (var-set total-reward-pool (+ (var-get total-reward-pool) token-amount))
        (ok true)
    )
)

;; Transfer contract ownership
(define-public (transfer-system-control (new-manager principal))
    (begin
        (asserts! (is-eq tx-sender (var-get system-manager)) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (not (is-eq new-manager (var-get system-manager))) ERR-UNAUTHORIZED-ACCESS)
        (var-set system-manager new-manager)
        (ok true)
    )
)