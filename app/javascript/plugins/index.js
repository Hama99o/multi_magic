import { VueQueryPlugin } from 'vue-query';
import { pinia } from '@/stores';
import { setHTTPHeader } from '@/services/http.service';
import AuthService from '@/services/auth.service';
import i18n from "@/plugins/i18n.js";
import router from "@/routers/index.js";
import { showToast } from '@/utils/showToast';
import vuetify from "@/plugins/vuetify";
export const globalProperties = {
  $showToast: showToast,
};

// STYLES
// import '@/assets/css/style.scss';

const token = AuthService.getToken();

if (token) {
  setHTTPHeader({ Authorization: token });
}

export const registerPlugins = (app) => {
  app.use(router);
  app.use(vuetify);
  app.use(pinia);
  app.use(VueQueryPlugin);
  app.use(i18n);
  app.config.globalProperties = { ...app.config.globalProperties, ...globalProperties };
};
