import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];

  connect() {
    console.log("SearchController connected"); // Debug log
    this.timeout = null;
  }

  search() {
    console.log("Search triggered:", this.inputTarget.value); // Debug log
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit(); // Submits the form automatically
    }, 300); // Debounce delay
  }

  clear() {
    console.log("Search cleared"); // Debug log
    this.inputTarget.value = "";
    this.resultsTarget.innerHTML = "";
  }
}
