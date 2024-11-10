import '@mdi/font/css/materialdesignicons.css';
// import 'vuetify/styles';

// Vuetify
import { createVuetify } from "vuetify";
import { VuetifyDateAdapter } from 'vuetify/lib/composables/date/adapters/vuetify.mjs'
import * as components from 'vuetify/components'
import * as labs from "vuetify/labs/components";
import { aliases, mdi } from 'vuetify/iconsets/mdi'

const studio = {
  dark: false,
  colors: {
    background: '#FFFFFF',
    surface: '#FFFFFF',
    primary: "#FDCF79",
    primaryHover: "#FDD994",
    primaryActive: "#FFC452",
    tooltipBackground: "#787878",
    tooltipText: "#FFFFFF",
    workshopBlue: '#167FFB',
    accent: "#000000",
    secondary: "#656565",
    success: "#86AF3F",
    info: "#EED055",
    warning: "#FB8C00",
    grey: '#CDCDCD',
    error: "#FF5252",
    neutral: "#333333",
    fakeBlack: "#57534e",
    darkGrey: "#787878",
    middleGrey: "#CDCDCD",
    lightGrey: "#ECECEC",
    veryLightGrey: "#F6F6F6",
    positiveGreen: "#7BC079",
    positiveGreenDarken: "#3C9739",
    mediumOrange: "#FFC85C",
    negativeRed: "#FF5656",
    limeGreen: "#FFC447",
    darkmoodGlobalBg: '#15292B',
    mediumOrangeOpacity: "#FFFAEF",
    negativeRedOpacity: "#FFEFEF",
    positiveGreenOpacity: "#F2F9F2",
    transparentPositiveGreen: "#D8EDD7",
    transparentMediumOrange: "#FFF3DB",
    transparentNegativeRed: "#FAD4D4",
    realDark: "#202124",
    realLight: "#ffffff",
    darkBtn: "#404040"
  }
}

const neutral = {
  dark: false,
  colors: {
    background: '#FFFFFF',
    surface: '#FFFFFF',
    primary: "#333333",
    primaryHover: "#8c8c8c",
    primaryActive: "#151515",
    tooltipBackground: "#787878",
    tooltipText: "#FFFFFF",
    accent: "#000000",
    secondary: "#656565",
    success: "#86af3f",
    info: "#eed055",
    warning: "#FB8C00",
    grey: '#CDCDCD',
    error: "#FF5252",
    neutral: "#333333",
    fakeBlack: "#333333",
    darkGrey: "#787878",
    middleGrey: "#CDCDCD",
    lightGrey: "#ECECEC",
    veryLightGrey: "#F6F6F6",
    positiveGreen: "#7BC079",
    mediumOrange: "#FFC85C",
    negativeRed: "#FF5656",
    mediumOrangeOpacity: "#FFFAEF",
    negativeRedOpacity: "#FFEFEF",
    positiveGreenOpacity: "#F2F9F2",
    transparentPositiveGreen: "#D8EDD7",
    transparentMediumOrange: "#fff3db",
    transparentNegativeRed: "#FAD4D4"
  }
}

// New themes
const light = {
  dark: false,
  colors: {
    background: '#d0d0d0',
    surface: '#F3F3F3',
    primary: '#1976D2',
    secondary: '#b1C3F3',
    accent: '#82B1FF',
    error: '#FF5252',
    info: '#2196F3',
    success: '#4CAF50',
    warning: '#FFC107',
  }
}

const dark = {
  dark: true,
  colors: {
    background: '#121212',
    surface: '#212121',
    primary: '#BB86FC',
    secondary: '#162129',
    accent: '#3700B3',
    error: '#CF6679',
    info: '#2196F3',
    success: '#4CAF50',
    warning: '#FB8C00',
  }
}

const blackguard = {
  dark: true,
  colors: {
    background: '#000000',
    surface: '#121212',
    primary: '#FF4081',
    secondary: '#321212',
    accent: '#448AFF',
    error: '#FF5252',
    info: '#2196F3',
    success: '#4CAF50',
    warning: '#FFD600',
  }
}

const polaris = {
  dark: false,
  colors: {
    background: '#E3F2FD',
    surface: '#708596',
    primary: '#0d3c61',
    secondary: '#1976D2',
    accent: '#FF4081',
    error: '#F44336',
    info: '#00BCD4',
    success: '#4CAF50',
    warning: '#FFC107',
  }
}

const nebula = {
  dark: true,
  colors: {
    background: '#11001C',
    surface: '#190028',
    primary: '#7B1FA2',
    secondary: '#390028',
    accent: '#18FFFF',
    error: '#FF5252',
    info: '#2196F3',
    success: '#4CAF50',
    warning: '#FFC107',
  }
}

const system = {
  dark: false,
  colors: {
    background: '#FFFFFF',
    surface: '#7a7a7a',
    primary: '#181818',
    secondary: '#795548',
    accent: '#009688',
    error: '#FF5252',
    info: '#2196F3',
    success: '#4CAF50',
    warning: '#FFC107',
  }
}

export default createVuetify(
  {
    date: {
      adapter: VuetifyDateAdapter,
    },
    icons: {
      defaultSet: 'mdi',
      aliases,
      sets: {
        mdi,
      },
    },
    theme: {
      defaultTheme: 'studio',
      themes: {
        studio,
        neutral,
        light,
        dark,
        blackguard,
        polaris,
        nebula,
        system,
      },
      variations: {
        colors: [
          'primary',
          'primaryHover',
          'secondary',
          'fakeBlack',
          'darkGrey',
          'middleGrey',
          'lightGrey',
          'veryLightGrey',
          'positiveGreen',
          'mediumOrange',
          'negativeRed',
          'limeGreen',
        ],
        lighten: 5,
        darken: 5,
      },
    },
    components: {
      ...components,
      ...labs,
    },
  }
)
