import { defineStore } from 'pinia';

export const usePortfolioStore = defineStore({
  id: 'portfolio-store',
  state: () => ({
    errors: {},
    hasNightMood: false,
    lightDarkClasses: {
      whitetextColorInDark: { dark: 'text-white', light: 'text-dark' },
      whiteBgWithOpacityInDark: { dark: 'bg-white-with-opacity', light: 'bg-black-with-opacity' },
      whitebgWithDarkTextInDark: { dark: 'bg-white  text-dark', light: 'bg-dark text-white' },
      darkTextInDark: { dark: 'text-dark', light: 'text-white' },
      whiteBorderBottomInDark: { dark: 'white-bottom-border', light: 'dark-bottom-border' },
      whiteBgInDark: { dark: 'bg-white', light: 'bg-dark' },
      darkBgInDark: { dark: 'bg-dark', light: 'bg-white' },
      lightBlueLinkInDark: { dark: 'light-blue', light: 'blue' }
    }
  }),
  getters: {
    getTheme() {
      return this.hasNightMood ? 'dark' : 'light';
    }
  },
  actions: {
  },
});
