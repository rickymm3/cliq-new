import { Controller } from "@hotwired/stimulus"

// Controls the collapsible/sticky sidebars on the cliq show page.
export default class extends Controller {
  static targets = [
    "leftSide",
    "rightSide",
    "leftToggle",
    "rightToggle",
    "mobileToggle"
  ]

  connect() {
    this.LEFT_BREAKPOINT = 992
    this.RIGHT_BREAKPOINT = 1200

    this._onResize = this.updateBreakpoints.bind(this)
    window.addEventListener("resize", this._onResize)

    // Seed manual state so responsive logic has consistent values
    if (!this.leftSideTarget.dataset.manualCollapsed) {
      this.leftSideTarget.dataset.manualCollapsed = "false"
    }
    if (!this.rightSideTarget.dataset.manualCollapsed) {
      this.rightSideTarget.dataset.manualCollapsed = "false"
    }

    this.updateBreakpoints()
    this.updateToggleIcons()
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize)
  }

  toggleLeft() {
    this.toggleSide(this.leftSideTarget, "left")
  }

  toggleRight() {
    this.toggleSide(this.rightSideTarget, "right")
  }

  toggleMobile() {
    const wasCollapsed = this.leftSideTarget.classList.contains("is-collapsed")
    if (wasCollapsed) {
      this.leftSideTarget.dataset.manualCollapsed = "false"
      this.leftSideTarget.classList.remove("is-collapsed")
      this.element.classList.remove("has-left-collapsed")
    } else {
      this.leftSideTarget.dataset.manualCollapsed = "true"
      this.leftSideTarget.classList.add("is-collapsed")
      this.element.classList.add("has-left-collapsed")
    }

    this.updateToggleIcons()
    this.updateMobileToggleVisibility()
  }

  toggleSide(side, name) {
    const isCollapsed = side.classList.contains("is-collapsed")

    if (isCollapsed) {
      side.classList.remove("is-collapsed")
      side.dataset.manualCollapsed = "false"
      this.element.classList.remove(`has-${name}-collapsed`)
    } else {
      side.classList.add("is-collapsed")
      side.dataset.manualCollapsed = "true"
      this.element.classList.add(`has-${name}-collapsed`)
    }

    this.updateToggleIcons()
    this.updateMobileToggleVisibility()
  }

  updateBreakpoints() {
    const width = window.innerWidth || document.documentElement.clientWidth

    this.applyAutoState(this.rightSideTarget, "right", false)
    this.applyAutoState(this.leftSideTarget, "left", width < this.LEFT_BREAKPOINT)

    this.updateToggleIcons()
    this.updateMobileToggleVisibility()
  }

  applyAutoState(side, name, shouldOverlay) {
    if (!side) return

    side.dataset.autoCollapsed = shouldOverlay ? "true" : "false"

    if (shouldOverlay) {
      side.classList.add("is-overlay")
      const manualOpen = side.dataset.manualCollapsed === "false"
      if (!manualOpen) {
        side.classList.add("is-collapsed")
        this.element.classList.add(`has-${name}-collapsed`)
      } else {
        side.classList.remove("is-collapsed")
        this.element.classList.remove(`has-${name}-collapsed`)
      }
    } else {
      side.classList.remove("is-overlay")
      const manualCollapsed = side.dataset.manualCollapsed === "true"
      if (manualCollapsed) {
        side.classList.add("is-collapsed")
        this.element.classList.add(`has-${name}-collapsed`)
      } else {
        side.classList.remove("is-collapsed")
        this.element.classList.remove(`has-${name}-collapsed`)
      }
    }
  }

  updateToggleIcons() {
    if (this.hasLeftToggleTarget) {
      const icon = this.leftToggleTarget.querySelector("i")
      if (icon) {
        const collapsed = this.leftSideTarget.classList.contains("is-collapsed")
        icon.className = collapsed ? "bi bi-chevron-right" : "bi bi-chevron-left"
      }
    }

    if (this.hasRightToggleTarget) {
      const icon = this.rightToggleTarget.querySelector("i")
      if (icon) {
        const collapsed = this.rightSideTarget.classList.contains("is-collapsed")
        icon.className = collapsed ? "bi bi-chevron-left" : "bi bi-chevron-right"
      }
    }

    if (this.hasMobileToggleTarget) {
      const icon = this.mobileToggleTarget.querySelector("i")
      const label = this.mobileToggleTarget.querySelector("span")
      const collapsed = this.leftSideTarget.classList.contains("is-collapsed")

      if (icon) {
        icon.className = collapsed ? "bi bi-layout-sidebar-inset" : "bi bi-x-lg"
      }
      if (label) {
        label.textContent = collapsed ? "Panels" : "Close"
      }
    }
  }

  updateMobileToggleVisibility() {
    if (!this.hasMobileToggleTarget) return
    const width = window.innerWidth || document.documentElement.clientWidth
    const shouldShow = width < this.LEFT_BREAKPOINT
    this.mobileToggleTarget.classList.toggle("d-none", !shouldShow)
  }
}
