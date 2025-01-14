import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "ingredients",
    "description",
    "preparation",
    "recipeIngredients",
    "recipeError",
    "recipeContainer",
    "spinner",
    "level",
    "time",
    "generateButton"
  ]

  connect() {
    this.hideContent()
    this.hideSpinner()
    this.ingredientsTarget.textContent = "Type as many ingredients as you want..."
  }

  generate() {
    this.disableButton()
    const meta = document.querySelector('meta[name=csrf-token]');
    const token = meta && meta.getAttribute('content');

    this.hideContent()
    this.showSpinner()

    let result = fetch("/recipes/generate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        'X-CSRF-Token': token,
      },
      body: JSON.stringify({
        recipe: {
          ingredients: this.ingredientsTarget.value
        }
      })
    })
      .then(response => response.text())
      .then(responseText => this.render(JSON.parse(responseText)))
      .then(() => this.enableButton())
  }

  render({ recipe }) {
    this.hideSpinner()

    if (recipe.valid) {
      this.descriptionTarget.textContent = recipe.description
      this.preparationTarget.textContent = recipe.preparation
      this.levelTarget.textContent = recipe.level
      this.timeTarget.textContent = recipe.cooking_time
      this.populateList(recipe.ingredients)

      this.showContent()
    } else {
      this.showError(recipe.reason)
    }
  }

  populateList(ingredients) {
    this.recipeIngredientsTarget.innerHTML = ""
    ingredients.map(ingredient => {
      let item = document.createElement("li")
      let span = document.createElement("span")
      span.textContent = ingredient

      item.appendChild(span)
      this.recipeIngredientsTarget.appendChild(item)
    });
  }

  showSpinner() {
    this.spinnerTarget.hidden = false
  }

  hideSpinner() {
    this.spinnerTarget.hidden = true
  }

  showContent() {
    this.recipeContainerTarget.hidden = false
    this.recipeErrorTarget.hidden = true
  }

  hideContent() {
    this.recipeContainerTarget.hidden = true
    this.recipeErrorTarget.hidden = true
  }

  showError(message) {
    this.recipeContainerTarget.hidden = true
    this.recipeErrorTarget.hidden = false
    this.recipeErrorTarget.textContent = message
  }

  disableButton() {
    this.generateButtonTarget.disabled = true
  }

  enableButton() {
    this.generateButtonTarget.disabled = false
  }
}
