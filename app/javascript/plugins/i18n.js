import {createI18n} from "vue-i18n";
import {en} from "@/locales/en.js";
import {fr} from "@/locales/fr.js";

export default createI18n({
  locale: 'en', // set locale
  fallbackLocale: 'en', // set fallback locale
  messages: {
    en: en,
    fr: fr,
  },
  datetimeFormats: {
    en: {
      short: {
        year: 'numeric',
        month: 'long',
        day: '2-digit'
      }
    },
    fr: {
      short: {
        year: 'numeric',
        month: 'long',
        day: '2-digit'
      }
    }
  }
})
