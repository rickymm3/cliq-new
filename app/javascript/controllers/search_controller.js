import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.timeout = null;
    console.log("SearchController connected");
  }

  search() {
    const query = this.inputTarget.value.trim();

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit(); // Automatically submits the form
    }, 200);
  }

  clearFormAndHideDropdown(event) {
    console.log("clearFormAndHideDropdown triggered!");

    // Prevent the default link behavior from interfering
    event.preventDefault();

    // Clear the search input
    this.inputTarget.value = "";

    // Hide the dropdown menu
    const dropdownMenu = document.querySelector("#cliq-search-results .dropdown-menu");
    if (dropdownMenu) {
      dropdownMenu.classList.remove("show");
    }

    // Trigger Turbo navigation
    const link = event.target.closest("a");
    if (link) {
      link.click();
    }
  }
}
