import { describe, it, expect, beforeEach } from "vitest"

// Mock Clarity contract functions
const mockContract = {
  experiences: new Map(),
  bookings: new Map(),
  nextExperienceId: 1,
  nextBookingId: 1,
  
  createExperience(provider, title, description, price, duration, maxParticipants, location) {
    const experienceId = this.nextExperienceId++
    
    this.experiences.set(experienceId, {
      provider,
      title,
      description,
      price,
      duration,
      maxParticipants,
      location,
      active: true,
    })
    
    return { success: true, experienceId }
  },
  
  bookExperience(tourist, experienceId, experienceDate, participants) {
    const experience = this.experiences.get(experienceId)
    if (!experience) {
      return { error: "not-found" }
    }
    
    if (!experience.active) {
      return { error: "invalid-status" }
    }
    
    if (participants > experience.maxParticipants) {
      return { error: "invalid-status" }
    }
    
    const bookingId = this.nextBookingId++
    const totalPrice = experience.price * participants
    
    this.bookings.set(bookingId, {
      experienceId,
      tourist,
      provider: experience.provider,
      bookingDate: Date.now(),
      experienceDate,
      participants,
      totalPrice,
      status: "pending",
      paymentHeld: totalPrice,
    })
    
    return { success: true, bookingId }
  },
  
  confirmBooking(provider, bookingId) {
    const booking = this.bookings.get(bookingId)
    if (!booking) {
      return { error: "not-found" }
    }
    
    if (provider !== booking.provider) {
      return { error: "unauthorized" }
    }
    
    if (booking.status !== "pending") {
      return { error: "invalid-status" }
    }
    
    booking.status = "confirmed"
    return { success: true }
  },
  
  completeBooking(user, bookingId) {
    const booking = this.bookings.get(bookingId)
    if (!booking) {
      return { error: "not-found" }
    }
    
    if (user !== booking.tourist && user !== booking.provider) {
      return { error: "unauthorized" }
    }
    
    if (booking.status !== "confirmed") {
      return { error: "invalid-status" }
    }
    
    booking.status = "completed"
    return { success: true }
  },
  
  getExperience(experienceId) {
    return this.experiences.get(experienceId) || null
  },
  
  getBooking(bookingId) {
    return this.bookings.get(bookingId) || null
  },
}

describe("Booking Coordination Contract", () => {
  beforeEach(() => {
    mockContract.experiences.clear()
    mockContract.bookings.clear()
    mockContract.nextExperienceId = 1
    mockContract.nextBookingId = 1
  })
  
  describe("Experience Creation", () => {
    it("should create new experience", () => {
      const result = mockContract.createExperience(
          "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
          "Historic Walking Tour",
          "Explore the historic downtown area",
          50,
          120,
          10,
          "Downtown Historic District",
      )
      
      expect(result.success).toBe(true)
      expect(result.experienceId).toBe(1)
      
      const experience = mockContract.getExperience(1)
      expect(experience.title).toBe("Historic Walking Tour")
      expect(experience.price).toBe(50)
    })
  })
  
  describe("Booking Process", () => {
    beforeEach(() => {
      mockContract.createExperience(
          "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
          "Historic Walking Tour",
          "Explore the historic downtown area",
          50,
          120,
          10,
          "Downtown Historic District",
      )
    })
    
    it("should allow booking experience", () => {
      const result = mockContract.bookExperience(
          "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
          1,
          Date.now() + 86400000, // tomorrow
          2,
      )
      
      expect(result.success).toBe(true)
      expect(result.bookingId).toBe(1)
      
      const booking = mockContract.getBooking(1)
      expect(booking.participants).toBe(2)
      expect(booking.totalPrice).toBe(100)
      expect(booking.status).toBe("pending")
    })
    
    it("should prevent booking with too many participants", () => {
      const result = mockContract.bookExperience(
          "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
          1,
          Date.now() + 86400000,
          15, // exceeds max of 10
      )
      
      expect(result.error).toBe("invalid-status")
    })
    
    it("should allow provider to confirm booking", () => {
      mockContract.bookExperience("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG", 1, Date.now() + 86400000, 2)
      
      const result = mockContract.confirmBooking("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM", 1)
      
      expect(result.success).toBe(true)
      
      const booking = mockContract.getBooking(1)
      expect(booking.status).toBe("confirmed")
    })
    
    it("should allow completion by tourist or provider", () => {
      mockContract.bookExperience("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG", 1, Date.now() + 86400000, 2)
      
      mockContract.confirmBooking("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM", 1)
      
      const result = mockContract.completeBooking("ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG", 1)
      
      expect(result.success).toBe(true)
      
      const booking = mockContract.getBooking(1)
      expect(booking.status).toBe("completed")
    })
  })
})
